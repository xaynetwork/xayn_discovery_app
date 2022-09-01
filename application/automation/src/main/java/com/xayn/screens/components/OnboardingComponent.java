package com.xayn.screens.components;

import com.xayn.screens.base.BaseComponent;
import io.appium.java_client.MobileElement;
import io.appium.java_client.pagefactory.AndroidFindBy;
import io.appium.java_client.pagefactory.iOSXCUITFindBy;

public class OnboardingComponent extends BaseComponent {

    @AndroidFindBy(accessibility = "Got it!")
    @iOSXCUITFindBy(accessibility = "Got it!")
    private MobileElement gotItButton;

    public OnboardingComponent open() {
        super.openScreen();
        return this;
    }

    @Override
    protected void load() {

    }

    @Override
    protected void isLoaded() throws Error {

    }

    public void gotItButtonClick() {
        click(gotItButton);
    }
}
