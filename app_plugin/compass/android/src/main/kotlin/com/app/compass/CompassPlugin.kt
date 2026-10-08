package com.app.compass

import android.app.Activity
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.Surface
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CompassPlugin : FlutterPlugin, ActivityAware, EventChannel.StreamHandler,
    MethodChannel.MethodCallHandler, SensorEventListener {
    private var eventChannel: EventChannel? = null
    private var methodChannel: MethodChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var activity: Activity? = null
    private var sensorManager: SensorManager? = null
    private var rotationVector: Sensor? = null
    private var accelerometer: Sensor? = null
    private var magneticField: Sensor? = null
    private var mode: CompassSensorMode? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var session = 0L
    private var sessionStartNanos = 0L
    private var displayRotation = Surface.ROTATION_0
    private var accuracy: Int? = null
    private var lastHeading: Double? = null
    private var accelerationSample: FloatArray? = null
    private var magneticSample: FloatArray? = null
    private val matrix = FloatArray(9)
    private val adjustedMatrix = FloatArray(9)
    private val orientation = FloatArray(3)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = EventChannel(binding.binaryMessenger, "app_compass/events").also {
            it.setStreamHandler(this)
        }
        methodChannel = MethodChannel(binding.binaryMessenger, "app_compass").also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventSink = null
        stopSensors()
        activity = null
        eventChannel?.setStreamHandler(null)
        methodChannel?.setMethodCallHandler(null)
        eventChannel = null
        methodChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        refreshOrientation()
        if (eventSink != null) startSensors()
    }

    override fun onDetachedFromActivityForConfigChanges() = detachActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivity() = detachActivity()

    private fun detachActivity() {
        stopSensors()
        activity = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        stopSensors()
        eventSink = events
        if (activity != null) startSensors()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stopSensors()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "refreshOrientation" -> {
                refreshOrientation()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    @Suppress("DEPRECATION")
    private fun currentDisplayRotation(): Int {
        val currentActivity = activity ?: return Surface.ROTATION_0
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            currentActivity.display?.rotation ?: Surface.ROTATION_0
        } else {
            currentActivity.windowManager.defaultDisplay.rotation
        }
    }

    private fun refreshOrientation() {
        val rotation = currentDisplayRotation()
        if (rotation != displayRotation) {
            displayRotation = rotation
            clearSamples()
        }
    }

    private fun startSensors() {
        stopSensors()
        val currentActivity = activity ?: return
        val manager = currentActivity.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        if (manager == null) {
            emitUnavailable("sensorNotFound")
            return
        }
        sensorManager = manager
        refreshOrientation()
        sessionStartNanos = SystemClock.elapsedRealtimeNanos()
        try {
            rotationVector = manager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            accelerometer = manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
            magneticField = manager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)
            val selection = CompassMath.selectSensors(
                rotationVector != null, accelerometer != null, magneticField != null,
                { register(manager, rotationVector) },
                { register(manager, accelerometer) && register(manager, magneticField) },
                { manager.unregisterListener(this) },
            )
            mode = selection.mode
            if (selection.unavailableReason != null) {
                stopSensors()
                emitUnavailable(selection.unavailableReason)
            }
        } catch (_: RuntimeException) {
            stopSensors()
            emitUnavailable("sensorFailure")
        }
    }

    private fun register(manager: SensorManager, sensor: Sensor?): Boolean {
        if (sensor == null) return false
        return try {
            manager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI, mainHandler)
        } catch (_: RuntimeException) {
            false
        }
    }

    private fun stopSensors() {
        session++
        sensorManager?.unregisterListener(this)
        sensorManager = null
        rotationVector = null
        accelerometer = null
        magneticField = null
        mode = null
        accuracy = null
        sessionStartNanos = 0L
        clearSamples()
    }

    private fun clearSamples() {
        accelerationSample = null
        magneticSample = null
        lastHeading = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        val currentMode = mode ?: return
        if (eventSink == null || event.timestamp < sessionStartNanos) return
        refreshOrientation()
        try {
            when (currentMode) {
                CompassSensorMode.ROTATION_VECTOR -> {
                    if (event.sensor != rotationVector) return
                    accuracy = event.accuracy
                    if (event.values.size < 3 || event.values.any { !it.isFinite() }) {
                        lastHeading = null
                        emitCalibratingWithoutHeading()
                        return
                    }
                    SensorManager.getRotationMatrixFromVector(matrix, event.values)
                }
                CompassSensorMode.FALLBACK -> {
                    when (event.sensor) {
                        accelerometer -> accelerationSample = validSample(event.values)
                        magneticField -> {
                            magneticSample = validSample(event.values)
                            accuracy = event.accuracy
                        }
                        else -> return
                    }
                    val acceleration = accelerationSample
                    val magnetic = magneticSample
                    if (acceleration == null || magnetic == null ||
                        !SensorManager.getRotationMatrix(matrix, null, acceleration, magnetic)
                    ) {
                        lastHeading = null
                        emitCalibratingWithoutHeading()
                        return
                    }
                }
            }
            val (axisX, axisY) = CompassMath.axesFor(displayRotation)
            if (!SensorManager.remapCoordinateSystem(matrix, axisX, axisY, adjustedMatrix)) {
                lastHeading = null
                emitCalibratingWithoutHeading()
                return
            }
            SensorManager.getOrientation(adjustedMatrix, orientation)
            val heading = Math.toDegrees(orientation[0].toDouble())
            lastHeading = heading.takeIf {
                it.isFinite() && accuracy != SensorManager.SENSOR_STATUS_UNRELIABLE
            }
            emit(CompassMath.reading(lastHeading, accuracy))
        } catch (_: RuntimeException) {
            stopSensors()
            emitUnavailable("sensorFailure")
        }
    }

    private fun validSample(values: FloatArray): FloatArray? =
        if (values.size >= 3 && values.take(3).all { it.isFinite() }) values.copyOf(3) else null

    override fun onAccuracyChanged(sensor: Sensor, newAccuracy: Int) {
        val qualitySensor = when (mode) {
            CompassSensorMode.ROTATION_VECTOR -> rotationVector
            CompassSensorMode.FALLBACK -> magneticField
            null -> null
        }
        if (sensor != qualitySensor || eventSink == null) return
        refreshOrientation()
        accuracy = newAccuracy
        if (newAccuracy == SensorManager.SENSOR_STATUS_UNRELIABLE) lastHeading = null
        emit(CompassMath.reading(lastHeading, accuracy))
    }

    private fun emitCalibratingWithoutHeading() = emit(CompassMath.reading(null, accuracy))

    private fun emitUnavailable(reason: String) = emit(mapOf(
        "status" to "unavailable",
        "magneticHeadingDegrees" to null,
        "accuracyDegrees" to null,
        "sensorAccuracy" to null,
        "unavailableReason" to reason,
    ))

    private fun emit(reading: Map<String, Any?>) {
        val sink = eventSink ?: return
        val currentSession = session
        if (Looper.myLooper() == Looper.getMainLooper()) {
            sink.success(reading)
        } else {
            mainHandler.post {
                if (eventSink === sink && session == currentSession) sink.success(reading)
            }
        }
    }
}
