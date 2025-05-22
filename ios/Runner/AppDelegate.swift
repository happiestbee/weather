import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyCjT5Uoin8KGNNCKyj8Q-Dc9wuW2ZuL2Ss")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
