package com.xsf.room_multitable_demo.database;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;
import androidx.room.migration.Migration;
import androidx.sqlite.db.SupportSQLiteDatabase;

/**
 *
 * @author kim
 * @date 20-3-6
 */
@Database(entities = {NotificationRecord.class}, version = 3, exportSchema = true)
@TypeConverters({NotificationEventConverter.class})
public abstract class NotificationDataBase extends RoomDatabase {

    public static final String DB_NAME = "NotificationDataBase.db";
    private static volatile NotificationDataBase instance;

    public static synchronized NotificationDataBase getInstance(Context context) {
        if (instance == null) {
            instance = create(context);
        }
        return instance;
    }

    private static NotificationDataBase create(final Context context) {
        return Room.databaseBuilder(
                context,
                NotificationDataBase.class,
                DB_NAME).allowMainThreadQueries().build();
    }

    public  void cleanUp(){
        instance = null;
    }

    public abstract NotificationRecordDao getNotificationRecordDao();

    //数据库升级方法
    static final Migration MIGRATION_1_2 = new Migration(1, 2) {
        @Override
        public void migrate(SupportSQLiteDatabase database) {
//            database.execSQL("CREATE TABLE `Fruit` (`id` INTEGER, "
//                    + "`name` TEXT, PRIMARY KEY(`id`))");
        }
    };

    static final Migration MIGRATION_2_3 = new Migration(2, 3) {
        @Override
        public void migrate(SupportSQLiteDatabase database) {
//            database.execSQL("ALTER TABLE Book "
//                    + " ADD COLUMN pub_year INTEGER");
        }
    };

}
