import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // TODO: Add your Google Maps API key y Validar en ios
    GMSServices.provideAPIKey("AIzaSyCIkaEV6hC5aqziGhyzrTcAKgrBHjHnAKQ")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
