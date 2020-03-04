package io.flutter.plugins;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.example.premades_nn.FloatingImageDisplayService;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.utils.Constants;

public class FloatBtnPlugin implements MethodChannel.MethodCallHandler{

    private final String TAG = "FloatBtnPlugin";

    public static String CHANNEL = "float_window_btn";

    private Handler mEventHandler = new Handler(Looper.getMainLooper());

    public static MethodChannel channel;

    private Activity activity;

    public static boolean isStartTime = false;


    private FloatBtnPlugin(Activity activity) {
        this.activity = activity;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        channel = new MethodChannel(registrar.messenger(), CHANNEL);
        FloatBtnPlugin instance = new FloatBtnPlugin(registrar.activity());
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (methodCall.method.equals("show")) {
            Log.d(TAG, "onMethodCall: show");
            int time = methodCall.argument("time") == null?0:methodCall.argument("time");
            isStartTime = methodCall.argument("isStartTime") == null?false:methodCall.argument("isStartTime");
            int floatType = methodCall.argument("floatType") == null?0:methodCall.argument("floatType");
            int roomNo = methodCall.argument("roomNo") == null?0:methodCall.argument("roomNo");
            int nnId = methodCall.argument("nnId") == null?0:methodCall.argument("nnId");
            Constants.voiceCallType = methodCall.argument("voiceCallType") == null?0:methodCall.argument("voiceCallType");
            String nickName = methodCall.argument("nickName") == null?"":methodCall.argument("nickName");
            String imageUrl = methodCall.argument("imageUrl") == null?"":methodCall.argument("imageUrl");

            Intent intent = new Intent(activity, FloatingImageDisplayService.class);
            intent.putExtra("time", time);
            intent.putExtra("floatType", floatType);
            intent.putExtra("roomNo", roomNo);
            intent.putExtra("nnId", nnId);
            intent.putExtra("nickName", nickName);
            intent.putExtra("imageUrl", imageUrl);
            activity.startService(intent);
        } else if(methodCall.method.equals("close")){
            Log.d(TAG, "onMethodCall: close");
            Intent intent = new Intent(activity, FloatingImageDisplayService.class);
            activity.stopService(intent);
        } else if (methodCall.method.equals("startTime")){
            isStartTime = true;
        } else if(methodCall.method.equals("voiceCallType")){
            Constants.voiceCallType = methodCall.argument("voiceCallType") == null?0:methodCall.argument("voiceCallType");
        } else {
            result.notImplemented();
        }
    }
}