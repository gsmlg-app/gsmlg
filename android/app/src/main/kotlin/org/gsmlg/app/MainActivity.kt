package org.gsmlg.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        CompanionHost.bind(this, flutterEngine)
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
