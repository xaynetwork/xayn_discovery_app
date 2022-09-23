package com.xayn.capabilities;


import org.openqa.selenium.remote.DesiredCapabilities;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

import static java.util.AbstractMap.SimpleEntry;


public class CapabilitiesBuilder {
    private SimpleEntry<String, String> platformName;
    private SimpleEntry<String, String> platformVersion;
    private SimpleEntry<String, String> deviceName;
    private SimpleEntry<String, String> automationName;
    private SimpleEntry<String, String> chromeDriverExec;
    private SimpleEntry<String, Integer> chromeDriverport;
    private SimpleEntry<String, Integer> webViewTimeout;
    private SimpleEntry<String, Boolean> webViewDetailsCollection;
    private SimpleEntry<String, String> app;
    private SimpleEntry<String, String> browser;

    private SimpleEntry<String, String> fullResetValue;
    private SimpleEntry<String, String> udid;
    //IOS
    private SimpleEntry<String, String> xcodeOrgId;
    private SimpleEntry<String, String> xcodeSigningId;
    private SimpleEntry<String, String> updatedWDABundleId;

    private SimpleEntry<String, Integer> wdaRetries;

    private SimpleEntry<String, Integer> wdaLaunchTimeout;

    private SimpleEntry<String, Integer> wdaConnectionTimeout;

    public CapabilitiesBuilder() {
    }

    ;

    public CapabilitiesBuilder setPlatformName(String platformName) {
        this.platformName = new SimpleEntry<>("platformName", platformName);
        return this;
    }

    public CapabilitiesBuilder setPlatformVersion(String platformVersion) {
        this.platformVersion = new SimpleEntry<>("platformVersion", platformVersion);
        return this;
    }

    public CapabilitiesBuilder setDeviceName(String deviceName) {
        this.deviceName = new SimpleEntry<>("deviceName", deviceName);
        return this;
    }

    public CapabilitiesBuilder setAutomationName(String automationName) {
        this.automationName = new SimpleEntry<>("automationName", automationName);
        return this;
    }

    public CapabilitiesBuilder setChromeDriverExec(String exec) {
        this.chromeDriverExec = new SimpleEntry<>("chromedriverExecutableDir", exec);
        return this;
    }

    public CapabilitiesBuilder setChromeDriverPort(int port) {
        this.chromeDriverport = new SimpleEntry<>("chromedriverPort", port);
        return this;
    }

    public CapabilitiesBuilder setWebViewTimeOut(int timeOut) {
        this.webViewTimeout = new SimpleEntry<>("autoWebviewTimeout", timeOut);
        return this;
    }

    public CapabilitiesBuilder setEnableWebviewDetailsCollection(boolean value) {
        this.webViewDetailsCollection = new SimpleEntry<>("enableWebviewDetailsCollection", value);
        return this;
    }

    public CapabilitiesBuilder setApp(String app) {
        this.app = new SimpleEntry<>("app", app);
        return this;
    }

    public CapabilitiesBuilder setBrowser(String browser) {
        this.browser = new SimpleEntry<>("browser", browser);
        return this;
    }

    public CapabilitiesBuilder setFullResetValue(boolean value) {
        this.fullResetValue = new SimpleEntry<>("fullReset", Boolean.toString(value));
        return this;
    }

    public CapabilitiesBuilder setWdaStartupRetries(int value) {
        this.wdaRetries = new SimpleEntry<>("wdaStartupRetries", value);
        return this;
    }

    public CapabilitiesBuilder setWdaLaunchTimeout(int value) {
        this.wdaLaunchTimeout = new SimpleEntry<>("wdaLaunchTimeout", value);
        return this;
    }

    public CapabilitiesBuilder setWdaConnectionTimeout(int value) {
        this.wdaConnectionTimeout = new SimpleEntry<>("wdaConnectionTimeout", value);
        return this;
    }

    public CapabilitiesBuilder setUdid(String udid) {
        this.udid = new SimpleEntry<>("udid", udid);
        return this;
    }

    public CapabilitiesBuilder setXcodeOrgId(String xcodeOrgId) {
        this.xcodeOrgId = new SimpleEntry<>("xcodeOrgId", xcodeOrgId);
        return this;
    }

    public CapabilitiesBuilder setXcodeSigningId(String xcodeSigningId) {
        this.xcodeSigningId = new SimpleEntry<>("xcodeSigningId", xcodeSigningId);
        return this;
    }

    public CapabilitiesBuilder setUpdatedWDABundleId(String updatedWDABundleId) {
        this.updatedWDABundleId = new SimpleEntry<>("updatedWDABundleId", updatedWDABundleId);
        return this;
    }

    public DesiredCapabilities build() throws IllegalAccessException {
        Map<String, String> caps = new HashMap<>();
        Field[] fields = CapabilitiesBuilder.class.getDeclaredFields();
        for (Field field : fields) {
            Object value = field.get(this);
            if (value != null) {
                SimpleEntry<String, ?> entry = (SimpleEntry) value;
                if (entry.getValue() == null) {
                    throw new RuntimeException("Declared field " +  entry.getKey() + ", is null!");
                }
                caps.put(entry.getKey(), entry.getValue().toString());
            }
        }
        return new DesiredCapabilities(caps);
    }
}