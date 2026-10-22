package org.gsmlg.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var editorBridge: EditorFileBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        CompanionHost.bind(this, flutterEngine)
        editorBridge = EditorFileBridge(this, flutterEngine.dartExecutor.binaryMessenger).also {
            it.openIntent(intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        editorBridge?.openIntent(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (editorBridge?.onActivityResult(requestCode, resultCode, data) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        editorBridge?.close()
        editorBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onResume() {
        super.onResume()
        CompanionHost.resume(this)
    }

    override fun onDestroy() {
        CompanionHost.unbind(this, isChangingConfigurations)
        super.onDestroy()
    }
}
