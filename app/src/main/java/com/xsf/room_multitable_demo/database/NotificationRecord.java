package com.xsf.room_multitable_demo.database;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Embedded;
import androidx.room.Entity;
import androidx.room.Index;
import androidx.room.PrimaryKey;

/**
 * @author kim
 * @date 20-3-6
 */
//indices = @Index(value = {"parent_key"},unique = true)
@Entity(tableName = "notification_table")
public class NotificationRecord {
    public int uid;
    @ColumnInfo(name = "parent_key")
    @PrimaryKey
    @NonNull
    public String key;
    public int notificationId;
    public String pkg;
    public String tag;
    public int userId;
    public long timeStamp;
    public int level;
    @Embedded
    public NotificationMessage notificationMessage;


    @Override
    public String toString() {
        return "NotificationRecord{" +
                "uid=" + uid +
                ", key='" + key + '\'' +
                ", notificationId=" + notificationId +
                ", pkg='" + pkg + '\'' +
                ", tag='" + tag + '\'' +
                ", userId=" + userId +
                ", timeStamp=" + timeStamp +
                ", level=" + level +
                ", notificationMessage=" + notificationMessage +
                '}';
    }
}

