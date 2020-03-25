package com.xsf.room_multitable_demo;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Build;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;


/**
 * Created by feng on 18-11-12.
 */

public class NotificationTestHelper implements INotificationOpt {

    private Context mContext;
    private String mTag = "NotificationTestHelper";
    private int mNotifyId = 100;
    private static final String TEST_BROADCAST = "com.ecarx.testbroadcast";
    private static final String TEST_SERVICE = "com.ecarx.testservice";

    private NotificationTestHelper(Context context) {
        mContext = context;
    }

    public static NotificationTestHelper newInstance(Context context) {
        return new NotificationTestHelper(context);
    }

    @Override
    public void notify(int id) {

    }

    public int notifyCompat() {
        mNotifyId++;
        NotificationManager manager = (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
        NotificationCompat.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            final String channelId = mNotifyId + "";
            final String channelName = "Channel" + mNotifyId;
            NotificationChannel channel = new NotificationChannel(channelId, channelName,
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.enableLights(true); //是否在桌面icon右上角展示小红点 channel
            channel.setLightColor(Color.GREEN); //小红点颜色 channel.setShowBadge(true); //是否在久按桌面图标时显示此渠道的通知
            manager.createNotificationChannel(channel);
            builder = new NotificationCompat.Builder(mContext, channelId);
        } else {
            builder = new NotificationCompat.Builder(mContext);
        }

        PendingIntent pendingIntent = PendingIntent.getActivity(mContext, 0, new Intent(mContext,
                        MainActivity.class),
                PendingIntent.FLAG_UPDATE_CURRENT);

        builder.setLargeIcon(BitmapFactory.decodeResource(mContext.getResources(), R.mipmap.ic_launcher))
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("《陈绮贞，沙发海，一些关于孤独的歌》")
                .setContentText("「在这样一个每个人都受伤的时代，她说、她唱、她写下你的歌。")
                .setWhen(System.currentTimeMillis())
                .setContentIntent(pendingIntent)
                .setDefaults(Notification.DEFAULT_SOUND)
                .build();
        NotificationManagerCompat.from(mContext).notify(mNotifyId, builder.build());
        return mNotifyId;
    }

    @Override
    public void cancel(int id) {

    }

    public int cancelCompat() {
        NotificationManagerCompat.from(mContext).cancel(mNotifyId);
        return mNotifyId;
    }

    public int cancel() {
        NotificationManager manager = (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
        manager.cancel(mNotifyId);
        return mNotifyId;
    }

    @Override
    public void cancelAll() {
        NotificationManager manager = (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
        manager.cancelAll();
    }

    public void cancelAllCompat() {
        NotificationManagerCompat.from(mContext).cancelAll();
    }

    public int notifyDefault() {
        mNotifyId++;
        NotificationManager manager = (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
        Notification.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            final String channelId = "NotificationCenter-Demo-ID";
            final String channelName = "NotificationCenter-Demo";
            NotificationChannel channel = new NotificationChannel(channelId, channelName,
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.enableLights(true); //是否在桌面icon右上角展示小红点 channel
            channel.setLightColor(Color.GREEN); //小红点颜色 channel.setShowBadge(true); //是否在久按桌面图标时显示此渠道的通知
            manager.createNotificationChannel(channel);
            builder = new Notification.Builder(mContext, channelId);
        } else {
            builder = new Notification.Builder(mContext);
        }

        PendingIntent pendingIntent = PendingIntent.getActivity(mContext, 0, new Intent(mContext,
                        MainActivity.class),
                PendingIntent.FLAG_UPDATE_CURRENT);
        builder.setLargeIcon(BitmapFactory.decodeResource(mContext.getResources(), R.mipmap.ic_launcher))
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("车贷逾期提醒")
                .setContentText("张先生，光大银行99000元贷款第6期还款已逾期5天，当前逾期金额5006元。请及时还款。")
                .setWhen(System.currentTimeMillis())
                .setContentIntent(pendingIntent)
                .setPriority(Notification.PRIORITY_MAX)
                .setDefaults(Notification.DEFAULT_SOUND)
                .build();

        manager.notify(mNotifyId, builder.build());
        return mNotifyId;
    }

    public Notification.Builder createBuilder(int notifyId) {
        Notification.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            final String channelId = notifyId + "";
            final String channelName = "Channel" + notifyId;
            NotificationChannel channel = new NotificationChannel(channelId, channelName,
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.enableLights(true); //是否在桌面icon右上角展示小红点 channel
            channel.setLightColor(Color.GREEN); //小红点颜色 channel.setShowBadge(true); //是否在久按桌面图标时显示此渠道的通知
            NotificationManager manager = (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
            manager.createNotificationChannel(channel);

            builder = new Notification.Builder(mContext, channelId);
        } else {
            builder = new Notification.Builder(mContext);
        }

        PendingIntent pendingIntent = PendingIntent.getActivity(mContext, 0, new Intent(mContext,
                        MainActivity.class),
                PendingIntent.FLAG_UPDATE_CURRENT);
        builder.setLargeIcon(BitmapFactory.decodeResource(mContext.getResources(), R.mipmap.ic_launcher))
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("买辣椒也用券新专辑旧岛看月亮")
                .setContentText("旧岛是我 月亮是你 呢喃的词句谁在听")
                .setWhen(System.currentTimeMillis())
                .setDefaults(Notification.DEFAULT_SOUND)
                .setContentIntent(pendingIntent);

        return builder;
    }

    public Notification.Builder createBuilder() {
        mNotifyId++;
        return createBuilder(mNotifyId);
    }

    public NotificationCompat.Builder createCompatBuilder() {
        mNotifyId++;
        return createCompatBuilder(mNotifyId);
    }

    public NotificationCompat.Builder createCompatBuilder(int notifyId) {
        NotificationCompat.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            final String channelId = notifyId + "";
            final String channelName = "Channel" + notifyId;
            NotificationChannel channel = new NotificationChannel(channelId, channelName,
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.enableLights(true); //是否在桌面icon右上角展示小红点 channel
            channel.setLightColor(Color.GREEN); //小红点颜色 channel.setShowBadge(true); //是否在久按桌面图标时显示此渠道的通知
            builder = new NotificationCompat.Builder(mContext, channelId);
        } else {
            builder = new NotificationCompat.Builder(mContext);
        }

        PendingIntent pendingIntent = PendingIntent.getActivity(mContext, 0, new Intent(mContext,
                        MainActivity.class),
                PendingIntent.FLAG_UPDATE_CURRENT);
        builder.setLargeIcon(BitmapFactory.decodeResource(mContext.getResources(), R.mipmap.ic_launcher))
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("雨中男孩全新单曲上架《Rainy Boy》")
                .setContentText("少郎豆蔻，相逢邂逅，叶舞花落，再沉醉入梦，对面饮酒，茶烟消愁，缠绵相拥在淋不湿的雨中。")
                .setWhen(System.currentTimeMillis())
                .setDefaults(Notification.DEFAULT_SOUND)
                .setContentIntent(pendingIntent);

        return builder;
    }

}
