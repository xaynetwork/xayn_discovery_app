package com.xayn.capabilities;


import org.openqa.selenium.remote.DesiredCapabilities;

import java.lang.reflect.Field;
import java.util.AbstractMap;
import java.util.HashMap;
import java.util.Map;


public class CapabilitiesBuilder {
    private AbstractMap.SimpleEntry<String, String> platformName;
    private AbstractMap.SimpleEntry<String, String> platformVersion;
    private AbstractMap.SimpleEntry<String, String> deviceName;
    private AbstractMap.SimpleEntry<String, String> automationName;
    private AbstractMap.SimpleEntry<String,String>  chromeDriverExec;
    private AbstractMap.SimpleEntry<String,Integer> chromeDriverport;
    private AbstractMap.SimpleEntry<String,Integer> webViewTimeout;
    private AbstractMap.SimpleEntry<String,Boolean> webViewDetailsCollection;
    private AbstractMap.SimpleEntry<String,String> app;
    private AbstractMap.SimpleEntry<String,String> browser;

    private AbstractMap.SimpleEntry<String, String> fullResetValue;
    private AbstractMap.SimpleEntry<String, String> udid;
    //IOS
    private AbstractMap.SimpleEntry<String, String> xcodeOrgId;
    private AbstractMap.SimpleEntry<String, String> xcodeSigningId;
    private AbstractMap.SimpleEntry<String, String> updatedWDABundleId;

    public CapabilitiesBuilder() {
    }

    ;

    public CapabilitiesBuilder setPlatformName(String platformName) {
        this.platformName = new AbstractMap.SimpleEntry<>("platformName", platformName);
        return this;
    }

    public CapabilitiesBuilder setPlatformVersion(String platformVersion) {
        this.platformVersion = new AbstractMap.SimpleEntry<>("platformVersion", platformVersion);
        return this;
    }

    public CapabilitiesBuilder setDeviceName(String deviceName) {
        this.deviceName = new AbstractMap.SimpleEntry<>("deviceName", deviceName);
        return this;
    }

    public CapabilitiesBuilder setAutomationName(String automationName) {
        this.automationName = new AbstractMap.SimpleEntry<>("automationName", automationName);
        return this;
    }

    public CapabilitiesBuilder setChromeDriverExec(String exec) {
        this.chromeDriverExec = new AbstractMap.SimpleEntry<>("chromedriverExecutableDir", exec);
        return this;
    }

    public CapabilitiesBuilder setChromeDriverPort (int port) {
        this.chromeDriverport = new AbstractMap.SimpleEntry<>("chromedriverPort", port);
        return this;
    }

    public CapabilitiesBuilder setWebViewTimeOut (int timeOut) {
        this.webViewTimeout = new AbstractMap.SimpleEntry<>("autoWebviewTimeout", timeOut);
        return this;
    }

    public CapabilitiesBuilder setEnableWebviewDetailsCollection (boolean value) {
        this.webViewDetailsCollection = new AbstractMap.SimpleEntry<>("enableWebviewDetailsCollection", value);
        return this;
    }

    public CapabilitiesBuilder setApp(String app) {
        this.app = new AbstractMap.SimpleEntry<>("app", app);
        return this;
    }

    public CapabilitiesBuilder setBrowser(String browser) {
        this.browser = new AbstractMap.SimpleEntry<>("browser", browser);
        return this;
    }

    public CapabilitiesBuilder setFullResetValue(boolean value) {
        this.fullResetValue = new AbstractMap.SimpleEntry<>("fullReset", Boolean.toString(value));
        return this;
    }

    public CapabilitiesBuilder setUdid(String udid) {
        this.udid = new AbstractMap.SimpleEntry<>("udid", udid);
        return this;
    }

    public CapabilitiesBuilder setXcodeOrgId(String xcodeOrgId) {
        this.xcodeOrgId = new AbstractMap.SimpleEntry<>("xcodeOrgId", xcodeOrgId);
        return this;
    }

    public CapabilitiesBuilder setXcodeSigningId(String xcodeSigningId) {
        this.xcodeSigningId = new AbstractMap.SimpleEntry<>("xcodeSigningId", xcodeSigningId);
        return this;
    }

    public CapabilitiesBuilder setUpdatedWDABundleId(String updatedWDABundleId) {
        this.updatedWDABundleId = new AbstractMap.SimpleEntry<>("updatedWDABundleId", updatedWDABundleId);
        return this;
    }

    public DesiredCapabilities build() throws IllegalAccessException {
        Map<String, String> caps = new HashMap<>();
        Field[] fields = CapabilitiesBuilder.class.getDeclaredFields();
        for (Field field : fields) {
            Object value = field.get(this);
            if (value != null) {
                AbstractMap.SimpleEntry<String, String> entry = (AbstractMap.SimpleEntry) value;
                caps.put(entry.getKey(), entry.getValue());
            }
        }
        return new DesiredCapabilities(caps);

    }
}