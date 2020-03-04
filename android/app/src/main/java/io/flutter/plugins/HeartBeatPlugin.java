package io.flutter.plugins;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.example.premades_nn.FloatingImageDisplayService;
import com.example.premades_nn.HeartBeatService;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.utils.Constants;

public class HeartBeatPlugin implements MethodChannel.MethodCallHandler{

    private final String TAG = "HeartBeatPlugin";

    public static String CHANNEL = "heart_beat";


    public static MethodChannel channel;

    private Activity activity;


    private HeartBeatPlugin(Activity activity) {
        this.activity = activity;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL);
        HeartBeatPlugin instance = new HeartBeatPlugin(registrar.activity());
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        System.out.println(methodCall.method + " 被调用");
        if (methodCall.method.equals("start")) {
            Intent intent = new Intent(activity, HeartBeatService.class);
            activity.startService(intent);
        } else if(methodCall.method.equals("close")){
            Intent intent = new Intent(activity, HeartBeatService.class);
            activity.stopService(intent);
        } else {
            result.notImplemented();
        }
    }
}