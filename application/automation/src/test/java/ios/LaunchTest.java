package ios;

import base.IOSTestBase;
import com.xayn.annotations.TestCase;
import org.testng.annotations.Test;

public class LaunchTest extends IOSTestBase {
    @Test(description = "Simple test to launch the app")
    @TestCase()
    public void LaunchingApp() {
        System.out.println("LAUNCHING THE APP");
    }
}
