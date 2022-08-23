package com.xayn.handlers;

import com.codepine.api.testrail.TestRail;
import com.codepine.api.testrail.model.Project;
import com.codepine.api.testrail.model.Result;
import com.codepine.api.testrail.model.ResultField;
import com.codepine.api.testrail.model.Run;
import com.xayn.constants.TestStatus;
import lombok.extern.log4j.Log4j2;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;

@Log4j2
public class TestRailHandler {

    private static final String APP = "Discovery App";

    private static final int APP_ID = 1;

    private static final int SUITE_ID = 1;

    public static final String DATE = new SimpleDateFormat("MM/dd/yyyy").format(Calendar.getInstance().getTime());

    public static TestRail testRail;

    public static Project project;

    public static Run run;


    public TestRailHandler(String endpoint, String user, String password, String app) {
        this.testRail = TestRail.builder("https://" + endpoint + "//", user, password).applicationName(app).build();
    }

    public static void addResult(int testcase, TestStatus status) {
        log.info("TEST RAIL : ADDING RESULT");
        List<ResultField> customResultFields = testRail.resultFields().list().execute();
        testRail.results().addForCase(run.getId(), testcase, new Result().setStatusId(status.value), customResultFields).execute();
    }
}