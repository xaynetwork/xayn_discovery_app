package com.xayn.screens;

import com.xayn.screens.base.BaseScreen;
import com.xayn.utils.WaitUtils;
import io.appium.java_client.MobileElement;
import io.appium.java_client.pagefactory.AndroidFindBy;
import io.appium.java_client.pagefactory.iOSXCUITFindBy;
import io.qameta.allure.Step;

import java.util.Arrays;

public class ReaderModeScreen extends BaseScreen {

    @AndroidFindBy(accessibility = "nav_bar_item_bookmark = true")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_bookmark = true")
    private MobileElement bookmarkButtonTrue;
    @AndroidFindBy(accessibility = "nav_bar_item_bookmark = false")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_bookmark = false")
    private MobileElement bookmarkButtonFalse;

    @AndroidFindBy(accessibility = "nav_bar_item_like = true")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_like = true")
    private MobileElement likeButtonTrue;

    @AndroidFindBy(accessibility = "nav_bar_item_like = false")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_like = false")
    private MobileElement likeButtonFalse;

    @AndroidFindBy(accessibility = "nav_bar_item_dis_like = true")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_dis_like = true")
    private MobileElement dislikeButtonTrue;

    @AndroidFindBy(accessibility = "nav_bar_item_dis_like = false")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_dis_like = false")
    private MobileElement dislikeButtonFalse;

    @AndroidFindBy(accessibility = "nav_bar_item_share")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_share")
    private MobileElement shareButton;

    @AndroidFindBy(accessibility = "nav_bar_item_edit_font_size")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_edit_font_size")
    private MobileElement fontSizeButton;

    @AndroidFindBy(accessibility = "nav_bar_item_arrow_left")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_arrow_left")
    private MobileElement arrowLeftButton;

    @Step("opening 'Reader Mode' screen")
    @Override
    public ReaderModeScreen open() {
        super.openScreen();
        return this;
    }

    @Override
    protected void load() {
    }

    @Override
    protected void isLoaded() throws Error {
        WaitUtils.getWaitUtils().waitUntilElementsAppear
                (Arrays.asList(arrowLeftButton, shareButton, fontSizeButton));
    }

    public ReaderModeScreen bookmark() {
        click(bookmarkButtonFalse);
        return this;
    }

    public void clickLeftArrow() {
        click(arrowLeftButton);
    }

    public void clickLikeButton() {
        click(likeButtonFalse);
    }

    public void clickDislikeButton() {
        click(dislikeButtonFalse);
    }

    public boolean isArticleLiked() {
        return isElementDisplayed(likeButtonTrue);
    }

    public boolean isArticleDisliked() {
        return isElementDisplayed(dislikeButtonTrue);
    }
}
