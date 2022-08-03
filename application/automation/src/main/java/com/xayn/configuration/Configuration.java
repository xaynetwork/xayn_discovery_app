package com.xayn.configuration;

import lombok.extern.log4j.Log4j2;

import java.io.FileInputStream;
import java.io.IOException;
import static java.util.Objects.*;
import java.util.Properties;

@Log4j2
public class  Configuration {

    private static final Properties props = new Properties();
    public static final String IOS_DEVICE_ID;
    public static final String ANDROID_DEVICE_ID;
    public static final String SCREENSHOT_DIRECTORY;
    public static final String DRIVER_EXEC;
    public static final String APPIUM_URL;
    public static final String APPIUM_JS;
    public static final String WDA_BUNDLE_ID;
    public static final String XCODE_ORG_ID;
    public static final String APP_IOS;
    public static final String APP_ANDROID;
    public static final String ANDROID_VERSION;
    public static final String IOS_VERSION;
    public static final String IOS_DEVICE;
    public static final int RETRY_COUNT;

    public static final boolean IS_REGRESSION;
    public static final boolean IS_REMOTE;

    static {
        try (FileInputStream file = new FileInputStream("./src/main/resources/config.properties")) {
            props.load(file);
        } catch (IOException e) {
            log.error(e.getMessage());
        }
        IS_REMOTE = Boolean.parseBoolean(props.getProperty("remote"));
        SCREENSHOT_DIRECTORY = props.getProperty("screenshot.directory");
        DRIVER_EXEC = getEnvProperty("driver.exec");
        APPIUM_URL = getEnvProperty("appium.url");
        APPIUM_JS = getEnvProperty("appium.js");
        IOS_DEVICE_ID = getEnvProperty("ios.id");
        ANDROID_DEVICE_ID = getEnvProperty("android.id");
        APP_IOS = getEnvProperty("app.ios");
        APP_ANDROID = getEnvProperty("app.android");
        WDA_BUNDLE_ID = props.getProperty("wda.bundle.id");
        XCODE_ORG_ID = props.getProperty("xcode.id");
        IS_REGRESSION = Boolean.parseBoolean(props.getProperty("tms.regression"));
        ANDROID_VERSION = getEnvProperty("android.version");
        IOS_VERSION = getEnvProperty("ios.version");
        IOS_DEVICE = getEnvProperty("ios.device");
        RETRY_COUNT = Integer.parseInt(props.getProperty("retry.count"));
    }

    private Configuration() {
    }

    private static String getResource(String path) {
        return requireNonNull(Configuration.class.getResource(path)).getPath();
    }
    private static String getEnvProperty(String property) {
        String prefix = IS_REMOTE ? "remote." : "";
        return Configuration.props.getProperty(prefix + property);
    }

}
