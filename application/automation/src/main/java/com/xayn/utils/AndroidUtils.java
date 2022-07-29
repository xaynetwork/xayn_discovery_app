package com.xayn.utils;

import com.xayn.handlers.AppiumHandler;
import io.appium.java_client.android.nativekey.AndroidKey;
import io.appium.java_client.android.nativekey.KeyEvent;

public class AndroidUtils {

    public static void goBack() {
        pressKey(AndroidKey.BACK);
    }

    public static void enter() {
        pressKey(AndroidKey.ENTER);
    }

    public static void goForward() {
        pressKey(AndroidKey.FORWARD);
    }

    public static void pressKey(AndroidKey key) {
        AppiumHandler.getAndroidDriver().pressKey(new KeyEvent(key));
    }
}