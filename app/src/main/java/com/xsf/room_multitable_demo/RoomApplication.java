package com.xsf.room_multitable_demo;

import android.app.Application;
import android.content.Context;

import com.xsf.room_multitable_demo.database.NotificationDataBase;

/**
 * Created by kim on 20-3-6.
 */
public class RoomApplication extends Application {
    private Context mContext;
    @Override
    public void onCreate() {
        super.onCreate();
        mContext = this;
        NotificationDataBase.getInstance(mContext);
    }

    // Room.databaseBuilder(getApplicationContext(), MyDb.class, "database-name")
    //            .addMigrations(MIGRATION_1_2, MIGRATION_2_3).build();
}
