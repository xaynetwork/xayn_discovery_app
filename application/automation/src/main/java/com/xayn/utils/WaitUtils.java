package com.xayn.utils;

import com.xayn.handlers.AppiumHandler;
import io.appium.java_client.MobileElement;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.*;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import static com.xayn.handlers.AppiumHandler.*;

import java.util.List;


@Log4j2
public class WaitUtils {

    private static final int TIMEOUT = 30;
    private static final int LONG_TIMEOUT = 180;
    private static final int SHORT_TIMEOUT = 5;
    private static WebDriverWait wait;

    private WaitUtils() {
    }

    private static WebDriverWait getInstance(int timeout) {
        return (WebDriverWait) new WebDriverWait(AppiumHandler.getDriver(), timeout, 50).ignoring(StaleElementReferenceException.class);
    }

    public static WaitUtils getWaitUtils() {
        wait = getInstance(TIMEOUT);
        return new WaitUtils();
    }

    public static WaitUtils getLongWaitUtils() {
        wait = getInstance(LONG_TIMEOUT);
        return new WaitUtils();
    }

    public static WaitUtils getShortWaitUtils() {
        wait = getInstance(SHORT_TIMEOUT);
        return new WaitUtils();
    }

    public static void threadSleep(int sleepTime) {
        try {
            Thread.sleep(sleepTime);
        } catch (InterruptedException ignored) {
            //ignored
        }
    }

    public void waitUntilElementAppear(MobileElement element) {
        try {
            Thread.sleep(1000);
        }
        catch (InterruptedException ignored) {

        }
        try {
            wait.until(ExpectedConditions.visibilityOf(element));
        } catch (StaleElementReferenceException | TimeoutException e) {
            throw new WebDriverException("The Element: " + element + " is not present");
        }
    }

    public void waitUntilElementsAppear(List <MobileElement> elements) {
            for (MobileElement el:elements) {
                try {
                    wait.until(ExpectedConditions.visibilityOf(el));
                }
                catch (StaleElementReferenceException | TimeoutException e) {
                    throw new WebDriverException("The Element: " + el + " is not present");
                }
            }
    }

    public void waitUntilElementAttributeIsChangedTo(MobileElement element, String attribute, String expectedValue) {
        try {
            wait.until(ExpectedConditions.attributeToBe(element, attribute, expectedValue));
        } catch (WebDriverException e) {
            log.error(e.getMessage());
            throw new WebDriverException("Expected attribute value is missing");
        }
    }

    public boolean isElementAttributeChangedTo(MobileElement element, String attribute, String expectedValue) {
        try {
            wait.until(ExpectedConditions.attributeToBe(element, attribute, expectedValue));
            return true;
        } catch (WebDriverException e) {
            log.error(e.getMessage());
        }
        return false;
    }

    public void waitUntilAppToBeReady() {
        new WebDriverWait(getDriver(), 1).until(new ExpectedCondition<Boolean>() {
            @Override
            public  Boolean apply( WebDriver webDriver) {
                try {
                    return getDriver().getPageSource() != null;
                } catch (Exception e) {
                    return false;
                }
            }
        });
    }

    public void waitUntilElementDisappear(MobileElement element) {
        wait.until(new ExpectedCondition<Boolean>() {
            @Override
            public  Boolean apply( WebDriver webDriver) {
                try {
                    return !element.isDisplayed();
                } catch (Exception e) {
                    return true;
                }
            }
        });
    }

    public void waitUntilElementDisappear(List<MobileElement> mobileElements, int index) {
        wait.until(new ExpectedCondition<Boolean>() {
            @Override
            public  Boolean apply( WebDriver webDriver) {
                try {
                    return !mobileElements.get(index).isDisplayed();
                } catch (Exception e) {
                    return true;
                }
            }
        });
    }

    public void waitUntilElementVisible(By by) {
        try {
            wait.until(ExpectedConditions.visibilityOfElementLocated(by));
        } catch (WebDriverException webDriverException) {
            throw new TimeoutException("Element is not visible");

        }
    }

    public void waitForTextToAppear(String textToAppear, MobileElement element) {
        wait.until(ExpectedConditions.textToBePresentInElement(element, textToAppear));
    }

    public void waitForTextToAppear(String textToAppear, List<MobileElement> elements, int index) {
        wait.until(ExpectedConditions.textToBePresentInElement(elements.get(index), textToAppear));
    }

    public MobileElement waitElementFromTheListToExist (List<MobileElement>list, int index) {
        return wait.until(XaynExpectedConditions.elementOfListToExist(list,index));
    }

}
