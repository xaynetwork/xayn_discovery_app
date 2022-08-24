package base;

import com.xayn.configuration.Configuration;
import com.xayn.handlers.ServerHandler;
import com.xayn.utils.WaitUtils;
import io.appium.java_client.AppiumDriver;
import lombok.extern.log4j.Log4j2;
import org.testng.ITestContext;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeSuite;

import java.io.File;

import static com.xayn.handlers.AppiumHandler.getDriver;

@Log4j2
abstract class TestBase {

    @BeforeSuite(alwaysRun = true)
    public void beforeSuite(ITestContext context) {
        ServerHandler.startLocalServer();
        if (!ServerHandler.isServerRunning()) {
            throw new RuntimeException("An appium server isn't running");
        }
        new File(Configuration.SCREENSHOT_DIRECTORY).mkdir();
        WaitUtils.threadSleep(3000);
    }

    @AfterSuite(alwaysRun = true)
    public void afterSuite() {
        AppiumDriver driver = getDriver();
        if (driver != null) getDriver().closeApp();
        if (ServerHandler.isServerRunning()) {
            ServerHandler.stopLocalServer();
        } else {
            log.warn("Server stopped unexpectedly...");
        }
    }

}
