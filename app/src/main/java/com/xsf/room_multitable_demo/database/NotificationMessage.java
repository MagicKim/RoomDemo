package com.xsf.room_multitable_demo.database;

import androidx.room.ColumnInfo;
import androidx.room.Embedded;
import androidx.room.Entity;
import androidx.room.ForeignKey;
import androidx.room.Index;
import androidx.room.PrimaryKey;

import java.util.List;

import static androidx.room.ForeignKey.CASCADE;

/**
 * @author kim
 * @date 20-3-6
 */
//@Entity(tableName = "notification_message_table",foreignKeys = @ForeignKey(entity= NotificationRecord.class,
//        parentColumns = "parent_key",childColumns = "child_key",onDelete = CASCADE),
//        indices = @Index(value = {"child_key"},unique = true))
public class NotificationMessage {
    public int priority;
    public String title;
    public String content;
    @Embedded
    public PendingIntentData pendingIntentData;
    public List<NotificationEvent> eventList;
}
