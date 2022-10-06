package com.xayn.screens;

import com.xayn.screens.base.BaseScreen;
import com.xayn.utils.WaitUtils;
import io.appium.java_client.MobileElement;
import io.appium.java_client.pagefactory.AndroidFindBy;
import io.appium.java_client.pagefactory.iOSXCUITFindBy;
import io.qameta.allure.Step;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.WebDriverException;

import java.util.Arrays;
import java.util.List;

@Log4j2
public class HomeScreen extends BaseScreen {

    // nav bar
    @AndroidFindBy(accessibility = "nav_bar_item_home")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_home")
    private MobileElement homeButton;
    @AndroidFindBy(accessibility = "nav_bar_item_search")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_search")
    private MobileElement searchButton;
    @AndroidFindBy(accessibility = "nav_bar_item_personal_area")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_personal_area")
    private MobileElement yourSpaceButton;

    @AndroidFindBy(accessibility = "What do you want to see less of?")
    private MobileElement sourcesToolbar;

    @AndroidFindBy(accessibility = "nav_bar_item_like = false")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_like = false")
    private List<MobileElement> likeButtonFalse;

    @AndroidFindBy(xpath = " //android.widget.Button")
    private List<MobileElement> newsCardBodyButton;

    @AndroidFindBy(accessibility = "nav_bar_item_like = true")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_like = true")
    private List<MobileElement> likeButtonTrue;

    @AndroidFindBy(accessibility = "nav_bar_item_dis_like = false")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_dis_like = false")
    private List<MobileElement> dislikeButtonFalse;

    @AndroidFindBy(accessibility = "nav_bar_item_dis_like = true")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_dis_like = true")
    private List<MobileElement> dislikeButtonTrue;

    @AndroidFindBy(accessibility = "nav_bar_item_bookmark = false")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_bookmark = false")
    private List<MobileElement> bookmarkButton;

    @AndroidFindBy(accessibility = "nav_bar_item_bookmark = true")
    @iOSXCUITFindBy(accessibility = "nav_bar_item_bookmark = true")
    private List<MobileElement> unbookmarkButton;

    //TODO add label
    @AndroidFindBy(xpath = "//android.widget.Button")
    @iOSXCUITFindBy(iOSNsPredicate = "label contains 'minutes read'")
    private List<MobileElement> discoveryCards;

    @Step("opening home screen")
    public HomeScreen open() {
        super.openScreen();
        log.warn("waiting for news feed to load..");
        WaitUtils.getLongWaitUtils().waitElementFromTheListToExist(newsCardBodyButton,0);
        log.info("news feed loaded...");
        return this;
    }

    @Override
    protected void load() {
    }

    @Override
    protected void isLoaded() throws Error {
        WaitUtils.getWaitUtils().waitUntilElementsAppear(Arrays.asList(homeButton, searchButton, yourSpaceButton));
    }

    public HomeScreen clickOnHomeButton() {
        click(homeButton);
        return this;
    }

    public YourSpaceScreen clickOnPersonalArea() {
        click(yourSpaceButton);
        return new YourSpaceScreen();
    }

    public HomeScreen bookmark() {
        try {
            click(bookmarkButton.get(0));
        } catch (WebDriverException exception) {
            log.warn(exception.fillInStackTrace());
            click(bookmarkButton.get(1));
        }
        return this;
    }

    public HomeScreen unBookmark() {
       clickOnFirstAvailable(bookmarkButton);
        return this;
    }

    public ReaderModeScreen clickOnDiscoveryCard() {
        click(discoveryCards.get(0));
        return new ReaderModeScreen();
    }

    public YourSpaceScreen clickOnYourSpace() {
        click(yourSpaceButton);
        return new YourSpaceScreen();
    }

    public HomeScreen likeDiscoveryCard() {
       clickOnFirstAvailable(likeButtonFalse);
       return this;
    }

    public HomeScreen dislikeDiscoveryCard() {
        clickOnFirstAvailable(dislikeButtonFalse);
        return this;
    }

    public void clickOnScreenCenter() {
        clickByCoordinates(200, 400);
    }

    public boolean isCardBookmarked () {
        return unbookmarkButton.get(0).isDisplayed();
    }

    public boolean isCardLiked () {
        return likeButtonTrue.get(0).isDisplayed();
    }

    public boolean isCardDisLiked () {
        return dislikeButtonTrue.get(0).isDisplayed();
    }

    public boolean isNavBarDisplayed () { return homeButton.isDisplayed() && searchButton.isDisplayed() && yourSpaceButton.isDisplayed();}

}