package com.xayn.listeners;

import com.xayn.configuration.Configuration;
import lombok.extern.log4j.Log4j2;
import org.testng.IRetryAnalyzer;
import org.testng.ITestResult;

@Log4j2
public class RetryAnalyzerImp implements IRetryAnalyzer {
    private int retryCount = 0;
    private int maxRetryCount = Configuration.RETRY_COUNT;
    public boolean retry(ITestResult result) {
        if(retryCount < maxRetryCount)
        {
            retryCount++;
            log.warn( "retrying " + result.getMethod());
            return true;
        }
        return false;
    }
}