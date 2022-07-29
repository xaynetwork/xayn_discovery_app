package android;

import base.AndroidTestBase;
import com.xayn.annotations.TMS;
import com.xayn.screens.HomeScreen;
import com.xayn.screens.ReaderModeScreen;
import com.xayn.screens.YourSpaceScreen;
import com.xayn.screens.components.OnboardingComponent;
import org.testng.Assert;
import org.testng.annotations.Test;

public class AndroidBookmarkingTest extends AndroidTestBase {
    @Test(description = "Adding a bookmark to Read Later collection")
    @TMS(id = 41)
    public void checkingBookmarking() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        YourSpaceScreen yourSpaceScreen = homeScreen.clickOnPersonalArea().open();
        yourSpaceScreen.clickOnCollection(0);
        Assert.assertTrue(yourSpaceScreen.isNoArticlesHeaderDisplayed(), "There is no 'No Articles' header displayed");

        yourSpaceScreen.returnBack();
        homeScreen
                .clickOnHomeButton()
                .bookmark()
                .clickOnPersonalArea();
        yourSpaceScreen.clickOnCollection(0);
        onboarding.gotItButtonClick();
        Assert.assertEquals(yourSpaceScreen.getAmountOfBookmarks(), 1, "Amount of bookmarks is different from expected");
    }

    @Test(description = "Adding a bookmark to Read Later collection from reading mode")
    @TMS(id = 42)
    public void checkingBookmarkingFromReaderMode() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        ReaderModeScreen readerModeScreen = homeScreen.clickOnDiscoveryCard().open();
        readerModeScreen.bookmark();
        readerModeScreen.clickLeftArrow();
        YourSpaceScreen yourSpaceScreen = homeScreen.clickOnPersonalArea().open();
        yourSpaceScreen.clickOnCollection(0);
        onboarding.gotItButtonClick();
        Assert.assertEquals(yourSpaceScreen.getAmountOfBookmarks(), 1, "Amount of bookmarks is different from expected");
    }
}
