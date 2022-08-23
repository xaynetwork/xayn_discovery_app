package com.xayn.handlers;

import com.xayn.configuration.Configuration;
import io.appium.java_client.service.local.AppiumDriverLocalService;
import io.appium.java_client.service.local.AppiumServiceBuilder;
import lombok.extern.log4j.Log4j2;

import java.io.File;

@Log4j2
public class ServerHandler {
    static private AppiumDriverLocalService appiumDriverLocalService;

    public static void startLocalServer () {
        AppiumServiceBuilder serviceBuilder = new AppiumServiceBuilder();
        serviceBuilder
                .usingDriverExecutable(new File(Configuration.DRIVER_EXEC))
                .withAppiumJS(new File(Configuration.APPIUM_JS));
        appiumDriverLocalService = AppiumDriverLocalService.buildService(serviceBuilder);
        appiumDriverLocalService.start();
        log.info(appiumDriverLocalService.getStdOut());
    }

    public static void stopLocalServer () {
        appiumDriverLocalService.stop();
        log.info("appium server stopped..");
    }

    public static boolean isServerRunning () {
        return appiumDriverLocalService != null && appiumDriverLocalService.isRunning();
    }

}
