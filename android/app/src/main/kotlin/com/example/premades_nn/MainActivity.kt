package com.example.premades_nn

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.annotation.RequiresApi

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
//import io.flutter.plugins.GeetestGT3Plugin
import io.flutter.plugins.HeartBeatPlugin
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.utils.Constants


class MainActivity : FlutterActivity() {

    //主界面返回监听
    private val CHANNEL = "android/back/desktop"

    private val CHECK_FLOAT_WINDOW_CHANNEL = "float_window_btn"

    private val TAG = "FloatBtnPlugin"

    private var REQUEST_CODE = 0X1


    companion object {
        lateinit var channel: MethodChannel
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        registerCustomPlugin(this)

        //主界面返回监听
        MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "backDesktop") {
                result.success(true)
                moveTaskToBack(false)
            }
        }

        //悬浮窗权限检查
        channel = MethodChannel(getFlutterView(), CHECK_FLOAT_WINDOW_CHANNEL)
        channel.setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "showFloatWindow") {
                Log.d(TAG, "onMethodCall: showFloatWindow")
                val time = methodCall.argument<Int>("time")
                Constants.isStartTime = methodCall.argument<Boolean>("isStartTime")!!
                val floatType = methodCall.argument<Int>("floatType")
                val roomNo = methodCall.argument<Int>("roomNo")
                val nnId = methodCall.argument<Int>("nnId")
                Constants.voiceCallType = methodCall.argument<Int>("voiceCallType")!!
                val nickName = methodCall.argument<String>("nickName")
                val imageUrl = methodCall.argument<String>("imageUrl")

                intent = Intent(this@MainActivity, FloatingImageDisplayService::class.java)
                intent.putExtra("time", time)
                intent.putExtra("floatType", floatType)
                intent.putExtra("roomNo", roomNo)
                intent.putExtra("nnId", nnId)
                intent.putExtra("nickName", nickName)
                intent.putExtra("imageUrl", imageUrl)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (Settings.canDrawOverlays(this)) {
                        startService(intent)
                    } else {
                        startActivityForResult(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")), REQUEST_CODE)
                    }
                } else {
                    startService(intent)
                }
            } else if (methodCall.method == "startVoiceCall") {
                Log.d(TAG, "onMethodCall: startVoiceCall")
                Constants.isStartTime = true
                Constants.voiceCallType = 3

            } else if (methodCall.method == "close") {
                Log.d(TAG, "onMethodCall: close")

                if (FloatingImageDisplayService.isStarted){
                    stopService(Intent(this@MainActivity, FloatingImageDisplayService::class.java))
                }

            } else {
                result.notImplemented()
            }
        }

    }
    private fun registerCustomPlugin(registrar: PluginRegistry) {
//        GeetestGT3Plugin.registerWith(registrar.registrarFor(GeetestGT3Plugin.CHANNEL))
        HeartBeatPlugin.registerWith(registrar.registrarFor(HeartBeatPlugin.CHANNEL))
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE){
            if (!Settings.canDrawOverlays(this)) {
                channel.invokeMethod("authFailure", null)
            } else {
                channel.invokeMethod("authSuccess", null)
                startService(intent)
            }
        }
    }
}
