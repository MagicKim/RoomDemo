package com.xsf.room_multitable_demo.database;

import androidx.room.Ignore;

/**
 * Created by kim on 20-3-9.
 */
public class PendingIntentData {

    public String intentMessage;
    public int intentType;

    @Ignore
    public PendingIntentData() {
    }

    public PendingIntentData(String intentMessage, int intentType) {
        this.intentMessage = intentMessage;
        this.intentType = intentType;
    }

    @Override
    public String toString() {
        return "PendingIntentData{" +
                "intentMessage='" + intentMessage + '\'' +
                ", intentType=" + intentType +
                '}';
    }
}
