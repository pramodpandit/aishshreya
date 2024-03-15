package com.app.aishshreya;

import android.content.Intent;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.annotation.NonNull;

import android.view.accessibility.AccessibilityManager;
import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.content.pm.ServiceInfo;
import android.content.Context;
import java.util.List;

import com.app.aishshreya.AccessibilityCheck;
import com.app.aishshreya.services.RecordingService;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "nativeChannel";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("startAccessibilityActivity")) {
                                /*String myText = call.argument("myText");
                                setText(myText);*/
                                startActivity(new Intent(MainActivity.this, AccessibilityCheck.class));
                            } else if (call.method.equals("checkAccessibility")) {
                                boolean isEnabled = isAccessibilityServiceEnabled(RecordingService.class);
                                String checkResult = isEnabled ? "enabled" : "disabled";
                                result.success(checkResult);
                            }
                        }
                );

    }

    public boolean isAccessibilityServiceEnabled(Class<? extends AccessibilityService> service) {
        AccessibilityManager am = (AccessibilityManager) getSystemService(Context.ACCESSIBILITY_SERVICE);
        List<AccessibilityServiceInfo> enabledServices = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK);

        for (AccessibilityServiceInfo enabledService : enabledServices) {
            ServiceInfo enabledServiceInfo = enabledService.getResolveInfo().serviceInfo;
            if (enabledServiceInfo.packageName.equals(this.getPackageName()) && enabledServiceInfo.name.equals(service.getName()))
                return true;
        }

        return false;
    }

}
