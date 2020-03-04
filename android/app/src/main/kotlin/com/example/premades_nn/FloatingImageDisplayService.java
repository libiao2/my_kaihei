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
import com.tekartik.sqflite.Constant;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugins.FloatBtnPlugin;
import io.flutter.plugins.utils.Constants;

/**
 * Created by dongzhong on 2018/5/30.
 */

public class FloatingImageDisplayService extends Service {
    public static boolean isStarted = false;

    private WindowManager windowManager;
    private WindowManager.LayoutParams layoutParams;

    private View displayView;

    private int screenWidth;
    private int screenHeight;

//    String imageUrl = "http://img5.imgtn.bdimg.com/it/u=2836714648,3992381933&fm=11&gp=0.jpg";

    private Handler mEventHandler = new Handler(Looper.getMainLooper());

    private int startTime;
    private int floatType;//0:语音通话  1：房间  默认为语音通话
    private int roomNo;
    private int nnId;
    private String nickname;
    private String imageUrl;

    private int serverTime = 0;

    private int updateTime;//锁屏或者

    @Override
    public void onCreate() {
        super.onCreate();

        isStarted = true;
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        layoutParams = new WindowManager.LayoutParams();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            layoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            layoutParams.type = WindowManager.LayoutParams.TYPE_PHONE;
        }
        layoutParams.format = PixelFormat.RGBA_8888;
        layoutParams.gravity = Gravity.LEFT | Gravity.TOP;
        layoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        layoutParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.height = WindowManager.LayoutParams.WRAP_CONTENT;
        layoutParams.y = 300;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        isStarted = false;
        windowManager.removeView(displayView);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startTime = intent.getIntExtra("time", 0);
        floatType = intent.getIntExtra("floatType", 0);
        roomNo = intent.getIntExtra("roomNo", 0);
        nnId = intent.getIntExtra("nnId", 0);
        nickname = intent.getStringExtra("nickName");
        imageUrl = intent.getStringExtra("imageUrl");

        startTime();
        showFloatingWindow();
        return super.onStartCommand(intent, flags, startId);
    }


    private void showFloatingWindow() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                return;
            }
        }

        if (displayView != null && windowManager != null){
            windowManager.removeView(displayView);
        }

        LayoutInflater layoutInflater = LayoutInflater.from(this);
        displayView = layoutInflater.inflate(R.layout.image_display, null);
        displayView.setOnTouchListener(new FloatingOnTouchListener());
        displayView.setOnClickListener(v -> {
            if (floatType == 0){
                HashMap<String, Object> result = new HashMap<>();
                result.put("nnId",nnId);
                result.put("nickname",nickname);
                result.put("imageUrl",imageUrl);
                result.put("startTime",startTime);
                result.put("floatType",floatType);
                result.put("voiceCallType", Constants.voiceCallType);
                mEventHandler.post(() -> MainActivity.channel.invokeMethod("onClick", result));
            } else if (floatType == 1){
                //TODO 进入房间
            }

            /**
             * 屏蔽掉点击悬浮窗关闭悬浮窗
             */
//            stopSelf();
        });
        ImageView imageView = displayView.findViewById(R.id.image_display_imageview);
        Glide.with(this)
                .load(imageUrl)
                .apply(RequestOptions.bitmapTransform(new RoundedCorners(100)).error(R.drawable.head_default)
                        .placeholder(R.drawable.head_default))
                .into(imageView);
        windowManager.addView(displayView, layoutParams);


    }

    /**
     * 每秒查询是否开始通话时长计时
     */
    private void startTime(){
        Runnable mChangeTipsRunnable = new Runnable() {
            @Override
            public void run() {
                serverTime++;
                if (Constants.isStartTime){
                    startTime++;
                }
//                if (serverTime % 60 == 0 && isStarted){
//                    showFloatingWindow();
//                }
                mEventHandler.postDelayed(this, 1000);
            }
        };

        mEventHandler.post(mChangeTipsRunnable);
    }

    /**
     * 悬浮框拖拽
     */
    private class FloatingOnTouchListener implements View.OnTouchListener {
        private int x;
        private int y;

        private int viewWidth;//view宽度
        private int viewHeight;//view高度
        private int maxX;//组件允许的最大偏移量X
        private int maxY;//组件允许的最大偏移量Y

        FloatingOnTouchListener(){
            screenWidth = windowManager.getDefaultDisplay().getWidth();//1440
            screenHeight = windowManager.getDefaultDisplay().getHeight();//2416
        }

        @Override
        public boolean onTouch(View view, MotionEvent event) {
            viewWidth = displayView.getWidth();
            viewHeight = displayView.getHeight();
            maxX = screenWidth - viewWidth;
            maxY = screenHeight - viewHeight;

            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    x = (int) event.getRawX();
                    y = (int) event.getRawY();
                    break;
                case MotionEvent.ACTION_MOVE:
                    int nowX = (int) event.getRawX();
                    int nowY = (int) event.getRawY();
                    int movedX = nowX - x;
                    int movedY = nowY - y;
                    x = nowX;
                    y = nowY;
                    layoutParams.x = layoutParams.x + movedX;
                    layoutParams.y = layoutParams.y + movedY;
                    if (layoutParams.x > maxX){
                        layoutParams.x = maxX;
                    }
                    if (layoutParams.y > maxY){
                        layoutParams.y = maxY;
                    }
                    windowManager.updateViewLayout(view, layoutParams);
                    break;
                    case MotionEvent.ACTION_UP:

//                        if (maxX - layoutParams.x > 10){
//                            ImageView imageView = displayView.findViewById(R.id.image_display_imageview);
//                            imageView.setImageDrawable(R.drawable.);
//                        }

                        System.out.println("maxX = " + maxX + ", maxY = " + maxY);
                        System.out.println("组件起始位置x：" + layoutParams.x + ", 组件起始位置Y：" + layoutParams.y);
                        System.out.println("组件宽度：" + displayView.getWidth() + ", 组件高度：" + displayView.getHeight());
                        break;
                default:
                    break;
            }
            return false;
        }
    }
}
