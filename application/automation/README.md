![Xayn](https://uploads-ssl.webflow.com/5ea197660b956f76d26f0026/5ea197660b956f6b886f003d_xayn-logo.svg)

## _Xayn Mobile Automation with Appium_<a name="TOP"></a>

### Required components  🛠

1. _**JDK8**_
2. _**Node**_
3. _**Maven 3.8.5**_
4. _**Appium >=1.22.0**_
5. _**Android SDK**_
6. _**Xcode**_

### Configuration for local execution 📱
Configuration file is located in _**src/main/resources**_
1. Override path to node binary to _**driver.exec**_
2. Override path to appium binary to _**appium.js**_
3. Add paths to **_app.android_** and **_app.ios_**
4. Add ids and versions for os testing devices


### Environment variables 📃
1. _**ANDROID_HOME**_
2. _**ANDROID_SDK_ROOT**_
3. _**JAVA_HOME**_
4. _**XCODE_ORG_ID**_
5. _**IOS_PERSONAL**_ (id of debugging device)
6. _**ANDROID_PERSONAL**_ (id of debugging device)

### Execution

1. `mvn clean test -DsuiteXmlFile=testng/regression.xml` - to compile sources and run tests with test configuration from _**pom.xml**_ (see **_suiteXmlFile_** tag)