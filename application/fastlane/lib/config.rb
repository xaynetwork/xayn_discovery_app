module Config
  module Keys
    BUILD_NUMBER_OFFSET = "build_number_offset"
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
    ANDROID_OUTPUT = :android_output
    BUILD = :build
    BUILD_NUMBER = :build_number
    CLEAN = :clean
    COVERAGE = :coverage
    DOWNLOAD_PROFILE = :download_profile
    ENV = :env
    # Available variants: Flavors
    FLAVOR = :flavor
    # Available variants: Platforms
    PLATFORM = :platform
    UPDATE_ASSETS = :update_assets
    UPLOAD_TO_APPCENTER = :upload_to_appcenter
    VERSION_NAME = :version_name
    WATCH = :watch
  end

  #release, debug
  BUILD = "debug"

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
        "id" => "com.xayn.discovery.internal",
        "name" => "Discovery",
        "appcenter_target" => "Discovery-App-internal",
        "appcenter_token" => "APPCENTER_IOS_INTERNAL_TOKEN",
        "appcenter_buildfile" => "build/discovery-app.ipa",
        Keys::BUILD_NUMBER_OFFSET => internalBuildNumberOffset,
      },
      Platforms::ANDROID => {
        "id" => "com.xayn.discovery.internal",
        "name" => "Discovery",
        "appcenter_target" => "Discovery-App-Android-internal",
        "appcenter_token" => "APPCENTER_ANDROID_INTERNAL_TOKEN",
        "appcenter_buildfile" => "build/app/outputs/flutter-apk/app-release.apk",
        Keys::BUILD_NUMBER_OFFSET => internalBuildNumberOffset,
      },
    },
    Flavors::BETA => {
      Platforms::IOS => {
        "id" => "com.xayn.discovery",
        "name" => "Xayn 3.0",
        # Discoveru is correct!! :P
        "appcenter_target" => "Discoveru-App-iOS-beta",
        "appcenter_token" => "APPCENTER_IOS_BETA_TOKEN",
        "appcenter_buildfile" => "build/discovery-app.ipa",
        Keys::BUILD_NUMBER_OFFSET => betaBuildNumberOffset,
      },
      Platforms::ANDROID => {
        "id" => "com.xayn.search",
        "name" => "Xayn 3.0",
        "appcenter_target" => "Discovery-App-Android-beta",
        "appcenter_token" => "APPCENTER_ANDROID_BETA_TOKEN",
        "appcenter_buildfile" => "build/app/outputs/flutter-apk/app-release.apk",
        Keys::BUILD_NUMBER_OFFSET => betaBuildNumberOffset,
      },
    },
    Flavors::PRODUCTION => {
      Platforms::IOS => {
        "id" => "com.xayn.search",
        "name" => "Discovery App",
      },
      Platforms::ANDROID => {
        "id" => "com.xayn.search",
        "name" => "Discovery App",
      },
    },
  }

  ANDROID_BUILD_CONFIG = {
    Flavors::INTERNAL => {
      "key_alias" => "release_internal",
    },
    Flavors::BETA => {
      "key_alias" => "release_beta",
    },
  }

  IOS_BUILD_CONFIG = {
    Flavors::INTERNAL => {
      "provisioning_profile_path" => "profiles/Xayn_Discovery_Internal_Adhoc_Profile.mobileprovision",
      "provisioning_profile_name" => "Xayn Discovery Internal Adhoc Profile",
      "provisioning_profiles" => {
        "com.xayn.discovery.internal" => "Xayn Discovery Internal Adhoc Profile",
      },
      "adhoc" => true,
    },
    Flavors::BETA => {
      "provisioning_profile_path" => "profiles/Xayn_Discovery_AppStore_Profile.mobileprovision",
      "provisioning_profile_name" => "Xayn Discovery AppStore Profile",
      "provisioning_profiles" => {
        "com.xayn.discovery" => "Xayn Discovery AppStore Profile",
      },
      "adhoc" => false,
    },
  }

  # Appcenter defaults
  APPCENTER_OWNER_NAME = "XAIN_AG"
  APPCENTER_OWNER_TYPE = "organization"
  APPCENTER_DEFAULT_TARGET = "Collaborators"
end
