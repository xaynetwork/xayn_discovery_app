package com.example.xayn_discovery_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.instabug.instabugflutter.InstabugFlutterPlugin


class MainActivity : FlutterActivity() {
    private val INSTABUG_ANDROID_CHANNEL = "instabug_android"
    private val INSTABUG_ANDROID_START_METHOD = "startInstabug"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INSTABUG_ANDROID_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == INSTABUG_ANDROID_START_METHOD) {
                val token: String? = call.argument<String>("token")
                val invocationEvents: ArrayList<String>? = call.argument<ArrayList<String>>("invocationEvents")
                startInstabug(token, invocationEvents);
            } else {
                result.notImplemented()
            }
        }
    }

    fun startInstabug(token: String?, invocationEvents: ArrayList<String>?) {
        if (token == null) {
            throw IllegalArgumentException("startInstabug Android: Token must not be equal to null")
        }

        if (invocationEvents == null) {
            throw IllegalArgumentException("startInstabug Android: invocationEvents must not be equal to null")
        }

        val instabug = InstabugFlutterPlugin()
        instabug.start(this.getApplication(), token, invocationEvents)
    }
}