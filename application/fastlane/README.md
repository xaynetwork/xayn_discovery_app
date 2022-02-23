fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### create_appstore_api_key
```
fastlane create_appstore_api_key
```
Create an app store connect api key 
### update_strings
```
fastlane update_strings
```
Update strings
The first time the command fastlane update_strings is run, the POEditor Key will be asked to input
A .env file will be created containing the token
Following executions of the command will automatically take the token from the .env file
### build_runner
```
fastlane build_runner
```
Flutter build runner
### check_config_files
```
fastlane check_config_files
```
Checks alle the config (env, properties, etc) if they are correctly set
### pub_get
```
fastlane pub_get
```
Flutter pub get
### watch
```
fastlane watch
```
Watch changes for rerunning the build_runner
### clean
```
fastlane clean
```
Flutter clean
### check
```
fastlane check
```
Sanity checks (options: coverage:[true/FALSE])
Available options:
   - coverage
### publish
```
fastlane publish
```
Build and publish 
Available options:
 - version_name 
 - watch : [true, false]
 - keyFile 
 - keyId 
 - issuerId 
 - clean : [true, false]
 - platform : [ios, android]
 - android_output : [apk, appbundle]
 - flavor : [internal, beta]
 - build_type : [debug, release]
 - build_number 
 - coverage : [true, false]
 - download_profile : [true, false]
 - update_assets : [true, false]
 - upload_to_appcenter : [true, false]

### update_assets
```
fastlane update_assets
```
Update the assets folder based on the Assets Manifest from xayn_discovery_engine

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
