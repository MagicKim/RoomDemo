package com.xsf.room_multitable_demo.database;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import java.util.List;

/**
 * @author kim
 * @date 20-3-6
 */
@Dao
public interface NotificationRecordDao {
    // SELECT * FROM COMPANY ORDER BY NAME DESC;
    @Query("SELECT * FROM notification_table  ORDER BY timeStamp DESC LIMIT 99 ")
    List<NotificationRecord> getNotificationRecord();

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    public void insertNotificationRecord(NotificationRecord... notificationRecords);

    @Query("DELETE FROM notification_table WHERE parent_key = :key")
    public void deleteNotificationRecord(String key);

    @Query("DELETE FROM notification_table WHERE pkg = :key")
    public void deleteNotificationPkg(String key);

    @Query("Delete From notification_table")
    public void deleteAllNotificationRecord();

    @Query("SELECT * FROM (SELECT * FROM notification_table ORDER BY level DESC) ORDER BY timeStamp DESC LIMIT 99")
    List<NotificationRecord> getNotificationOrderList();



}
