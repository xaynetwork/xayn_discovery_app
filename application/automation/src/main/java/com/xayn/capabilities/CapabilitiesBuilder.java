package com.xayn.capabilities;


import org.openqa.selenium.remote.DesiredCapabilities;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

import static java.util.AbstractMap.SimpleEntry;


public class CapabilitiesBuilder {
    private Map<String, String> caps = new HashMap<>();
    public CapabilitiesBuilder setPlatformName(String platformName) {
        caps.put("platformName", platformName);
        return this;
    }

    public CapabilitiesBuilder setPlatformVersion(String platformVersion) {
        caps.put("platformVersion", platformVersion);
        return this;
    }

    public CapabilitiesBuilder setDeviceName(String deviceName) {
        caps.put("deviceName", deviceName);
        return this;
    }

    public CapabilitiesBuilder setAutomationName(String automationName) {
        caps.put("automationName", automationName);
        return this;
    }

    public CapabilitiesBuilder setChromeDriverExec(String exec) {
        caps.put("chromedriverExecutableDir", exec);
        return this;
    }

    public CapabilitiesBuilder setChromeDriverPort(int port) {
        caps.put("chromedriverPort", String.valueOf(port));
        return this;
    }

    public CapabilitiesBuilder setWebViewTimeOut(int timeOut) {
        caps.put("autoWebviewTimeout", String.valueOf(timeOut));
        return this;
    }

    public CapabilitiesBuilder setEnableWebviewDetailsCollection(boolean value) {
        caps.put("enableWebviewDetailsCollection", String.valueOf(value));
        return this;
    }

    public CapabilitiesBuilder setApp(String app) {
        caps.put("app", app);
        return this;
    }

    public CapabilitiesBuilder setBrowser(String browser) {
        caps.put("browser", browser);
        return this;
    }

    public CapabilitiesBuilder setFullResetValue(boolean value) {
        caps.put("fullReset", Boolean.toString(value));
        return this;
    }

    public CapabilitiesBuilder setWdaStartupRetries(int value) {
        caps.put("wdaStartupRetries", String.valueOf(value));
        return this;
    }

    public CapabilitiesBuilder setWdaLaunchTimeout(int value) {
        caps.put("wdaLaunchTimeout", String.valueOf(value));
        return this;
    }

    public CapabilitiesBuilder setWdaConnectionTimeout(int value) {
        caps.put("wdaConnectionTimeout", String.valueOf(value));
        return this;
    }

    public CapabilitiesBuilder setUdid(String udid) {
        caps.put("udid", udid);
        return this;
    }

    public CapabilitiesBuilder setXcodeOrgId(String xcodeOrgId) {
        caps.put("xcodeOrgId", xcodeOrgId);
        return this;
    }

    public CapabilitiesBuilder setXcodeSigningId(String xcodeSigningId) {
        caps.put("xcodeSigningId", xcodeSigningId);
        return this;
    }

    public CapabilitiesBuilder setUpdatedWDABundleId(String updatedWDABundleId) {
        caps.put("updatedWDABundleId", updatedWDABundleId);
        return this;
    }

    public DesiredCapabilities build() {
        for (Map.Entry<String, String> entry : caps.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();
            if (value == null) throw new RuntimeException(key + " value is null!");
        }
        return new DesiredCapabilities(caps);
    }
}
