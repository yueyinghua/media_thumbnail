import Flutter
import UIKit

public class SwiftMediaThumbnailPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.medinno/media_thumbnail", binaryMessenger: registrar.messenger())
    let instance = SwiftMediaThumbnailPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          if( call.method == "videoThumbnail"){
              let args = call.arguments as! Dictionary<String, String>;
              let config = try OktaOidcConfig(with: [
                  "issuer": args["issuer"]!,
                  "clientId": args["clientId"]!,
                  "redirectUri": args["redirectUri"]!,
                  "logoutRedirectUri": args["endSessionUri"]!,
                  "scopes": "openid profile email offline_access",
              ])

          }else {
               result(FlutterMethodNotImplemented)
               return
          }
  }
}
