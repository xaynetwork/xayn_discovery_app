import UIKit
import Flutter
import AppTrackingTransparency

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
