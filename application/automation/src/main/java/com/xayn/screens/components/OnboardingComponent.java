package com.xayn.screens.components;

import com.xayn.screens.base.BaseComponent;
import com.xayn.utils.WaitUtils;
import io.appium.java_client.MobileElement;
import io.appium.java_client.pagefactory.AndroidFindBy;
import io.appium.java_client.pagefactory.iOSXCUITFindBy;
import lombok.extern.log4j.Log4j2;

@Log4j2
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
        try{
            WaitUtils.getShortWaitUtils().waitUntilElementAppear(gotItButton);
            click(gotItButton);
        }catch (Exception e) {
            log.warn("'Got It' button isn't displayed");
        }
    }
}
