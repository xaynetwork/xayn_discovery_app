module Config
  module Keys
    BUILD_NUMBER_OFFSET = "build_number_offset"
    ID = "id"
    NAME = "name"
    APPCENTER_TARGET = "appcenter_target"
    APPCENTER_TOKEN = "appcenter_token"
    APPCENTER_FILEPATH = "appcenter_buildfile"
    KEY_ALIAS = "key_alias"
    PROVISIONING_PROFILE_PATH = "provisioning_profile_path"
    PROVISIONING_PROFILE_NAME = "provisioning_profile_name"
    PROVISIONING_PROFILES = "provisioning_profiles"
    ADHOC = "adhoc"
  end

  module Platforms
    ANDROID = "android"
    IOS = "ios"
  end

  module Flavors
    INTERNAL = "internal"
    BETA = "beta"
    PRODUCTION = "production"
  end

  module AndroidOutputs
    APK = "apk"
    APP_BUNDLE = "appbundle"
  end

  ###
  ### All possible options should be described in this module
  ###
  module Options
    # Available variants: AndroidOutputs
    ANDROID_OUTPUT = :android_output
    BUILD_NUMBER = :build_number
    # Available variants: true / false
    CLEAN = :clean
    # Available variants: true / false
    COVERAGE = :coverage
    # Available variants: true / false
    DOWNLOAD_PROFILE = :download_profile
    ENV = :env
    # Available variants: Flavors
    FLAVOR = :flavor
    # Available variants: Platforms
    PLATFORM = :platform
    # Available variants: true / false
    RELEASE_BUILD = :release_build
    UPDATE_ASSETS = :update_assets
    # Available variants: true / false
    UPLOAD_TO_APPCENTER = :upload_to_appcenter
    VERSION_NAME = :version_name
    # Available variants: true / false
    WATCH = :watch
  end

  # env defaults that will be used when no ENV variables are provided
  ENV_DEFAULTS = { "SEARCH_API_URL_DEBUG" => "api-gw.xaynet.dev",
                   "SEARCH_API_URL_PRODUCTION" => "api-gw.xayn.com",
                   "IMAGE_FETCHER_URL_DEBUG" => "https://img-fetcher.xaynet.dev",
                   "IMAGE_FETCHER_URL_PRODUCTION" => "https://img-fetcher.xayn.com",
                   "APP_STORE_NUMERICAL_ID_DEBUG" => "1593410545",
                   "APP_STORE_NUMERICAL_ID_PRODUCTION" => "1514123811",
                   "AI_ASSETS_URL" => "https://ai-assets.xaynet.dev" }

  # Carefull to change those offsets, they are defining the beta process:
  # production:       1,     2,     3,  ..., 479, ... |  10480...
  # beta      :   10001, 10002, 10003, ... 10479, ... |  ^^close beta
  #
  # Closing the beta is possible and then production would take over the last
  # beta buildNumber
  internalBuildNumberOffset = 0
  betaBuildNumberOffset = 10000

  FLAVOR_MATRIX = {
    Flavors::INTERNAL => {
      Platforms::IOS => {
        Keys::ID => "com.xayn.discovery.internal",
        Keys::NAME => "Discovery",
        Keys::APPCENTER_TARGET => "Discovery-App-internal",
        Keys::APPCENTER_TOKEN => "APPCENTER_IOS_INTERNAL_TOKEN",
        Keys::APPCENTER_FILEPATH => "build/discovery-app.ipa",
        Keys::BUILD_NUMBER_OFFSET => internalBuildNumberOffset,
      },
      Platforms::ANDROID => {
        Keys::ID => "com.xayn.discovery.internal",
        Keys::NAME => "Discovery",
        Keys::APPCENTER_TARGET => "Discovery-App-Android-internal",
        Keys::APPCENTER_TOKEN => "APPCENTER_ANDROID_INTERNAL_TOKEN",
        Keys::APPCENTER_FILEPATH => "build/app/outputs/flutter-apk/app-release.apk",
        Keys::BUILD_NUMBER_OFFSET => internalBuildNumberOffset,
      },
    },
    Flavors::BETA => {
      Platforms::IOS => {
        Keys::ID => "com.xayn.discovery",
        Keys::NAME => "Xayn 3.0",
        # Discoveru is correct!! :P
        Keys::APPCENTER_TARGET => "Discoveru-App-iOS-beta",
        Keys::APPCENTER_TOKEN => "APPCENTER_IOS_BETA_TOKEN",
        Keys::APPCENTER_FILEPATH => "build/discovery-app.ipa",
        Keys::BUILD_NUMBER_OFFSET => betaBuildNumberOffset,
      },
      Platforms::ANDROID => {
        Keys::ID => "com.xayn.search",
        Keys::NAME => "Xayn 3.0",
        Keys::APPCENTER_TARGET => "Discovery-App-Android-beta",
        Keys::APPCENTER_TOKEN => "APPCENTER_ANDROID_BETA_TOKEN",
        Keys::APPCENTER_FILEPATH => "build/app/outputs/flutter-apk/app-release.apk",
        Keys::BUILD_NUMBER_OFFSET => betaBuildNumberOffset,
      },
    },
    Flavors::PRODUCTION => {
      Platforms::IOS => {
        Keys::ID => "com.xayn.search",
        Keys::NAME => "Discovery App",
      },
      Platforms::ANDROID => {
        Keys::ID => "com.xayn.search",
        Keys::NAME => "Discovery App",
      },
    },
  }

  ANDROID_BUILD_CONFIG = {
    Flavors::INTERNAL => {
      Keys::KEY_ALIAS => "release_internal",
    },
    Flavors::BETA => {
      Keys::KEY_ALIAS => "release_beta",
    },
  }

  IOS_BUILD_CONFIG = {
    Flavors::INTERNAL => {
      Keys::PROVISIONING_PROFILE_PATH => "profiles/Xayn_Discovery_Internal_Adhoc_Profile.mobileprovision",
      Keys::PROVISIONING_PROFILE_NAME => "Xayn Discovery Internal Adhoc Profile",
      Keys::PROVISIONING_PROFILES => {
        "com.xayn.discovery.internal" => "Xayn Discovery Internal Adhoc Profile",
      },
      Keys::ADHOC => true,
    },
    Flavors::BETA => {
      Keys::PROVISIONING_PROFILE_PATH => "profiles/Xayn_Discovery_AppStore_Profile.mobileprovision",
      Keys::PROVISIONING_PROFILE_NAME => "Xayn Discovery AppStore Profile",
      Keys::PROVISIONING_PROFILES => {
        "com.xayn.discovery" => "Xayn Discovery AppStore Profile",
      },
      Keys::ADHOC => false,
    },
  }

  # Appcenter defaults
  APPCENTER_OWNER_NAME = "XAIN_AG"
  APPCENTER_OWNER_TYPE = "organization"
  APPCENTER_DEFAULT_TARGET = "Collaborators"
end
