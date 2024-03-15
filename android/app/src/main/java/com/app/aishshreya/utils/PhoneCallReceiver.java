package com.app.aishshreya.utils;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.preference.PreferenceManager;
import android.telephony.TelephonyManager;
import android.util.Log;

import androidx.core.os.EnvironmentCompat;

import com.app.aishshreya.services.CallRecorderService;

import java.util.Date;

public class PhoneCallReceiver extends BroadcastReceiver {

    private static String savedNumber;
    private static boolean isIncoming = false;
    private static boolean isOutgoingCallPinged = false;
    private static Date callStartTime = null;

    private static int lastState;

    public static int call_state = 1;

    @Override
    public void onReceive(Context context, Intent intent) {
        String str;
        if (intent.getAction().equals(Intent.ACTION_NEW_OUTGOING_CALL)) {
            savedNumber = intent.getExtras().getString(Intent.EXTRA_PHONE_NUMBER);
            if (savedNumber == null) {
                savedNumber = intent.getStringExtra(Intent.EXTRA_PHONE_NUMBER);
            }
            Log.d("PhoneCallReceiver", "savedNumber number: " + savedNumber);
            if (isOutgoingCallPinged || (str = savedNumber) == null) {
                return;
            }
            onOutgoingCallStarted(context, str, callStartTime);
            return;
        }

        String string = intent.getExtras().getString("state");
        String string2 = intent.getExtras().getString("incoming_number");
        int i = 0;
        //Log.d("PhoneCallReceiver", "string: " + string);
        if (!string.equals(TelephonyManager.EXTRA_STATE_IDLE)) {
            if (string.equals(TelephonyManager.EXTRA_STATE_OFFHOOK)) {
                i = 2;
                if (string2 == null) {
                    string2 = intent.getExtras().getString(Intent.EXTRA_PHONE_NUMBER);
                    if (string2 == null) {
                        string2 = intent.getStringExtra(Intent.EXTRA_PHONE_NUMBER);
                    }
                }

                if (savedNumber == null && string2 != null) {
                    savedNumber = string2;
                }
            } else if (string.equals(TelephonyManager.EXTRA_STATE_RINGING)) {
                i = 1;
            }
        }
        if ((string2 != null && !string2.isEmpty()) || (i != 1 && i != 2)) {
            onCallStateChanged(context, i, string2);
        }

    }

    public void onCallStateChanged(Context context, int i, String str) {
        //Log.d("PhoneCallReceiver", "onCallStateChanged: " + lastState + " " + i + " " + str);
        int i2 = lastState;
        if (i2 == i) {
            return;
        }
        if (i == 0) {
            if (i2 == 1) {
                onMissedCall(context, savedNumber, callStartTime);
            } else if (isIncoming) {
                onIncomingCallEnded(context, savedNumber, callStartTime, new Date());
            } else {
                onOutgoingCallEnded(context, savedNumber, callStartTime, new Date());
                isOutgoingCallPinged = false;
            }
            savedNumber = null;
        } else if (i == 1) {
            isIncoming = true;
            callStartTime = new Date();
            savedNumber = str;
            onIncomingCallReceived(context, str, callStartTime);
        } else if (i == 2) {
            if (i2 != 1) {
                isIncoming = false;
                callStartTime = new Date();
                if (savedNumber == null) {
                    savedNumber = EnvironmentCompat.MEDIA_UNKNOWN;
                }
                Log.d("PhoneCallReceiver", "onOutgoingCallStarted savedNumber number: " + savedNumber);
                onOutgoingCallStarted(context, savedNumber, callStartTime);
                isOutgoingCallPinged = true;
            } else {
                isIncoming = true;
                callStartTime = new Date();
                onIncomingCallAnswered(context, savedNumber, callStartTime);
            }
        }
        lastState = i;
    }

    private void onIncomingCallAnswered(Context context, String savedNumber, Date callStartTime) {
        call_state = 3;
    }

    private void onOutgoingCallEnded(Context context, String savedNumber, Date callStartTime, Date date) {
        call_state = 1;
        CallRecorderService.mStopRecordingExternal = true;
    }

    private void onIncomingCallReceived(Context context, String str, Date callStartTime) {
        call_state = 2;
        if (str == null) {
            str = EnvironmentCompat.MEDIA_UNKNOWN;
        }
        Intent intent = new Intent(context, CallRecorderService.class);
        Log.d("PhoneCallReceiver", "str number: " + str);
        intent.putExtra("number", str);
        //intent.putExtra(AppMeasurementSdk.ConditionalUserProperty.NAME, contactName);
        //intent.putExtra("picuri", picURI);
        intent.putExtra("type", 1);
        if (Build.VERSION.SDK_INT >= 26) {
            context.startForegroundService(intent);
        } else {
            context.startService(intent);
        }
    }

    private void onIncomingCallEnded(Context context, String savedNumber, Date callStartTime, Date date) {
        call_state = 1;
        CallRecorderService.mStopRecordingExternal = true;
    }

    private void onMissedCall(Context context, String savedNumber, Date callStartTime) {
        call_state = 1;
        CallRecorderService.mStopRecordingExternal = true;
    }

    private void onOutgoingCallStarted(Context context, String str, Date callStartTime) {
        call_state = 3;
        SharedPreferences defaultSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        //if (defaultSharedPreferences.getBoolean("record_preference", true) && str != null && str.length() > 1) {
            /*String contactName = CallUtils.getContactName(context, str);
            String picURI = CallUtils.getPicURI(context, str);
            if (defaultSharedPreferences.getBoolean("record_contacts_only_prefs", false) && (contactName == null || contactName.length() == 0)) {
                return;
            }*/
        Intent intent = new Intent(context, CallRecorderService.class);
        Log.d("PhoneCallReceiver", "str number: " + str);
        intent.putExtra("number", str);
        //intent.putExtra(AppMeasurementSdk.ConditionalUserProperty.NAME, contactName);
        //intent.putExtra("picuri", picURI);
        intent.putExtra("type", 2);
        if (Build.VERSION.SDK_INT >= 26) {
            context.startForegroundService(intent);
        } else {
            context.startService(intent);
        }
        //}
    }
}
