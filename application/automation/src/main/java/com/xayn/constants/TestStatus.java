package com.xayn.constants;

public enum TestStatus {
    Passed(1),
    Failed(5),
    Retest(4),
    Blocked(2);

    public final int value;

    TestStatus(int value) {
        this.value = value;
    }
}