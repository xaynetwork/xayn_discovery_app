package com.xayn.screens.base;

import com.xayn.constants.Directions;
import com.xayn.handlers.AppiumHandler;
import com.xayn.utils.WaitUtils;
import io.appium.java_client.MobileElement;
import io.appium.java_client.TouchAction;
import io.appium.java_client.pagefactory.AppiumFieldDecorator;
import io.appium.java_client.touch.WaitOptions;
import io.appium.java_client.touch.offset.PointOption;
import io.qameta.allure.Step;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.WebDriverException;
import org.openqa.selenium.support.PageFactory;
import org.openqa.selenium.support.ui.LoadableComponent;
import org.testng.Assert;

import java.time.Duration;
import java.util.List;

import static com.xayn.handlers.AppiumHandler.*;
import static com.xayn.utils.WaitUtils.getWaitUtils;

@Log4j2
public abstract class BaseScreen<T extends LoadableComponent<T>> extends LoadableComponent<T> {

    public abstract T open();

    @Override
    public T get() {
        try {
            return super.get();
        } catch (Exception e) {
            Assert.fail(this.getClass().getSimpleName() + " didn't open");
            return null;
        }
    }

    protected T openScreen() {
        PageFactory.initElements(new AppiumFieldDecorator(getDriver()), this);
        load();
        try {
            isLoaded();
        } catch (Exception e) {
            load();
        }
        return get();
    }

    @Step("clicking on {mobileElement}")
    protected void click(MobileElement mobileElement) {
        WaitUtils.getWaitUtils().waitUntilElementAppear(mobileElement);
        mobileElement.click();
    }

    @Step("clicking on {mobileElements}")
    protected void clickOnFirstAvailable(List <MobileElement> mobileElements) {
        try {
            click(mobileElements.get(0));
        } catch (WebDriverException exception) {
            log.warn(exception.fillInStackTrace());
            click(mobileElements.get(1));
        }
    }

    @Step("checking if {element} is displayed")
    protected boolean isElementDisplayed (MobileElement element) {
       return element.isDisplayed();
    }

    @Step("checking if {element} is enabled")
    protected boolean isElementEnabled (MobileElement element) {
        return element.isEnabled();
    }

    @Step("checking if {element} is selected")
    protected boolean isElementSelected (MobileElement element) {
        return element.isSelected();
    }

    @Step("getting text from {element}")
    protected String getText(MobileElement element) {
        getWaitUtils().waitUntilElementAppear(element);
        return element.getText();
    }

    @Step("checking by coordinates")
    public void clickByCoordinates(int xOffset, int yOffset) {
        TouchAction action = new TouchAction<>(AppiumHandler.getDriver());
        action.press(PointOption.point(xOffset, yOffset)).release().perform();
    }

    @Step("swiping screen")
    public void swipeScreen(Directions dir) {
        log.info("swipeScreen(): dir: '" + dir + "'");
        final int ANIMATION_TIME = 1000;
        final int PRESS_TIME = 200;
        int edgeBorder = 10;
        PointOption pointOptionStart, pointOptionEnd;
        Dimension dims = AppiumHandler.getDriver().manage().window().getSize();
        pointOptionStart = PointOption.point(dims.width / 2, dims.height / 2);

        switch (dir) {
            case DOWN:
                pointOptionEnd = PointOption.point(dims.width / 2, dims.height - edgeBorder);
                break;
            case UP:
                pointOptionEnd = PointOption.point(dims.width / 2, edgeBorder);
                break;
            case LEFT:
                pointOptionEnd = PointOption.point(edgeBorder, dims.height / 2);
                break;
            case RIGHT:
                pointOptionEnd = PointOption.point(dims.width - edgeBorder, dims.height / 2);
                break;
            default:
                throw new IllegalArgumentException("swipeScreen(): dir: '" + dir + "' NOT supported");
        }

        try {
            new TouchAction(AppiumHandler.getDriver())
                    .press(pointOptionStart)
                    .waitAction(WaitOptions.waitOptions(Duration.ofMillis(PRESS_TIME)))
                    .moveTo(pointOptionEnd)
                    .release().perform();
        } catch (Exception e) {
            System.err.println("swipeScreen(): TouchAction FAILED\n" + e.getMessage());
            return;
        }
        try {
            Thread.sleep(ANIMATION_TIME);
        } catch (InterruptedException e) {
        }
    }

    @Step("cleaning text in {element}")
    protected void cleanText(MobileElement element) {
        element.clear();
    }

    @Step("typing text into {element}")
    protected void type(MobileElement element, String value) {
        element.sendKeys(value);
    }
}