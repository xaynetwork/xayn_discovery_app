package com.xayn.utils;

import io.appium.java_client.MobileElement;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.ui.ExpectedCondition;

import javax.annotation.Nullable;
import java.util.List;

public class XaynExpectedConditions {

    private XaynExpectedConditions() {
    };

    public static ExpectedCondition<MobileElement> elementOfListToExist(List<MobileElement> list, int index) {
        return new ExpectedCondition<MobileElement>() {
            @Nullable
            @Override
            public MobileElement apply(@Nullable WebDriver webDriver) {
                try {
                    if (list.size() > index) {
                        return list.get(index);
                    }
                } catch (Exception e) {
                    return null;
                }
                return null;
            }
        };

    }
}
