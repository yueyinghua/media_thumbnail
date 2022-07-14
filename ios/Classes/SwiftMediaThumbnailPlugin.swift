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
            let url = args["url"] as! String;
            let outPath = args["outPath"] as! String;
            print(outPath);
            let quality = args["quality"] as! Float;
            print("quality:\(quality)");
            self.createThumbnailForVideo(atURL: url, completion: {(thumb) in
                if(thumb==nil) {result(nil); return;}
                let thumbData = thumb!.jpegData(compressionQuality: CGFloat(quality)/100); // 转Data
                let thumbPath = self.createFile(data: thumbData,outPath:outPath);
                result(thumbPath)
            });
        }else {
            result(FlutterMethodNotImplemented)
            return
        }
    }
    func createThumbnailForVideo(atURL videoURL: String , completion : @escaping (UIImage?)->Void) {
        var asset: AVAsset?;
        if(videoURL.hasPrefix("/")){            
            asset = AVAsset(url: URL.init(fileURLWithPath:videoURL));
        }else{
            asset = AVAsset(url: URL.init(string: videoURL)!);
        }
        let assetImgGenerate = AVAssetImageGenerator(asset: asset!)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1, preferredTimescale: 60)
        let times = [NSValue(time: time)]
        assetImgGenerate.generateCGImagesAsynchronously(forTimes: times, completionHandler: {  _, image, _, _, _ in
            if let image = image {
                let uiImage = UIImage(cgImage: image)
                completion(uiImage)
            } else {
                completion(nil)
            }
        })
    }
    private func createFile(data: Data?,outPath:String)->String {
        let fileManager = FileManager.default;
        fileManager.createFile(atPath: outPath, contents: data, attributes: nil);
        return outPath;
    }
}
