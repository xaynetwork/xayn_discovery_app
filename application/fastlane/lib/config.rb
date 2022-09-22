module Config
  module Keys
    BUILD_NUMBER_OFFSET = "build_number_offset"
    ID = "id"
    NAME = "name"
    APPCENTER_TARGET = "appcenter_target"
    APPCENTER_TOKEN = "appcenter_token"
    KEY_ALIAS = "key_alias"
    # appbundle or apk
    ANDROID_OUTPUT = "android_output"
    PROVISIONING_PROFILE_PATH = "provisioning_profile_path"
    PROVISIONING_PROFILE_NAME = "provisioning_profile_name"
    CERTIFICATE_NAME = "certificate_name"
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

  module BuildTypes
    DEBUG = "debug"
    RELEASE = "release"
  end

  ###
  ### All possible options should be described in this module
  ###
  module Options
    def self.doc_ANDROID_OUTPUT() "apk, appbundle" end
    ANDROID_OUTPUT = :android_output

    BUILD_NUMBER = :build_number

    def self.doc_CLEAN() "true, false" end
    CLEAN = :clean

    def self.doc_COVERAGE() "true, false" end
    COVERAGE = :coverage

    def self.doc_DOWNLOAD_PROFILE() "true, false" end
    DOWNLOAD_PROFILE = :download_profile

    def self.doc_FLAVOR() "internal, beta" end
    FLAVOR = :flavor

    ISSUER_ID = :issuerId

    KEY_FILE = :keyFile

    KEY_ID = :keyId

    SKSL_PATH = :skslPath

    def self.doc_PLATFORM() "ios, android" end
    PLATFORM = :platform

    def self.doc_BUILD_TYPE() "debug, release" end
    BUILD_TYPE = :build_type

    def self.doc_UPDATE_ASSETS() "true, false" end
    UPDATE_ASSETS = :update_assets

    def self.doc_UPLOAD_TO_APPCENTER() "true, false" end
    UPLOAD_TO_APPCENTER = :upload_to_appcenter

    def self.doc_STORE() "true, false" end
    STORE = :store

    VERSION_NAME = :version_name

    def self.doc_WATCH() "true, false" end
    WATCH = :watch

    def self.doc_TEST() "true, false" end
    TEST = :test

    def self.help()
      Options.constants.map { |o|
        doc = ""
        begin
          method = Options.method("doc_#{o.to_s}".to_sym)
          doc = ": [#{method.call}]" if method
        rescue
        end
        " - #{Options.const_get(o).to_s} #{doc}\n"
      }.reduce("", :+)
    end

    def self.doc_TEST_SUITE() "regression, sanity, debug" end
    TEST_SUITE = :test_suite
  end

  # Options not passed by the user to a lane
  module InternalOptions
    ENV = :env
    BUILD_FOR_SIMULATOR = :build_for_simulator
  end

  # env defaults that will be used when no ENV variables are provided
  ENV_DEFAULTS = { "SEARCH_API_URL_DEBUG" => "https://api-gw.xaynet.dev",
                   "SEARCH_API_URL_PRODUCTION" => "https://api-gw.xayn.com",
                   "IMAGE_FETCHER_URL_DEBUG" => "https://img-fetcher.xaynet.dev",
                   "IMAGE_FETCHER_URL_PRODUCTION" => "https://img-fetcher.xayn.com",
                   "APP_STORE_NUMERICAL_ID_DEBUG" => "1593410545",
                   "APP_STORE_NUMERICAL_ID_PRODUCTION" => "1605873072",
                   "AI_ASSETS_URL" => "https://ai-assets.xaynet.dev",
                   "MIXPANEL_SERVER_URL" => "https://api-eu.mixpanel.com",
                   "RCONFIG_S3_REGION" => "s3-de-central",
                   "RCONFIG_ENDPOINT_URL" => "https://s3-de-central.profitbricks.com" }

  # Careful to change those offsets, they are defining the beta process:
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
        Keys::NAME => "Xayn News[i]",
        Keys::APPCENTER_TARGET => "Discovery-App-internal",
        Keys::APPCENTER_TOKEN => "APPCENTER_IOS_INTERNAL_TOKEN",
        Keys::BUILD_NUMBER_OFFSET => internalBuildNumberOffset,
      },
      Platforms::ANDROID => {
        Keys::ID => "com.xayn.discovery.internal",
        Keys::NAME => "Xayn News[i]",
        Keys::APPCENTER_TARGET => "Discovery-App-Android-internal",
        Keys::APPCENTER_TOKEN => "APPCENTER_ANDROID_INTERNAL_TOKEN",
        Keys::BUILD_NUMBER_OFFSET => internalBuildNumberOffset,
      },
    },
    Flavors::BETA => {
      Platforms::IOS => {
        Keys::ID => "com.xayn.discovery",
        Keys::NAME => "Xayn News",
        # Discoveru is correct!! :P
        Keys::APPCENTER_TARGET => "Discoveru-App-iOS-beta",
        Keys::APPCENTER_TOKEN => "APPCENTER_IOS_BETA_TOKEN",
        Keys::BUILD_NUMBER_OFFSET => betaBuildNumberOffset,
      },
      Platforms::ANDROID => {
        Keys::ID => "com.xayn.discovery",
        Keys::NAME => "Xayn News",
        Keys::APPCENTER_TARGET => "Discovery-App-Android-beta",
        Keys::APPCENTER_TOKEN => "APPCENTER_ANDROID_BETA_TOKEN",
        Keys::BUILD_NUMBER_OFFSET => betaBuildNumberOffset,
      },
    },
    Flavors::PRODUCTION => {
      Platforms::IOS => {
        Keys::ID => "com.xayn.search",
        Keys::NAME => "Xayn News",
      },
      Platforms::ANDROID => {
        Keys::ID => "com.xayn.search",
        Keys::NAME => "Xayn News",
      },
    },
  }

  ANDROID_BUILD_CONFIG = {
    Flavors::INTERNAL => {
      Keys::ANDROID_OUTPUT => AndroidOutputs::APK,
      Keys::KEY_ALIAS => "release_internal",
    },
    Flavors::BETA => {
      Keys::ANDROID_OUTPUT => AndroidOutputs::APP_BUNDLE,
      Keys::KEY_ALIAS => "release_beta",
    },
  }

  # TODO rework the profiles and IOS_BUILD_CONFIG section to avoid duplication
  PROFILES = ["Xayn Discovery Internal Adhoc Profile", "Xayn Discovery AppStore Profile", "Xayn Discovery Internal Develop Profile"]
  IOS_BUILD_CONFIG = {
    Flavors::INTERNAL => {
      Keys::PROVISIONING_PROFILE_PATH => "profiles/Xayn_Discovery_Internal_Adhoc_Profile.mobileprovision",
      Keys::PROVISIONING_PROFILE_NAME => "Xayn Discovery Internal Adhoc Profile",
      Keys::CERTIFICATE_NAME => "Apple Distribution: Xayn AG (586TQ875ST)",
      Keys::PROVISIONING_PROFILES => {
        "com.xayn.discovery.internal" => "Xayn Discovery Internal Adhoc Profile",
      },
      Keys::ADHOC => true,
    },
    Flavors::BETA => {
      Keys::PROVISIONING_PROFILE_PATH => "profiles/Xayn_Discovery_AppStore_Profile.mobileprovision",
      Keys::PROVISIONING_PROFILE_NAME => "Xayn Discovery AppStore Profile",
      Keys::CERTIFICATE_NAME => "Apple Distribution: Xayn AG (586TQ875ST)",
      Keys::PROVISIONING_PROFILES => {
        "com.xayn.discovery" => "Xayn Discovery AppStore Profile",
      },
      Keys::ADHOC => false,
    },
  }

  # Appcenter defaults
  APPCENTER_OWNER_NAME = "XAIN_AG"
  APPCENTER_OWNER_TYPE = "organization"
  APPCENTER_DESTINATION_TYPE_STORE = "store"
  APPCENTER_DEFAULT_TARGET = "Collaborators"
  APPCENTER_DEFAULT_STORE = "Beta"
end
