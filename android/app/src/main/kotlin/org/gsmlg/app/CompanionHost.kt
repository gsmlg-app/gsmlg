package org.gsmlg.app

import android.app.ActivityOptions
import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/** One owner, engine and companion task. All callbacks run on Android's main thread. */
internal object CompanionHost {
    const val ENGINE_ID = "org.gsmlg.duo.companion"
    private val lifecycle = CompanionLifecycle()
    private var owner = WeakReference<MainActivity>(null)
    private var companion = WeakReference<CompanionActivity>(null)
    private var manager: DisplayManager? = null
    private var methods: MethodChannel? = null
    private var events: EventChannel? = null
    private var sink: EventChannel.EventSink? = null
    private val closed = mutableListOf<() -> Unit>()
    private var requestedDisplay: Int? = null
    private var releaseEngine = false
    var engine: FlutterEngine? = null
        private set

    private val listener = object : DisplayManager.DisplayListener {
        override fun onDisplayAdded(displayId: Int) { sink?.success(displayId) }
        override fun onDisplayChanged(displayId: Int) { sink?.success(displayId) }
        override fun onDisplayRemoved(displayId: Int) {
            if (requestedDisplay == displayId) hide(displayId) {}
            sink?.success(displayId)
        }
    }

    fun bind(activity: MainActivity, primaryEngine: FlutterEngine) {
        clearChannels()
        owner = WeakReference(activity)
        releaseEngine = false
        manager = activity.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        methods = MethodChannel(primaryEngine.dartExecutor.binaryMessenger,
            "dev.duskmoon.duo/displays").also { channel ->
            channel.setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "listDisplays" -> result.success(displays(activity))
                        "show" -> result.success(show(activity,
                            requireNotNull(call.argument<Int>("displayId"))))
                        "hide" -> hide(requireNotNull(call.argument<Int>("displayId"))) {
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("companion_unavailable", error.message, null)
                }
            }
        }
        events = EventChannel(primaryEngine.dartExecutor.binaryMessenger,
            "dev.duskmoon.duo/display_changes").also { channel ->
            channel.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                    sink = eventSink
                    manager?.registerDisplayListener(listener, Handler(Looper.getMainLooper()))
                }
                override fun onCancel(arguments: Any?) {
                    manager?.unregisterDisplayListener(listener)
                    sink = null
                }
            })
        }
    }

    @Suppress("DEPRECATION")
    private fun displays(activity: MainActivity): List<Int> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return emptyList()
        val host = activity.windowManager.defaultDisplay.displayId
        return manager?.getDisplays(DisplayManager.DISPLAY_CATEGORY_PRESENTATION)
            ?.filter { it.isValid && CompanionLifecycle.eligible(it.displayId, host, true) }
            ?.map { it.displayId } ?: emptyList()
    }

    private fun show(activity: MainActivity, displayId: Int): Boolean {
        if (!displays(activity).contains(displayId) || lifecycle.isClosing()) return false
        val needsLaunch = lifecycle.needsLaunch()
        val generation = lifecycle.show(displayId)
        requestedDisplay = displayId
        if (needsLaunch) {
            try {
                if (engine == null) {
                    val loader = FlutterInjector.instance().flutterLoader()
                    loader.startInitialization(activity.applicationContext)
                    loader.ensureInitializationComplete(activity.applicationContext, null)
                    engine = FlutterEngine(activity.applicationContext).also {
                        it.navigationChannel.setInitialRoute("secondaryDisplayMain")
                        it.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(
                            loader.findAppBundlePath(), "secondaryDisplayMain"))
                        FlutterEngineCache.getInstance().put(ENGINE_ID, it)
                    }
                }
                launch(activity, displayId, generation)
            } catch (error: Exception) {
                lifecycle.launchFailed()
                requestedDisplay = null
                engine?.destroy()
                engine = null
                FlutterEngineCache.getInstance().remove(ENGINE_ID)
                throw error
            }
        }
        return true
    }

    private fun launch(activity: MainActivity, displayId: Int, generation: Long) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val intent = Intent(activity, CompanionActivity::class.java)
            .putExtra("generation", generation)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val options = ActivityOptions.makeBasic().setLaunchDisplayId(displayId)
        activity.startActivity(intent, options.toBundle())
    }

    private fun hide(displayId: Int, complete: () -> Unit) {
        if (requestedDisplay == displayId) requestedDisplay = null
        if (lifecycle.displayId() != displayId) {
            complete()
            return
        }
        closed.add(complete)
        if (lifecycle.close()) {
            companion.get()?.finishAndRemoveTask()
        } else {
            finishClose()
        }
    }

    fun attach(activity: CompanionActivity, generation: Long): Boolean {
        if (generation != lifecycle.generation() || !lifecycle.isOpening()) return false
        val accepted = lifecycle.attach(generation)
        companion = WeakReference(activity)
        return accepted && engine != null && owner.get() != null
    }

    fun detached(activity: CompanionActivity, changingConfigurations: Boolean) {
        if (companion.get() !== activity) return
        companion.clear()
        lifecycle.detached(changingConfigurations)
        if (lifecycle.displayId() == null) finishClose()
    }

    private fun finishClose() {
        if (releaseEngine) {
            engine?.destroy()
            engine = null
            FlutterEngineCache.getInstance().remove(ENGINE_ID)
        }
        val callbacks = closed.toList()
        closed.clear()
        callbacks.forEach { it() }
    }

    fun resume(activity: MainActivity) {
        if (owner.get() !== activity || lifecycle.isClosing()) return
        val target = requestedDisplay ?: return
        try {
            if (lifecycle.needsLaunch()) {
                show(activity, target)
            } else if (companion.get()?.visible == false) {
                launch(activity, target, lifecycle.generation())
            }
        } catch (error: Exception) {
            sink?.error("companion_unavailable", error.message, null)
        }
    }

    fun unbind(activity: MainActivity, changingConfigurations: Boolean) {
        if (owner.get() !== activity) return
        clearChannels()
        owner.clear()
        if (changingConfigurations) return
        releaseEngine = true
        requestedDisplay = null
        val target = lifecycle.displayId()
        if (target != null) hide(target) {} else finishClose()
    }

    private fun clearChannels() {
        manager?.unregisterDisplayListener(listener)
        methods?.setMethodCallHandler(null)
        events?.setStreamHandler(null)
        methods = null
        events = null
        sink = null
    }
}
