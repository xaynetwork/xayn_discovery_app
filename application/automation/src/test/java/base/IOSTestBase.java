package base;


import com.xayn.capabilities.CapabilitiesBuilder;
import com.xayn.constants.PlatformType;
import com.xayn.handlers.AppiumHandler;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.ios.IOSDriver;
import lombok.extern.log4j.Log4j2;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.RandomStringUtils;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;

import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;

import static com.xayn.configuration.Configuration.*;
import static com.xayn.handlers.AppiumHandler.getDriver;

@Log4j2
public abstract class IOSTestBase extends TestBase {

    @BeforeMethod(alwaysRun = true)
    public void startDriver(Method method) throws IllegalAccessException {
        DesiredCapabilities desiredCapabilities = new CapabilitiesBuilder()
                .setPlatformName("iOS")
                .setPlatformVersion(DEVICE_VERSION)
                .setDeviceName(DEVICE_NAME)
                .setUdid(DEVICE_ID)
                .setAutomationName("XCUITest")
                .setXcodeOrgId(XCODE_ORG_ID)
                .setXcodeSigningId("Iphone Developer")
                .setUpdatedWDABundleId(WDA_BUNDLE_ID)
                .setFullResetValue(false)
                .setWdaStartupRetries(5)
                .setWdaConnectionTimeout(10*1000)
                .setWdaLaunchTimeout(180*1000)
                .setApp(APP)
                .build();
        AppiumHandler.createDriver(PlatformType.IOS, desiredCapabilities);
        getDriver().manage().timeouts().implicitlyWait(5, TimeUnit.SECONDS);
        ((IOSDriver<?>) getDriver()).startRecordingScreen();
    }

    @AfterMethod(alwaysRun = true)
    public void onFinish() {
        String path = ARTIFACTS_DIRECTORY + "/ios/ios_test_" + RandomStringUtils.randomAlphabetic(5);
        byte[] data = Base64.decodeBase64(((AndroidDriver<?>) getDriver()).stopRecordingScreen());
        try (OutputStream stream = Files.newOutputStream(
                Paths.get(path + ".mp4"))) {
            stream.write(data);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
