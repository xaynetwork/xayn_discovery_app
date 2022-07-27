package base;


import com.xayn.capabilities.CapabilitiesBuilder;
import com.xayn.constants.PlatformType;
import com.xayn.handlers.AppiumHandler;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.testng.annotations.BeforeMethod;

import java.lang.reflect.Method;
import java.util.concurrent.TimeUnit;

import static com.xayn.configuration.Configuration.*;
import static com.xayn.handlers.AppiumHandler.getDriver;

@Log4j2
public abstract class IOSTestBase extends TestBase {

    @BeforeMethod(alwaysRun = true)
    public void startDriver(Method method) throws IllegalAccessException {
        DesiredCapabilities desiredCapabilities = new CapabilitiesBuilder()
                .setPlatformName("iOS")
                .setPlatformVersion(IOS_VERSION)
                .setDeviceName(IOS_DEVICE)
                .setUdid(IOS_DEVICE_ID)
                .setAutomationName("XCUITest")
                .setXcodeOrgId(XCODE_ORG_ID)
                .setXcodeSigningId("Iphone Developer")
                .setUpdatedWDABundleId(WDA_BUNDLE_ID)
                .setFullResetValue(false)
                .setApp(APP_IOS)
                .build();
        AppiumHandler.createDriver(PlatformType.IOS, desiredCapabilities);
        getDriver().manage().timeouts().implicitlyWait(500, TimeUnit.MILLISECONDS);
    }
}
