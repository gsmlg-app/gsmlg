package org.gsmlg.app

import android.content.Intent
import android.os.Bundle
import android.widget.FrameLayout
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.android.FlutterFragment

class CompanionActivity : FragmentActivity() {
    private var flutter: FlutterFragment? = null
    var visible = false
        private set

    override fun onCreate(savedInstanceState: Bundle?) {
        val accepted = CompanionHost.attach(this, intent.getLongExtra("generation", -1))
        super.onCreate(if (accepted) savedInstanceState else null)
        if (!accepted) {
            finishAndRemoveTask()
            return
        }
        setContentView(FrameLayout(this).apply { id = R.id.duo_companion })
        flutter = supportFragmentManager.findFragmentByTag("companion") as? FlutterFragment
        if (flutter == null) {
            flutter = FlutterFragment.withCachedEngine(CompanionHost.ENGINE_ID)
                .destroyEngineWithFragment(false)
                .shouldAutomaticallyHandleOnBackPressed(true)
                .build<FlutterFragment>()
            supportFragmentManager.beginTransaction()
                .add(R.id.duo_companion, requireNotNull(flutter), "companion")
                .commitNow()
        }
    }

    override fun onPostResume() {
        super.onPostResume()
        flutter?.onPostResume()
    }

    override fun onNewIntent(intent: Intent) {
        flutter?.onNewIntent(intent)
        super.onNewIntent(intent)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        flutter?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        flutter?.onActivityResult(requestCode, resultCode, data)
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        flutter?.onTrimMemory(level)
    }

    override fun onStart() {
        super.onStart()
        visible = true
    }

    override fun onStop() {
        visible = false
        super.onStop()
    }

    override fun onDestroy() {
        super.onDestroy()
        CompanionHost.detached(this, isChangingConfigurations)
    }
}
