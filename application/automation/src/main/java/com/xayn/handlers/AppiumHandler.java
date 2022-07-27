package com.xayn.handlers;

import com.xayn.configuration.Configuration;
import com.xayn.constants.PlatformType;
import io.appium.java_client.AppiumDriver;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.AndroidElement;
import io.appium.java_client.ios.IOSDriver;
import io.appium.java_client.ios.IOSElement;
import lombok.Getter;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.remote.DesiredCapabilities;

import java.net.MalformedURLException;
import java.net.URL;

@Log4j2
public class AppiumHandler{

    @Getter
    private static AppiumDriver driver;

    public static void createDriver(PlatformType type, DesiredCapabilities capabilities) {
        try {
            driver = type.equals(PlatformType.ANDROID) ? initAndroidDriver(capabilities) : initIOSDriver(capabilities);
        } catch (MalformedURLException exception) {
            log.error(exception.getMessage());
        }
    }

    private static AndroidDriver<AndroidElement> initAndroidDriver(DesiredCapabilities capabilities) throws MalformedURLException {
        return new AndroidDriver(new URL(Configuration.APPIUM_URL), capabilities);
    }

    private static IOSDriver<IOSElement> initIOSDriver(DesiredCapabilities capabilities) throws MalformedURLException {
        return new IOSDriver(new URL(Configuration.APPIUM_URL), capabilities);
    }

    public static AndroidDriver getAndroidDriver () {
       return (AndroidDriver) driver;
    }

    public static IOSDriver getIosDriver () {
        return (IOSDriver) driver;
    }
}