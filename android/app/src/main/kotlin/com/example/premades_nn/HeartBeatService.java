package com.example.premades_nn;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.provider.Settings;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;

import androidx.annotation.RequiresApi;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.nn.flutter.premades.R;

import java.util.HashMap;

import io.flutter.plugins.HeartBeatPlugin;
import io.flutter.plugins.utils.Constants;

/**
 * Created by dongzhong on 2018/5/30.
 */

public class HeartBeatService extends Service {

    private Handler mEventHandler = new Handler(Looper.getMainLooper());

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startTime();
        return super.onStartCommand(intent, flags, startId);
    }


    /**
     * 每秒查询是否开始通话时长计时
     */
    private void startTime(){

        Runnable heartBeat = new Runnable() {
            @Override
            public void run() {
                mEventHandler.post(() -> HeartBeatPlugin.channel.invokeMethod("sendHeartBeat", null));
                mEventHandler.postDelayed(this, 10000);
            }
        };

        mEventHandler.post(heartBeat);
    }
}
