package com.xayn.screens.components;

import com.xayn.screens.base.BaseComponent;
import io.appium.java_client.MobileElement;
import io.appium.java_client.pagefactory.AndroidFindBy;

public class CreateNewCollectionComponent extends BaseComponent {

    @AndroidFindBy(xpath = "//android.widget.EditText")
    private MobileElement textInputField;

    @AndroidFindBy(accessibility = "Create")
    private MobileElement createButton;

    @AndroidFindBy(accessibility = "Cancel")
    private MobileElement cancelButton;

    @Override
    public CreateNewCollectionComponent open() {
        super.openScreen();
        return this;
    }

    @Override
    protected void load() {

    }

    @Override
    protected void isLoaded() throws Error {

    }

    public CreateNewCollectionComponent typeCollectionName (String name) {
        type(textInputField, name);
        return this;
    }

    public CreateNewCollectionComponent clickCreateButton () {
        click(createButton);
        return this;
    }

    public boolean isCreateButtonEnabled () {
        return createButton.isEnabled();
    }
}