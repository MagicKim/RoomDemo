package com.xsf.room_multitable_demo.database;

import androidx.room.Embedded;

/**
 * Created by  on 20-3-6.
 */
public class NotificationEvent {

    public String buttonContent;
    @Embedded
    public PendingIntentData pendingIntentData;

    @Override
    public String toString() {
        return "NotificationEvent{" +
                "buttonContent='" + buttonContent + '\'' +
                ", pendingIntentData=" + pendingIntentData +
                '}';
    }
}
