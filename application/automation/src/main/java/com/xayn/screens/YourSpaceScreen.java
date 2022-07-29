package com.xayn.screens;

import com.xayn.handlers.AppiumHandler;
import com.xayn.screens.base.BaseScreen;
import com.xayn.screens.components.CreateNewCollectionComponent;
import com.xayn.utils.AndroidUtils;
import com.xayn.utils.WaitUtils;
import io.appium.java_client.MobileElement;
import io.appium.java_client.pagefactory.AndroidFindBy;
import io.appium.java_client.pagefactory.iOSXCUITFindBy;

import java.util.Arrays;
import java.util.List;

public class YourSpaceScreen extends BaseScreen {

    @AndroidFindBy(uiAutomator = "new UiSelector().descriptionContains(\"collection\")")
    @iOSXCUITFindBy(iOSNsPredicate = "label contains 'collection_item'")
    private List<MobileElement> collections;

    @AndroidFindBy(uiAutomator = "new UiSelector().descriptionContains(\"bookmark_item\")")
    @iOSXCUITFindBy(iOSNsPredicate = "label contains 'bookmark_item'")
    private List<MobileElement> bookmarkCollections;

    @AndroidFindBy(xpath = "//android.view.View[@content-desc=\"Your Space\"]")
    @iOSXCUITFindBy(accessibility = "Your Space")
    private MobileElement screenTitle;

    @AndroidFindBy(accessibility = "personal_area_icon_plus")
    @iOSXCUITFindBy(accessibility = "personal_area_icon_plus")
    private MobileElement iconPlusButton;

    @AndroidFindBy(accessibility = "personal_area_icon_settings")
    @iOSXCUITFindBy(accessibility = "personal_area_icon_settings")
    private MobileElement iconSettingsButton;

    @AndroidFindBy(xpath = "//android.view.View[@content-desc=\"Read later\"]")
    private MobileElement readLaterTitle;

    @AndroidFindBy(xpath = "//android.view.View[@content-desc=\"No Articles\"]")
    @iOSXCUITFindBy(accessibility = "No Articles")
    private MobileElement noArticlesHeader;

    @AndroidFindBy(accessibility = "Contact")
    @iOSXCUITFindBy(accessibility = "Contact")
    private MobileElement contactButton;

    @AndroidFindBy(accessibility = "The name can't exceed 20 characters")
    @iOSXCUITFindBy(accessibility = "The name can't exceed 20 characters")
    private MobileElement collectionNameExceed;

    @Override
    public YourSpaceScreen open() {
        super.openScreen();
        return this;
    }

    @Override
    protected void load() {
    }

    @Override
    protected void isLoaded() throws Error {
        WaitUtils.getWaitUtils().waitUntilElementsAppear(Arrays.asList(screenTitle,contactButton));
    }

    public YourSpaceScreen clickOnCollection(int index) {
        click(collections.get(index));
        return this;
    }

    public YourSpaceScreen clickOnSavedBookmark(int index) {
        click(bookmarkCollections.get(index));
        return this;
    }

    public boolean isNoArticlesHeaderDisplayed() {
        return noArticlesHeader.isDisplayed();
    }

    public boolean isReadLaterOpened() {
        return isElementDisplayed(readLaterTitle);
    }

    public boolean isReadLaterEmpty() {
        return isElementDisplayed(noArticlesHeader);
    }

    public int getAmountOfBookmarks() {
        return bookmarkCollections.size();
    }

    public void returnBack() {
        AndroidUtils.goBack();
    }

    public CreateNewCollectionComponent clickPlusIcon () {
        click(iconPlusButton);
        return new CreateNewCollectionComponent();
    }

    public boolean isNameOfTheCollectionDisplayed (String accessibilityId) {
        return AppiumHandler.getDriver().findElementByAccessibilityId(accessibilityId).isDisplayed();
    }

    public boolean isCollectionNameExceed () {
        return isElementDisplayed(collectionNameExceed);
    }
}
