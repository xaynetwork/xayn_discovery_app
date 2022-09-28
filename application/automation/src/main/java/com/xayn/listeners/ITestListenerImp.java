package com.xayn.listeners;

import com.xayn.annotations.TestCase;
import com.xayn.configuration.Configuration;
import com.xayn.constants.TestStatus;
import com.xayn.handlers.AppiumHandler;
import com.xayn.handlers.TestRailHandler;
import io.qameta.allure.Attachment;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;

@Log4j2
public class ITestListenerImp implements ITestListener {

    @Override
    public void onStart(ITestContext context) {
        log.info("starting test : " + context.getName());
    }

    @Override
    public void onTestSuccess(ITestResult result) {
        log.info("test passed : " + result.getName());
        log.info("duration : " + (result.getEndMillis() - result.getStartMillis()) + " ms");
        if (Configuration.IS_REGRESSION) TestRailHandler.addResult(getTmsId(result), TestStatus.Passed);
    }

    @Override
    public void onTestFailure(ITestResult result) {
        log.warn("test failed : " + result.getName());
        log.info("duration : " + (result.getEndMillis() - result.getStartMillis()) + " ms");
        try {
            saveScreenshot(Configuration.ARTIFACTS_DIRECTORY + "/" + result.getName() + ".png");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        if (Configuration.IS_REGRESSION) TestRailHandler.addResult(getTmsId(result), TestStatus.Failed);
    }

    @Override
    public void onTestSkipped(ITestResult result) {
        if (Configuration.IS_REGRESSION) TestRailHandler.addResult(getTmsId(result), TestStatus.Retest);
    }

    @Attachment(type = "image/png", value = "screenshot during failure")
    public byte[] saveScreenshot(String path) throws IOException {
        byte[] scrFile = ((TakesScreenshot) AppiumHandler.getDriver()).getScreenshotAs(OutputType.BYTES);
        try (ByteArrayInputStream bis = new ByteArrayInputStream(scrFile);) {
            BufferedImage image = ImageIO.read(bis);
            ImageIO.write(image, "png", new File(path));
        } catch (IOException e) {
            e.printStackTrace();
        }
        return scrFile;
    }

    private int getTmsId(ITestResult result) {
        String methodName = result.getMethod().getMethodName();
        try {
            TestCase anno = result.getTestClass()
                    .getRealClass()
                    .getMethod(methodName, null)
                    .getAnnotation(TestCase.class);
            return anno.id();
        } catch (NoSuchMethodException e) {
            throw new RuntimeException(e);
        }
    }
}
