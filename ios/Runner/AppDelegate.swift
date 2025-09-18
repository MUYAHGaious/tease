import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let adaptiveIconsChannel = FlutterMethodChannel(name: "adaptive_icons",
                                                  binaryMessenger: controller.binaryMessenger)
    
    adaptiveIconsChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "supportsAlternateIcons":
        result(UIApplication.shared.supportsAlternateIcons)
        
      case "setAlternateIconName":
        guard UIApplication.shared.supportsAlternateIcons else {
          result(FlutterError(code: "UNAVAILABLE",
                            message: "Alternate icons not supported",
                            details: nil))
          return
        }
        
        let iconName = call.arguments as? String
        
        UIApplication.shared.setAlternateIconName(iconName) { (error) in
          if let error = error {
            result(FlutterError(code: "FAILED",
                              message: "Failed to set icon: \(error.localizedDescription)",
                              details: nil))
          } else {
            result(true)
          }
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
