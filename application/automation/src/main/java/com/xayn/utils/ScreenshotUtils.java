package com.xayn.utils;

import com.github.romankh3.image.comparison.ImageComparison;
import com.github.romankh3.image.comparison.ImageComparisonUtil;
import com.github.romankh3.image.comparison.model.ImageComparisonResult;
import com.github.romankh3.image.comparison.model.ImageComparisonState;
import io.appium.java_client.MobileElement;
import lombok.extern.log4j.Log4j2;
import org.openqa.selenium.OutputType;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Objects;

import static com.xayn.configuration.Configuration.SCREENSHOT_DIRECTORY;

@Log4j2
public class ScreenshotUtils {
    public static String saveScreenshot(String screenshotAbsolutePath, MobileElement element) {
        File file = new File(screenshotAbsolutePath);
        if (createFile(file)) {
            byte[] screenshot = getScreenshot(element);
            writeScreenshotToFile(screenshot, file);
        }
        return screenshotAbsolutePath;
    }

    public static boolean createFile(File name) {
        boolean fileCreated = false;
        if (name.exists()) {
            fileCreated = true;
        } else {
            File parentDirectory = new File(name.getParent());
            if (parentDirectory.exists() || parentDirectory.mkdirs()) {
                try {
                    fileCreated = name.createNewFile();
                } catch (IOException e) {

                }
            }
        }
        return fileCreated;
    }

    private static byte[] getScreenshot(MobileElement element) {
        byte[] screenshotAs = element.getScreenshotAs(OutputType.BYTES);
        return screenshotAs;
    }

    private static void writeScreenshotToFile(byte[] image, File screenshot) {
        try (FileOutputStream screenshotStream = new FileOutputStream(screenshot)) {
            screenshotStream.write(image);
        } catch (IOException e) {
            log.error("Unable to write " + screenshot.getAbsolutePath());
            log.error(e.getMessage());
        }
    }

    public static String takeScreenshot(MobileElement element) {
        String screenshotAbsolutePath = SCREENSHOT_DIRECTORY + File.separator + System.currentTimeMillis() + ".png";
        return saveScreenshot(screenshotAbsolutePath, element);
    }

    public static boolean compareScreenshots(String file1, String file2, double permittedPercentage) {
        BufferedImage actualImage = ImageComparisonUtil.readImageFromResources(file1);
        BufferedImage expectedImage = ImageComparisonUtil.readImageFromResources(file2);
        ImageComparison imageComparison = new ImageComparison(expectedImage, actualImage);
        imageComparison.setAllowingPercentOfDifferentPixels(permittedPercentage);
        ImageComparisonResult imageComparisonResult = imageComparison.compareImages();
        ImageComparisonState imageComparisonState = imageComparisonResult.getImageComparisonState();
        return imageComparisonState == ImageComparisonState.MATCH;
    }

    public static String getResource(String path) {
        return Objects.requireNonNull(ScreenshotUtils.class.getResource(path)).getPath();
    }
}
