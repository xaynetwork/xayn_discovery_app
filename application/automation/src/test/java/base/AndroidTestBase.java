package base;

import com.xayn.capabilities.CapabilitiesBuilder;
import com.xayn.constants.PlatformType;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.testng.annotations.BeforeMethod;

import java.lang.reflect.Method;
import java.util.concurrent.TimeUnit;

import static com.xayn.configuration.Configuration.*;
import static com.xayn.handlers.AppiumHandler.createDriver;
import static com.xayn.handlers.AppiumHandler.getDriver;

@Log4j2
public abstract class AndroidTestBase extends TestBase {

    @BeforeMethod(alwaysRun = true)
    public void startDriver(Method method) throws IllegalAccessException {
        DesiredCapabilities desiredCapabilities = new CapabilitiesBuilder()
                .setPlatformName("Android")
                .setPlatformVersion(DEVICE_VERSION)
                .setDeviceName(DEVICE_ID)
                .setAutomationName("UiAutomator2")
                .setFullResetValue(false)
                .setApp(APP)
                .build();
        createDriver(PlatformType.ANDROID, desiredCapabilities);
        getDriver().manage().timeouts().implicitlyWait(500, TimeUnit.MILLISECONDS);
    }

}
