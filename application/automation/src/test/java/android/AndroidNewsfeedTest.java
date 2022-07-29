package android;

import base.AndroidTestBase;
import com.xayn.annotations.TMS;
import com.xayn.constants.Directions;
import com.xayn.screens.HomeScreen;
import com.xayn.screens.components.OnboardingComponent;
import org.testng.Assert;
import org.testng.annotations.Test;

public class AndroidNewsfeedTest extends AndroidTestBase {

    @Test(description = "Liking an article by swiping it to the right")
    @TMS(id = 202)
    public void checkingLikeBySwipe() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        homeScreen.swipeScreen(Directions.RIGHT);
        Assert.assertTrue(homeScreen.isCardLiked(), "Card isn't liked");
    }

    @Test(description = "Disliking an article by swiping it to the left")
    @TMS(id = 203)
    public void checkingDislikeBySwipe() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        homeScreen.swipeScreen(Directions.LEFT);
        Assert.assertTrue(homeScreen.isCardDisLiked(), "Card isn't disliked");
    }

    @Test(description = "Liking an article by clicking on the like button")
    @TMS(id = 204)
    public void checkingLikeByButton() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        homeScreen.likeDiscoveryCard();
        Assert.assertTrue(homeScreen.isCardLiked(), "Card isn't liked");
    }

    @Test(description = "Disliking an article by clicking on the dislike button")
    @TMS(id = 205)
    public void checkingDislikeByButton() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        homeScreen.dislikeDiscoveryCard();
        Assert.assertTrue(homeScreen.isCardDisLiked(), "Card isn't disliked");
    }
}