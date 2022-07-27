package ios;

import base.IOSTestBase;
import com.xayn.annotations.TMS;
import com.xayn.screens.HomeScreen;
import com.xayn.screens.ReaderModeScreen;
import com.xayn.screens.components.OnboardingComponent;
import org.testng.Assert;
import org.testng.annotations.Test;

public class IOSReaderModeTest extends IOSTestBase {
    @Test(description = "Liking an article in reader mode")
    @TMS(id = 22)
    public void checkingLikeInReaderMode() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        homeScreen.clickOnScreenCenter();
        ReaderModeScreen readerModeScreen = new ReaderModeScreen().open();
        readerModeScreen.clickLikeButton();
        Assert.assertTrue(readerModeScreen.isArticleLiked(), "Article isn't liked");
    }

    @Test(description = "Disliking an article in reader mode")
    @TMS(id = 23)
    public void checkingDislikeInReaderMode() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        homeScreen.clickOnScreenCenter();
        ReaderModeScreen readerModeScreen = new ReaderModeScreen().open();
        readerModeScreen.clickDislikeButton();
        Assert.assertTrue(readerModeScreen.isArticleDisliked(), "Article isn't disliked");
    }

    @Test(description = "Navigating back from reader mode")
    @TMS(id = 26)
    public void checkingNavigatingBackFromReaderMode() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        homeScreen.clickOnScreenCenter();
        ReaderModeScreen readerModeScreen = new ReaderModeScreen().open();
        readerModeScreen.clickLeftArrow();
        Assert.assertTrue(homeScreen.isNavBarDisplayed(), "Navbar isn't displayed");
    }
}
