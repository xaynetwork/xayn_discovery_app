package com.xayn.configuration;

import lombok.extern.log4j.Log4j2;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

import static java.util.Objects.requireNonNull;

@Log4j2
public class Configuration {

    private static final Properties props = new Properties();
    public static final String SCREENSHOT_DIRECTORY;
    public static final String DRIVER_EXEC;
    public static final String APPIUM_URL;
    public static final String APPIUM_JS;
    public static final String WDA_BUNDLE_ID;
    public static final String XCODE_ORG_ID;
    public static final String APP;
    public static final int RETRY_COUNT;
    public static final boolean IS_REGRESSION;

    //Platform specific params
    public static final String DEVICE_ID;
    public static final String DEVICE_VERSION;
    public static final String DEVICE_NAME;


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


        APP = props.getProperty("app");
        WDA_BUNDLE_ID = props.getProperty("wda.bundle.id");
        XCODE_ORG_ID = props.getProperty("xcode.id");
        IS_REGRESSION = Boolean.parseBoolean(props.getProperty("tms.regression"));


        RETRY_COUNT = Integer.parseInt(props.getProperty("retry.count"));
        DEVICE_ID = props.getProperty("device.id");
        DEVICE_VERSION = props.getProperty("device.version");
        DEVICE_NAME = props.getProperty("device.name");
    }

    private Configuration() {
    }

    private static String getResource(String path) {
        return requireNonNull(Configuration.class.getResource(path)).getPath();
    }

}
