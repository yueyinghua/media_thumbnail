import Flutter
import UIKit
import AVFoundation

public class SwiftMediaThumbnailPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.medinno/media_thumbnail", binaryMessenger: registrar.messenger())
        let instance = SwiftMediaThumbnailPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if( call.method == "videoThumbnail"){
            let args = call.arguments as! NSDictionary;
            let quality = args["quality"] as! Float;
            if let thumbPath = self.getVideoThumbPath(url:args["url"] as! String,outPath:args["outPath"] as! String,quality:quality) {
                result(thumbPath)
            }
        }else {
            result(FlutterMethodNotImplemented)
            return
        }
    }
    
    private func getVideoThumbPath(url: String,outPath:String,quality:Float)->String? {
        do {
            let  avasset:AVAsset;
            if(url.hasPrefix( "file://")){
                avasset = AVAsset.init(url:URL.init(fileURLWithPath: url) );
            }else{
                avasset = AVAsset.init(url:URL.init(string: url)! );
            }
            let gen = AVAssetImageGenerator.init(asset: avasset);
            gen.appliesPreferredTrackTransform = true;
            let time = CMTime.init(seconds: 0.0, preferredTimescale: 600);
            let image = try gen.copyCGImage(at: time, actualTime: nil);
            let thumb = UIImage.init(cgImage: image);
            let thumbData = thumb.jpegData(compressionQuality: CGFloat(quality/100)); // 转Data
            let fileManager = FileManager.default;
            fileManager.createFile(atPath: outPath, contents: thumbData, attributes: nil);
            return outPath;
        } catch {
            return nil;
        }
    }
}
