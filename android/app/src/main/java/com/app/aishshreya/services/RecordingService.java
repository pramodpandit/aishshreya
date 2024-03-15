package com.app.aishshreya.services;

import android.accessibilityservice.AccessibilityService;
import android.annotation.SuppressLint;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;


public class RecordingService extends AccessibilityService {
    public static final String LOG_TAG_S = "MyService:";


    @SuppressLint("RtlHardcoded")
    @Override
    public void onCreate() {
        super.onCreate();

        Log.i("start Myservice", "MyService");

    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        Log.e(LOG_TAG_S, "Event :" + event.getEventType());
    }

    @Override
    public void onInterrupt() {

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }


    @Override
    protected void onServiceConnected() {
        System.out.println("onServiceConnected");
        Log.d(LOG_TAG_S, "onServiceConnected");
    }

}
