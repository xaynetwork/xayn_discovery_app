package com.xayn.configuration;

import lombok.extern.log4j.Log4j2;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Objects;
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
    public static final boolean DEVICE_PERSONAL;
//    public static final String TESTRAIL_ENDPOINT;
//    public static final String TESTRAIL_USER;
//    public static final String TESTRAIL_PASSWORD;
    public static final String ANDROID_VERSION;
    public static final String IOS_VERSION;
    public static final String IOS_DEVICE;
    public static final int RETRY_COUNT;

    public static final boolean IS_REGRESSION;

    static {
        try (FileInputStream file = new FileInputStream("./src/main/resources/config.properties")) {
            props.load(file);
        } catch (IOException e) {
            log.error(e.getMessage());
        }
        SCREENSHOT_DIRECTORY = props.getProperty("screenshot.directory");
        DRIVER_EXEC = props.getProperty("driver.exec");
        APPIUM_URL = props.getProperty("appium.url");
        APPIUM_JS = props.getProperty("appium.js");
        DEVICE_PERSONAL = Boolean.parseBoolean(props.getProperty("device.personal"));
        IOS_DEVICE_ID = DEVICE_PERSONAL ? System.getenv("IOS_PERSONAL") : props.getProperty("ios.id");
        ANDROID_DEVICE_ID = DEVICE_PERSONAL ? System.getenv("ANDROID_PERSONAL") : props.getProperty("android.id");
        APP_IOS = getResource(props.getProperty("app.ios"));
        APP_ANDROID = getResource(props.getProperty("app.android"));
        WDA_BUNDLE_ID = props.getProperty("wda.bundle.id");
        XCODE_ORG_ID = System.getenv("XCODE_ORG_ID");
        IS_REGRESSION = Boolean.parseBoolean(props.getProperty("tms.regression"));
        ANDROID_VERSION = props.getProperty("android.version");
        IOS_VERSION = props.getProperty("ios.version");
        IOS_DEVICE = props.getProperty("ios.device");
        //todo enable for automatic regression results
//        TESTRAIL_ENDPOINT = System.getenv("TESTRAIL_ENDPOINT");
//        TESTRAIL_USER = System.getenv("TESTRAIL_USER");
//        TESTRAIL_PASSWORD = System.getenv("TESTRAIL_PASSWORD");
        RETRY_COUNT = Integer.parseInt(props.getProperty("retry.count"));
    }

    private Configuration() {
    }

    private static String getResource(String path) {
        return Objects.requireNonNull(Configuration.class.getResource(path)).getPath();
    }

}
