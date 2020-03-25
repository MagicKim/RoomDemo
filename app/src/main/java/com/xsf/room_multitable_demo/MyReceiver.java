package com.xsf.room_multitable_demo;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

public class MyReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Intent i = new Intent(context, MyService.class);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //这是8.0以后的版本需要这样跳转
            Log.e("kim", "onReceive > = 8");
            context.startForegroundService(i);
        } else {
            Log.e("kim", "onReceive < 8");
            context.startService(i);
        }

    }
}
