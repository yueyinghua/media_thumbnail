package com.medinno.media_thumbnail;

import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * MediaThumbnailPlugin
 */
public class MediaThumbnailPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.medinno/media_thumbnail");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("videoThumbnail")) {
            final Map<String, Object> args = call.arguments();
            final String url = (String) args.get("url");
            final HashMap<String, String> headers = (HashMap<String, String>) args.get("headers");
            final int quality = (int) args.get("quality");
            final String outPath = (String) args.get("outPath");
            final String path = createVideoThumb(url, outPath,headers,  quality);
            result.success(path);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    private String createVideoThumb(String url, String outPath, final HashMap<String, String> headers, int quality) {
        Log.i("path", url);
        Bitmap bitmap = createVideoThumbnail(url, headers);
        if(bitmap == null) return  null;
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, bytes);
        try {
            File outputFile = new File(outPath);
            FileOutputStream fo = new FileOutputStream(outputFile);
            fo.write(bytes.toByteArray());
            fo.close();
            return outputFile.getAbsolutePath();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Bitmap createVideoThumbnail(final String url, final HashMap<String, String> headers) {
        Bitmap bitmap = null;
        MediaMetadataRetriever retriever = new MediaMetadataRetriever();
        try {
            if (url.startsWith("/")) {
                setDataSource(url, retriever);
            } else if (url.startsWith("file://")) {
                setDataSource(url.substring(7), retriever);
            } else {
                retriever.setDataSource(url, (headers != null) ? headers : new HashMap<String, String>());
            }
            bitmap = retriever.getFrameAtTime(-1, MediaMetadataRetriever.OPTION_CLOSEST_SYNC);
        } catch (IllegalArgumentException ex) {
            ex.printStackTrace();
        } catch (RuntimeException ex) {
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            try {
                retriever.release();
            } catch (RuntimeException ex) {
                ex.printStackTrace();
            }
        }

        return bitmap;
    }

    private static void setDataSource(String video, final MediaMetadataRetriever retriever) throws IOException {
        File videoFile = new File(video);
        FileInputStream inputStream = new FileInputStream(videoFile.getAbsolutePath());
        retriever.setDataSource(inputStream.getFD());
    }
}
