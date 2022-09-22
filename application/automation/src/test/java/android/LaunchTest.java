package android;

import base.AndroidTestBase;
import com.xayn.annotations.TestCase;
import org.testng.annotations.Test;

public class LaunchTest extends AndroidTestBase {
    @Test(description = "Simple test to launch the app")
    @TestCase()
    public void LaunchingApp() throws InterruptedException {
        System.out.println("LAUNCHING THE APP");
        Thread.sleep(60000);
    }

}
