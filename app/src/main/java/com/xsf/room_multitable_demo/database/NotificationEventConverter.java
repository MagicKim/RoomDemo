package com.xsf.room_multitable_demo.database;

import androidx.room.TypeConverter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.util.List;

/**
 * Created by kim on 20-3-6.
 */
public class NotificationEventConverter {

    private static Gson mGson = new Gson();

    @TypeConverter
    public static List<NotificationEvent> revert(String eventString) {
        return mGson.fromJson(eventString, new TypeToken<List<NotificationEvent>>() {
        }.getType());
    }

    @TypeConverter
    public static String converter(List<NotificationEvent> eventString) {
        return mGson.toJson(eventString);
    }
}
