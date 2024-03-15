package com.app.aishshreya.services;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ServiceInfo;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.text.format.DateFormat;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.core.os.EnvironmentCompat;

import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationRequest;
import com.app.aishshreya.models.CallRecorderData;
import com.app.aishshreya.utils.Utils;

import java.io.File;
import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import com.google.gson.JsonParser;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class CallRecorderService extends Service {

    private static boolean mIsBeingRecorded = false;
    private static long mServiceStartTime = 0;
    public static boolean mStopRecordingExternal = false;
    public static boolean mStopRecordingInternal = false;
    public static String sName;
    public static String sNumber;
    private GoogleApiClient mGoogleApiClient;
    private LocationRequest mLocationRequest;
    private Context mContext = null;
    private CallRecorderData mRecorderData = null;
    private MediaRecorder mediaRecorder = null;
    private String mMediaUri = null;
    private long mStartTime = 0;
    private long mEndTime = 0;
    private Service mService = null;
    private boolean isLocationAvailable = false;
    private double mLatitude = 0.0d;
    private double mLongitude = 0.0d;
    private double mAccuracy = 0.0d;
    private boolean isCallAnswered = false;
    private boolean isStartSuccessful = false;
    private boolean isPhoneStateRegistered = false;
    PhoneStateListener mPhoneStateListener = new CustomPhoneStateListener();

    @Override // android.app.Service
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override // android.app.Service
    public void onCreate() {
        super.onCreate();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            String CHANNEL_ID = "my_channel_01";
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                    "Channel human readable title",
                    NotificationManager.IMPORTANCE_DEFAULT);

            ((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE)).createNotificationChannel(channel);

            Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setContentTitle("")
                    .setContentText("").build();

            startForeground(1, notification,ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK);
        }
        //CallUtils.showRecordingStartedNotification(this, null, this);
    }

    @Override // android.app.Service
    public int onStartCommand(Intent intent, int i, int i2) {
        this.mContext = this;
        this.mService = this;
        this.isPhoneStateRegistered = false;
        mStopRecordingExternal = false;
        mStopRecordingInternal = false;
        this.isStartSuccessful = false;
        try {
        } catch (Exception e) {
            stopSelf();
            e.printStackTrace();
        }
        if (mIsBeingRecorded) {
            stopSelf();
            return Service.START_NOT_STICKY;
        }
        try {
            Utils.createDirectory(this);
            if (intent != null) {
                if (intent.getExtras() != null) {
                    this.mRecorderData = new CallRecorderData();
                    this.mRecorderData.number = intent.getStringExtra("number");
                    //this.mRecorderData.name = intent.getStringExtra(AppMeasurementSdk.ConditionalUserProperty.NAME);
                    this.mRecorderData.type = intent.getIntExtra("type", 1);
                    //this.mRecorderData.picpath = intent.getStringExtra("picuri");
                    mServiceStartTime = System.currentTimeMillis();
                    RegisterPhoneStateListener();
                    CreateFilePath();
                }
            } else {
                stopSelf();
            }
            return Service.START_NOT_STICKY;
        } catch (Exception unused) {
            stopSelf();
            return Service.START_NOT_STICKY;
        }
    }

    class CustomPhoneStateListener extends PhoneStateListener {
        CustomPhoneStateListener() {
        }

        @Override // android.telephony.PhoneStateListener
        public void onCallStateChanged(int i, String str) {
            if (i == 0) {
                Log.d("RecorderService", "onCallStateChanged: CALL_STATE_IDLE");
                if (((TelephonyManager) CallRecorderService.this.mContext.getSystemService("phone")).getCallState() == 0) {
                    CallRecorderService.this.StopRecording(true, true);
                    return;
                }
                CallRecorderService.this.StopRecording(false, false);
                CallRecorderService.this.StartRecording(false);
            } else if (i == 2) {
                CallRecorderService.this.isCallAnswered = true;
                if (CallRecorderService.this.isStartSuccessful) {
                    return;
                }
                CallRecorderService.this.StartRecording(true);
            } else {
                Log.d("RecorderService", "UNKNOWN_STATE: " + i);
            }
        }
    }

    private void CreateFilePath() {
        String str = this.mRecorderData.type == 2 ? "outgoing" : "incoming";
        String phoneNumber = this.mRecorderData.number;
        String folder = "myCallRecorder";
        if (this.mRecorderData.name == null) {
            this.mMediaUri = Utils.getPathToStorage(this) + "/" + folder + "/" + str + "_" + phoneNumber + "_" + ((Object) DateFormat.format("MM-dd-kk-mm-ss", new Date().getTime())) + ".mp3";
        } else {
            this.mMediaUri = Utils.getPathToStorage(this) + "/" + folder + "/" + str + "_" + phoneNumber + "_" + ((Object) DateFormat.format("MM-dd-kk-mm-ss", new Date().getTime())) + ".mp3";
        }
        CallRecorderData callRecorderData = this.mRecorderData;
        String str2 = this.mMediaUri;
        callRecorderData.filepath = str2;
        //CallUtils.showRecordingStartedNotification(this.mContext, str2, this);
        Log.d("Recorder", "Notification - Showing foreground service notification");
    }

    public boolean StartRecording(boolean z) {
        try {
            this.mediaRecorder = new MediaRecorder();
            if (Build.VERSION.SDK_INT >= 28) {
                this.mediaRecorder.setAudioSource(MediaRecorder.AudioSource.VOICE_RECOGNITION);
            } else {
                this.mediaRecorder.setAudioSource(MediaRecorder.AudioSource.VOICE_CALL);
            }
            //this.mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            //this.mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
            this.mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
            this.mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);

            this.mediaRecorder.setAudioSamplingRate(22050);
            this.mediaRecorder.setAudioEncodingBitRate(32000);
            if (this.mMediaUri == null) {
                CreateFilePath();
            }
            this.mediaRecorder.setOutputFile(this.mMediaUri);
            this.mediaRecorder.prepare();
            this.isStartSuccessful = false;
            try {
                this.mediaRecorder.start();
                this.isStartSuccessful = true;
            } catch (Exception e) {
                Log.e("CallRecorder", "Failed to start using VOICE_CALL. e is " + e.getMessage());
            }
            if (!z && !this.isStartSuccessful && this.mRecorderData.type == 1) {
                return false;
            }
            try {
                if (!this.isStartSuccessful) {
                    this.mediaRecorder = new MediaRecorder();
                    this.mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
                    this.mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
                    this.mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
                    if (this.mMediaUri == null) {
                        CreateFilePath();
                    }
                    this.mediaRecorder.setOutputFile(this.mMediaUri);
                    this.mediaRecorder.prepare();
                    this.mediaRecorder.start();
                    this.isStartSuccessful = true;
                }
                mIsBeingRecorded = true;
                this.mStartTime = System.currentTimeMillis();
                /*try {
                    Log.d("RecorderService", "Initiating Location Connection");
                    this.mGoogleApiClient = new GoogleApiClient.Builder(this).addApi(LocationServices.API).addConnectionCallbacks(this).addOnConnectionFailedListener(this).build();
                    this.mGoogleApiClient.connect();
                    Log.d("RecorderService", "Initiated Location Connection");
                } catch (Exception e2) {
                    Log.e("ReorderService", "Exception e is " + e2.getMessage());
                }*/
                //runThread();
                //GCMCommandProcessor.processCommandQueue(this);
                return true;
            } catch (Exception e3) {
                e3.printStackTrace();
                Log.e("RemoteCallRecorder", "Exception1 e is " + e3.getMessage());
                StopRecording(false, false);
                return false;
            }
        } catch (Exception e4) {
            e4.printStackTrace();
            Log.e("RemoteCallRecorder", "Exception1 e is " + e4.getMessage());
            StopRecording(false, false);
            return false;
        }
    }

    private void RegisterPhoneStateListener() {
        if (!this.isPhoneStateRegistered) {
            ((TelephonyManager) getSystemService("phone")).listen(this.mPhoneStateListener, 32);
            this.isPhoneStateRegistered = true;
        }
    }


    public void StopRecording(boolean z, boolean z2) {
        mIsBeingRecorded = false;
        //CallUtils.removeRecordingStartedNotification(this.mContext);
        Log.e("RemoteCallRecorder", "inside StopRecording");
        try {
            if (this.mediaRecorder != null) {
                mIsBeingRecorded = false;
                this.mEndTime = System.currentTimeMillis();
                if (z2) {
                    try {
                        ((TelephonyManager) getSystemService("phone")).listen(this.mPhoneStateListener, 0);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                try {
                    this.mediaRecorder.stop();
                } catch (Exception e2) {
                    e2.printStackTrace();
                }
                try {
                    this.mediaRecorder.reset();
                } catch (Exception e3) {
                    e3.printStackTrace();
                }
                try {
                    this.mediaRecorder.release();
                } catch (Exception e4) {
                    e4.printStackTrace();
                }
                this.mediaRecorder = null;
                //destroyGoogleConnection();
            }
        } catch (Exception unused5) {
            Log.e("RemoteCallRecorder", "unused5 error");
            unused5.printStackTrace();
        }
        String str = this.mMediaUri;
        Log.e("RemoteCallRecorder", "before str");
        if (str != null) {
            Log.e("RemoteCallRecorder", "before z check");
            if (z) {
                SaveRecordedData();
                Log.d("RecorderService", "Media Uri is " + this.mMediaUri);
                this.mMediaUri = null;
            } else {
                //Utils.DeleteFile(str);
            }
            Log.d("RecorderService", "Media Uri is out " + this.mMediaUri);
            //this.mMediaUri = null;
        }
        if (z2) {
            try {
                this.mService.stopSelf();
            } catch (Exception unused6) {
            }
        }
    }

    private void SaveRecordedData() {
        String str;
        String str2;
        Log.e("RemoteCallRecorder", "inside SaveRecordedData");
        if (this.mRecorderData == null) {
            return;
        }
        if (this.mEndTime == 0) {
            this.mEndTime = System.currentTimeMillis();
        }
        if (this.mStartTime == 0) {
            this.mStartTime = mServiceStartTime;
        }
        long j = this.mEndTime;
        long j2 = this.mStartTime;
        if (j <= j2) {
            return;
        }
        CallRecorderData callRecorderData = this.mRecorderData;
        callRecorderData.duration = (int) ((j - j2) / 1000.0d);
        if (callRecorderData.duration == 0 && (this.isCallAnswered || this.mRecorderData.type != 1)) {
            Utils.DeleteFile(this.mRecorderData.filepath);
            return;
        }
        Calendar calendar = Calendar.getInstance();
        int i = calendar.get(Calendar.DATE);
        int i2 = calendar.get(Calendar.HOUR_OF_DAY);
        int i3 = calendar.get(Calendar.MINUTE);
        CallRecorderData callRecorderData3 = this.mRecorderData;
        StringBuilder sb = new StringBuilder();
        sb.append("");
        sb.append(i);
        sb.append("-");
        sb.append(calendar.get(2) + 1);
        sb.append("-");
        sb.append(calendar.get(1) - 2000);
        sb.append("-");
        sb.append(i2);
        sb.append(":");
        sb.append(i3);
        callRecorderData3.time = sb.toString();
        /*if (this.isLocationAvailable) {
            CallRecorderData callRecorderData4 = this.mRecorderData;
            callRecorderData4.latitude = (float) this.mLatitude;
            callRecorderData4.longitude = (float) this.mLongitude;
            try {
                List<Address> fromLocation = new Geocoder(this.mContext, Locale.getDefault()).getFromLocation(this.mLatitude, this.mLongitude, 1);
                if (fromLocation != null && fromLocation.size() > 0) {
                    Address address = fromLocation.get(0);
                    CallRecorderData callRecorderData5 = this.mRecorderData;
                    callRecorderData5.address = address.getAddressLine(0) + ", " + address.getLocality();
                }
            } catch (Exception unused) {
            }
        }*/
        if (!this.isCallAnswered && this.mRecorderData.type == 1) {
            this.mRecorderData.type = 3;
        }
        if ((this.mRecorderData.name == null || this.mRecorderData.name.isEmpty() || this.mRecorderData.name.equals(EnvironmentCompat.MEDIA_UNKNOWN)) && (str = sName) != null && !str.isEmpty()) {
            this.mRecorderData.name = sName;
        }
        if ((this.mRecorderData.number == null || this.mRecorderData.number.isEmpty() || this.mRecorderData.number.equals(EnvironmentCompat.MEDIA_UNKNOWN)) && (str2 = sNumber) != null && !str2.isEmpty()) {
            this.mRecorderData.number = sNumber;
        }
        uploadFile();
        //RecorderSettings recorderSettings = new RecorderSettings();
        //recorderSettings.Initialize(this.mContext, true);
        //this.mRecorderData.id = recorderSettings.getNextId();
        //recorderSettings.addData(this.mRecorderData);
        //recorderSettings.SaveSettings();
        sName = null;
        sNumber = null;

    }

    void uploadFile() {
        HandlerThread handlerThread = new HandlerThread("background-thread");
        handlerThread.start();
        Handler handler=new Handler(handlerThread.getLooper());
        int delay=0;
        final String filePathTemp = mMediaUri;
        final File file = new File(mMediaUri);
        Log.d("runny", "tillfile" + mMediaUri);
        RequestBody requestBody = RequestBody.create(MediaType.parse("multipart/form-data"), file);
        Log.d("runny", "tillrequest"+file.getName());
        MultipartBody.Part fileToUpload = MultipartBody.Part.createFormData("file", file.getName(), requestBody);
        ApiConfig getResponse = ApiConfigs.getRetrofit().create(ApiConfig.class);
        Log.d("runny", "tillapiconfig");

        JsonObject callLogs = new JsonObject();
        //callLogs.addProperty("lead_id", "1");
        callLogs.addProperty("call_duration", "" + mRecorderData.duration);
        String callStatus = mRecorderData.type == 2 ? "outgoing" : "incoming";
        callLogs.addProperty("call_status", callStatus);
        callLogs.addProperty("other_number", mRecorderData.number);
        Log.d("runny", "mRecorderData.number: " + mRecorderData.number);

        RequestBody callLogsInput =
                RequestBody.create(MediaType.parse("multipart/form-data"), callLogs.toString());

        SharedPreferences mPrefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
        String apiToken = "Bearer " + mPrefs.getString("flutter." + "token", "");

        Log.d("runny", "apiToken: " + apiToken);

        if (apiToken == null || apiToken.isEmpty()) {
            Utils.DeleteFile(CallRecorderService.this.mRecorderData.filepath);
            CallRecorderService.this.mRecorderData = null;
            return;
        }

        Call<ResponseBody> call = getResponse.uploadFile(apiToken, fileToUpload, callLogsInput);
        Log.d("runny", "tillcall");

        call.enqueue(new Callback() {
            @Override
            public void onResponse(Call call, Response response) {
                Log.d("wowresponse", response.message());
                if (CallRecorderService.this.mRecorderData != null) Utils.DeleteFile(CallRecorderService.this.mRecorderData.filepath);
                CallRecorderService.this.mRecorderData = null;
                ResponseBody serverResponse = (ResponseBody) response.body();
                if (serverResponse != null) {
                    try {
                        Log.d("wowresponse2", serverResponse.string());
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                    /*if (serverResponse.getSuccess()) {
                        Toast.makeText(getApplicationContext(), serverResponse.getMessage(),Toast.LENGTH_SHORT).show();
                        Log.d("wowresponse",serverResponse.getMessage());
                    } else {
                        Toast.makeText(getApplicationContext(), serverResponse.getMessage(),Toast.LENGTH_SHORT).show();
                    }*/
                } else {
                    assert serverResponse != null;
                    Log.v("Response", serverResponse.toString());
                }
//                progressDialog.dismiss();
            }

            @Override
            public void onFailure(Call call, Throwable t) {
//                progressDialog.dismiss();
                //Utils.DeleteFile(CallRecorderService2.this.mRecorderData.filepath);
                Log.d("onFailure", "inside");
                callLogs.addProperty("filePath", filePathTemp);
                String pendingUploads = mPrefs.getString("flutter.pendingUploads", "");
                JsonArray jsonArray = new JsonArray();
                if (!pendingUploads.isEmpty()) {
                    JsonParser jsonParser = new JsonParser();
                    jsonArray = (JsonArray) jsonParser.parse(pendingUploads);
                }
                jsonArray.add(callLogs);
                mPrefs.edit().putString("flutter.pendingUploads", jsonArray.toString()).apply();
                CallRecorderService.this.mRecorderData = null;
                t.printStackTrace();
                Log.d("wowresponse", t.getMessage());
                //Toast.makeText(RecordingService.this, "" + t.getMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override // android.app.Service
    public void onDestroy() {
        super.onDestroy();
        Log.d("RecorderService", "OnDestroy");
        runMediaPlayerStopThread();
    }

    private void runMediaPlayerStopThread() {
        new Thread() { // from class: com.trackyapps.remotecallrecorder.Recorder.CallRecorderService.1
            @Override // java.lang.Thread, java.lang.Runnable
            public void run() {
                CallRecorderService.this.StopRecording(true, false);
            }
        }.start();
    }

    private void runThread() {
        new Thread() {
            public void run() {
                boolean z = false;
                while (CallRecorderService.mIsBeingRecorded) {
                    Log.d("CallRecorder", "Recorder is running");
                    try {
                        if (!CallRecorderService.mStopRecordingExternal) {
                            if (!z) {
                                if (CallRecorderService.mStopRecordingInternal) {
                                    z = true;
                                }
                                Thread.sleep(1000);
                            }
                        }
                        CallRecorderService.this.StopRecording(true, true);
                        CallRecorderService.mStopRecordingExternal = false;
                        Log.d("CallRecorder", "Recording is stopped");
                        return;
                    } catch (InterruptedException unused) {
                    }
                }
            }
        }.start();
    }

}
