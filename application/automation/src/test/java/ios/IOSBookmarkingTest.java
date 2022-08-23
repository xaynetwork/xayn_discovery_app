package ios;

import base.IOSTestBase;
import com.xayn.annotations.TestCase;
import com.xayn.screens.HomeScreen;
import com.xayn.screens.YourSpaceScreen;
import com.xayn.screens.components.OnboardingComponent;
import org.testng.Assert;
import org.testng.annotations.Test;

public class IOSBookmarkingTest extends IOSTestBase {
    @Test(description = "Adding a bookmark to Read Later collection")
    @TestCase(id = 41)
    public void checkingBookmarking() {
        OnboardingComponent onboarding = new OnboardingComponent().open();
        onboarding.gotItButtonClick();
        HomeScreen homeScreen = new HomeScreen().open();
        YourSpaceScreen yourSpaceScreen = homeScreen
                .bookmark()
                .clickOnPersonalArea()
                .open();
        yourSpaceScreen.clickOnCollection(0);
        onboarding.gotItButtonClick();
        Assert.assertEquals(yourSpaceScreen.getAmountOfBookmarks(), 1, "Amount of bookmarks is different from expected");
    }
}
