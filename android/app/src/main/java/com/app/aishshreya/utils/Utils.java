package com.app.aishshreya.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import java.io.File;

public class Utils {

    public static void createDirectory(Context context) {
        try {
            SharedPreferences defaultSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
            File file = new File(getPathToStorage(context) + "/" + "myCallRecorder");
            if (file.exists()) {
                return;
            }
            file.mkdirs();
        } catch (Exception unused) {
        }
    }

    public static File getPathToStorage(Context context) {
        return context.getFilesDir();
    }

    public static void DeleteFile(String str) {
        try {
            File file = new File(str);
            if (!file.exists()) {
                return;
            }
            file.delete();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
