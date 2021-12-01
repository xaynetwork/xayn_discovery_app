package com.example.xayn_discovery_app;

import io.flutter.app.FlutterApplication;
import com.instabug.instabugflutter.InstabugFlutterPlugin;

import java.util.ArrayList;

public class CustomFlutterApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        ArrayList<String> invocation_events = new ArrayList<>();
        invocation_events.add(InstabugFlutterPlugin.INVOCATION_EVENT_NONE);
        InstabugFlutterPlugin instabug = new InstabugFlutterPlugin();
        instabug.start(CustomFlutterApplication.this, "c038ec6a25f5051abe27bf58310708dd", invocation_events);
        instabug.setWelcomeMessageMode("WelcomeMessageMode.disabled");
    }
}