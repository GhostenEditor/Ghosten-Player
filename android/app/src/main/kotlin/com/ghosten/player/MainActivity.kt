package com.ghosten.player

import android.annotation.TargetApi
import android.app.UiModeManager
import android.content.Intent
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.window.BackEvent
import android.window.OnBackAnimationCallback
import android.window.OnBackInvokedCallback
import android.window.OnBackInvokedDispatcher
import androidx.annotation.RequiresApi
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentManager
import io.flutter.Build.API_LEVELS
import io.flutter.embedding.android.FlutterFragment

class MainActivity : FragmentActivity() {
    private var mainFragment: MainFragment? = null
    private var hasRegisteredBackCallback = false
    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.NormalTheme)
        setContentView(R.layout.main_layout)

        super.onCreate(savedInstanceState)

        if (intent.scheme == "content") {
            mainFragment = ensureFlutterFragmentCreated(
                PLAYER_FRAGMENT, "player", listOf(androidDeviceType().toString(), intent.data?.toString())
            )
        } else {
            mainFragment = ensureFlutterFragmentCreated(MAIN_FRAGMENT, "main", listOf(androidDeviceType().toString()))
        }
        registerOnBackInvokedCallback()
    }

    private fun registerOnBackInvokedCallback() {
        if (!hasRegisteredBackCallback && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            onBackInvokedDispatcher.registerOnBackInvokedCallback(
                OnBackInvokedDispatcher.PRIORITY_DEFAULT, createOnBackInvokedCallback()
            )
            hasRegisteredBackCallback = true
        }
    }

    private fun createOnBackInvokedCallback(): OnBackInvokedCallback {
        if (Build.VERSION.SDK_INT >= API_LEVELS.API_34) {
            return object : OnBackAnimationCallback {
                override fun onBackInvoked() {
                    commitBackGesture()
                }

                override fun onBackCancelled() {
                    cancelBackGesture()
                }

                override fun onBackProgressed(backEvent: BackEvent) {
                    updateBackGestureProgress(backEvent)
                }

                override fun onBackStarted(backEvent: BackEvent) {
                    startBackGesture(backEvent)
                }
            }
        }

        return OnBackInvokedCallback { mainFragment?.onBackPressed() }
    }

    @TargetApi(API_LEVELS.API_34)
    @RequiresApi(API_LEVELS.API_34)
    fun startBackGesture(backEvent: BackEvent) {
        if (stillAttachedForEvent("startBackGesture")) {
            mainFragment?.startBackGesture(backEvent)
        }
    }

    @TargetApi(API_LEVELS.API_34)
    @RequiresApi(API_LEVELS.API_34)
    fun updateBackGestureProgress(backEvent: BackEvent) {
        if (stillAttachedForEvent("updateBackGestureProgress")) {
            mainFragment?.updateBackGestureProgress(backEvent)
        }
    }

    @TargetApi(API_LEVELS.API_34)
    @RequiresApi(API_LEVELS.API_34)
    fun commitBackGesture() {
        if (stillAttachedForEvent("commitBackGesture")) {
            mainFragment?.commitBackGesture()
        }
    }

    @TargetApi(API_LEVELS.API_34)
    @RequiresApi(API_LEVELS.API_34)
    fun cancelBackGesture() {
        if (stillAttachedForEvent("cancelBackGesture")) {
            mainFragment?.cancelBackGesture()
        }
    }

    private fun stillAttachedForEvent(event: String): Boolean {
        if (mainFragment == null) {
            return false
        }
        return true
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        mainFragment?.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
    }

    override fun onPostResume() {
        super.onPostResume()
        mainFragment?.onPostResume()
    }

    override fun onNewIntent(intent: Intent) {
        mainFragment?.onNewIntent(intent)
        super.onNewIntent(intent)
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        mainFragment?.onBackPressed()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String?>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        mainFragment?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(
        requestCode: Int, resultCode: Int, data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        mainFragment?.onActivityResult(requestCode, resultCode, data)
    }

    override fun onUserLeaveHint() {
        mainFragment?.onUserLeaveHint()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        mainFragment?.onTrimMemory(level)
    }


    private fun ensureFlutterFragmentCreated(tag: String, entryPoint: String, args: List<String?>): MainFragment {
        val fragmentManager: FragmentManager = supportFragmentManager
        var fragment = fragmentManager.findFragmentByTag(tag) as MainFragment?

        val newFragment = FlutterFragment
            .NewEngineFragmentBuilder(MainFragment::class.java)
            .shouldDelayFirstAndroidViewDraw(true)
            .shouldAutomaticallyHandleOnBackPressed(true)
            .dartEntrypoint(entryPoint)
            .dartEntrypointArgs(args)
            .build<MainFragment>()
        if (fragment == null) {
            fragmentManager.beginTransaction().add(R.id.fragment_container, newFragment, tag).commit()
        } else {
            fragmentManager.beginTransaction().replace(R.id.fragment_container, newFragment, tag).commit()
        }
        fragment = newFragment
        return fragment;
    }

    private fun androidDeviceType(): Int {
        val uiModeManager = getSystemService(UI_MODE_SERVICE) as UiModeManager
        return if (uiModeManager.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION) {
            DEVICE_TYPE_TV
        } else if (resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK >= Configuration.SCREENLAYOUT_SIZE_LARGE) {
            DEVICE_TYPE_PAD
        } else {
            DEVICE_TYPE_PHONE
        }
    }

    companion object {
        private const val DEVICE_TYPE_TV = 0
        private const val DEVICE_TYPE_PAD = 1
        private const val DEVICE_TYPE_PHONE = 2
        private const val MAIN_FRAGMENT = "main_fragment"
        private const val PLAYER_FRAGMENT = "player_fragment"
    }
}
