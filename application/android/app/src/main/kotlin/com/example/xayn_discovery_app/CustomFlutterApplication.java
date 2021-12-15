package com.example.xayn_discovery_app;

import io.flutter.app.FlutterApplication;
import com.instabug.instabugflutter.InstabugFlutterPlugin;
import com.example.xayn_discovery_app.BuildConfig;

import java.util.ArrayList;

public class CustomFlutterApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        ArrayList<String> invocation_events = new ArrayList<>();
        invocation_events.add(InstabugFlutterPlugin.INVOCATION_EVENT_NONE);
        InstabugFlutterPlugin instabug = new InstabugFlutterPlugin();
        instabug.start(CustomFlutterApplication.this, BuildConfig.INSTABUG_TOKEN, invocation_events);
        instabug.setWelcomeMessageMode("WelcomeMessageMode.disabled");
    }
}