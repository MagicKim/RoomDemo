package com.xsf.room_multitable_demo.ui.main;

import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;

import com.xsf.room_multitable_demo.R;
import com.xsf.room_multitable_demo.database.NotificationDataBase;
import com.xsf.room_multitable_demo.database.NotificationEvent;
import com.xsf.room_multitable_demo.database.NotificationMessage;
import com.xsf.room_multitable_demo.database.NotificationRecord;
import com.xsf.room_multitable_demo.database.PendingIntentData;

import java.util.ArrayList;
import java.util.List;

/**
 * A placeholder fragment containing a simple view.
 */
public class PlaceholderFragment extends Fragment implements View.OnClickListener{

    private static final String ARG_SECTION_NUMBER = "section_number";

    private PageViewModel pageViewModel;

    private Handler handler;

    public static PlaceholderFragment newInstance(int index) {
        PlaceholderFragment fragment = new PlaceholderFragment();
        Bundle bundle = new Bundle();
        bundle.putInt(ARG_SECTION_NUMBER, index);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        HandlerThread handlerThread = new HandlerThread("room_thread");
        handlerThread.start();
        handler = new Handler(handlerThread.getLooper());
        pageViewModel = ViewModelProviders.of(this).get(PageViewModel.class);
        int index = 1;
        if (getArguments() != null) {
            index = getArguments().getInt(ARG_SECTION_NUMBER);
        }
        pageViewModel.setIndex(index);
    }

    @Override
    public View onCreateView(
            @NonNull LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_main, container, false);
        final TextView textView = root.findViewById(R.id.section_label);
        pageViewModel.getText().observe(getViewLifecycleOwner(), new Observer<String>() {
            @Override
            public void onChanged(@Nullable String s) {
                textView.setText(s);
            }
        });
        root.findViewById(R.id.button).setOnClickListener(this);
        root.findViewById(R.id.button2).setOnClickListener(this);
        root.findViewById(R.id.button3).setOnClickListener(this);
        root.findViewById(R.id.button4).setOnClickListener(this);
        root.findViewById(R.id.button5).setOnClickListener(this);
        return root;
    }

    @Override
    public void onResume() {
        super.onResume();


    }


    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.button:
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        addData();
                    }
                });
                break;
            case R.id.button2:
                Log.w("kim","点击");
                deleteOneData("asdfghjkliuuw2");
                break;
            case R.id.button3:
                deleteAllData();
                break;
            case R.id.button4:
                List<NotificationRecord> notificationRecord = NotificationDataBase.getInstance(getContext()).getNotificationRecordDao().getNotificationRecord();
                Log.w("kim","数量 = "+notificationRecord.size());
                break;
            case R.id.button5:
                NotificationDataBase.getInstance(getContext()).getNotificationRecordDao().deleteNotificationPkg("com.ecarx.weather");
                break;
        }
    }

    private void addData(){
        for (int i = 0; i < 10; i++) {
            NotificationRecord notificationRecord = new NotificationRecord();
            NotificationMessage notificationMessage = new NotificationMessage();
            notificationRecord.key = "asdfghjkliuuw" + i;
            notificationRecord.level = i;
            notificationRecord.notificationId = i;
            notificationRecord.pkg = "com.ecarx.news";
            notificationRecord.uid = 10000 + i;
            notificationRecord.timeStamp = 1557903094210L + i * 100;
            notificationRecord.userId = 100 + i;
            notificationMessage.content = "这是第" + i + "条数据内容";
            notificationMessage.title = "这是第" + i + "个标题";
            notificationMessage.pendingIntentData = new PendingIntentData("open activity intent",1);
            notificationMessage.priority = i;
            List<NotificationEvent>notificationEventList = new ArrayList<>();
            NotificationEvent notificationEvent = new NotificationEvent();
            notificationEvent.buttonContent = "这是第一个按钮的数据" + i;
            notificationEvent.pendingIntentData = new PendingIntentData("open service intent",2);

            NotificationEvent notificationEvent2 = new NotificationEvent();
            notificationEvent2.buttonContent = "这是第二个按钮的数据" + i;
            notificationEvent.pendingIntentData = new PendingIntentData("open broadcast receiver intent",3);

            notificationEventList.add(0,notificationEvent);
            notificationEventList.add(1,notificationEvent2);
            notificationMessage.eventList = notificationEventList;
            //-----------------------------------------------
            notificationRecord.notificationMessage = notificationMessage;
            NotificationDataBase.getInstance(getContext()).getNotificationRecordDao().insertNotificationRecord(notificationRecord);
        }

        for (int i = 0; i < 40; i++) {
            NotificationRecord notificationRecord = new NotificationRecord();
            NotificationMessage notificationMessage = new NotificationMessage();
            notificationRecord.key = "asdfghjkliuuz" + i;
            notificationRecord.level = i;
            notificationRecord.notificationId = i;
            notificationRecord.pkg = "com.ecarx.weather";
            notificationRecord.uid = 10000 + i;
            notificationRecord.timeStamp = 1557903091230L + i * 100;
            notificationRecord.userId = 100 + i;
            notificationMessage.content = "这是第" + i + "条数据内容";
            notificationMessage.title = "这是第" + i + "个标题";
            notificationMessage.pendingIntentData = new PendingIntentData("open activity intent",1);
            notificationMessage.priority = i;
            List<NotificationEvent>notificationEventList = new ArrayList<>();
            NotificationEvent notificationEvent = new NotificationEvent();
            notificationEvent.buttonContent = "这是第一个按钮的数据" + i;
            notificationEvent.pendingIntentData = new PendingIntentData("open service intent",2);

            NotificationEvent notificationEvent2 = new NotificationEvent();
            notificationEvent2.buttonContent = "这是第二个按钮的数据" + i;
            notificationEvent.pendingIntentData = new PendingIntentData("open broadcast receiver intent",3);

            notificationEventList.add(0,notificationEvent);
            notificationEventList.add(1,notificationEvent2);
            notificationMessage.eventList = notificationEventList;
            //-----------------------------------------------
            notificationRecord.notificationMessage = notificationMessage;
            NotificationDataBase.getInstance(getContext()).getNotificationRecordDao().insertNotificationRecord(notificationRecord);
        }
    }

    private void deleteOneData(String key){
        NotificationDataBase.getInstance(getContext()).getNotificationRecordDao().deleteNotificationRecord(key);
    }

    private void deleteAllData(){
        NotificationDataBase.getInstance(getContext()).getNotificationRecordDao().deleteAllNotificationRecord();
    }


}