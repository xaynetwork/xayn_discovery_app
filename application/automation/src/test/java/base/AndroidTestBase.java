package base;

import com.xayn.capabilities.CapabilitiesBuilder;
import com.xayn.constants.PlatformType;
import io.appium.java_client.android.AndroidDriver;
import lombok.extern.log4j.Log4j2;
import org.apache.commons.codec.binary.Base64;
import org.openqa.selenium.logging.LogEntry;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.testng.ITestResult;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;

import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import static com.xayn.configuration.Configuration.*;
import static com.xayn.handlers.AppiumHandler.createDriver;
import static com.xayn.handlers.AppiumHandler.getDriver;

@Log4j2
public abstract class AndroidTestBase extends TestBase {

    @BeforeMethod(alwaysRun = true)
    public void onStart(Method method) {
        DesiredCapabilities desiredCapabilities = new CapabilitiesBuilder()
                .setPlatformName("Android")
                .setPlatformVersion(DEVICE_VERSION)
                .setDeviceName(DEVICE_ID)
                .setAutomationName("UiAutomator2")
                .setFullResetValue(false)
                .setApp(APP)
                .build();
        createDriver(PlatformType.ANDROID, desiredCapabilities);
        getDriver().manage().timeouts().implicitlyWait(5, TimeUnit.SECONDS);
    }

    @AfterMethod(alwaysRun = true)
    public void onFinish(ITestResult result) throws IOException {
        AndroidDriver driver = ((AndroidDriver<?>) getDriver());
        String path = ARTIFACTS_DIRECTORY + "/android/android_test_" + result.getMethod().getMethodName();
        Set availableLogTypes = driver.manage().logs().getAvailableLogTypes();
        if (availableLogTypes.contains("logcat")) {
            List<String> lines = driver.manage().logs().get("logcat").getAll().stream()
                    .map(LogEntry::toString).collect(Collectors.toList());
            Files.write(Paths.get(path + ".txt"), lines);
        }
        byte[] data = Base64.decodeBase64(((AndroidDriver<?>) getDriver()).stopRecordingScreen());
        path = path + ".mp4";
        try (OutputStream stream = Files.newOutputStream(
                Paths.get(path))) {
            stream.write(data);
            log.info("screen recording saved as " + path);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
