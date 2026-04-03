package com.flutterneverdie.barrier_free_navigation;

import android.app.Activity;
import android.os.Build;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** BarrierFreeNavigationPlugin */
public class BarrierFreeNavigationPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final String TAG = "BarrierFreeNavPlugin";
    private MethodChannel channel;
    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "barrier_free_navigation/init");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("requestKeyboardFocus")) {
            handleRequestKeyboardFocus(result);
        } else {
            result.notImplemented();
        }
    }

    private void handleRequestKeyboardFocus(final MethodChannel.Result result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is null", null);
            return;
        }

        activity.runOnUiThread(() -> {
            try {
                Log.d(TAG, "키보드 포커스 요청 시도");
                View decorView = activity.getWindow().getDecorView();
                
                // 안드로이드 8.0(API 26) 이상에서 시스템 기본 포커스 하이라이트(테두리) 비활성화
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    decorView.setDefaultFocusHighlightEnabled(false);
                }

                decorView.setFocusableInTouchMode(true);
                decorView.requestFocus();
                
                // 100ms 지연 후 엔터키(DOWN) 발생
                activity.getWindow().getDecorView().postDelayed(() -> {
                    KeyEvent downEvent = new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER);
                    activity.getWindow().getDecorView().dispatchKeyEvent(downEvent);
                    
                    // 다시 10ms 후 엔터키(UP) 발생
                    activity.getWindow().getDecorView().postDelayed(() -> {
                        KeyEvent upEvent = new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER);
                        activity.getWindow().getDecorView().dispatchKeyEvent(upEvent);
                    }, 10);
                }, 100);
                
                result.success("키보드 포커스 요청 완료");
            } catch (Exception e) {
                result.error("ERROR", "키보드 포커스 요청 실패", e.getMessage());
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    // --- ActivityAware implementation ---
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }
}
