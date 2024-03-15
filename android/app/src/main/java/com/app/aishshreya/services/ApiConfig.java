package com.app.aishshreya.services;

import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.Header;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;

public interface ApiConfig {
    @Multipart
    @POST("add_call_log")
    Call<ResponseBody> uploadFile(@Header("Authorization") String token, @Part MultipartBody.Part file, @Part("callLog") RequestBody callLog);

}
