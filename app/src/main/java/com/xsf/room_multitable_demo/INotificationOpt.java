package com.xsf.room_multitable_demo;

/**
 * Created by feng on 18-11-19.
 */

public interface INotificationOpt {

    void notify(int id);

    void cancel(int id);

    void cancelAll();

}
