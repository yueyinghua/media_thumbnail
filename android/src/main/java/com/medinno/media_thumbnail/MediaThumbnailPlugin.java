package com.medinno.media_thumbnail;

import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

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
    private ExecutorService executor;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        executor = Executors.newCachedThreadPool();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.medinno/media_thumbnail");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        final Map<String, Object> args = call.arguments();
        final String url = (String) args.get("url");
        final HashMap<String, String> headers = (HashMap<String, String>) args.get("headers");
        final int quality = (int) args.get("quality");
        final String outPath = (String) args.get("outPath");
        final String method = call.method;
        executor.execute(new Runnable() {
            @Override
            public void run() {
                Object thumbnail = null;
                boolean handled = false;
                Exception exc = null;

                try {
                    if (method.equals("videoThumbnail")) {
                        thumbnail = createVideoThumb(url, outPath,headers,  quality);
                        handled = true;
                    }
                } catch (Exception e) {
                    exc = e;
                }

                onResult(result, thumbnail, handled, exc);
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        executor.shutdown();
        executor = null;
    }
    private void onResult(final Result result, final Object thumbnail, final boolean handled, final Exception e) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!handled) {
                    result.notImplemented();
                    return;
                }

                if (e != null) {
                    e.printStackTrace();
                    result.error("exception", e.getMessage(), null);
                    return;
                }

                result.success(thumbnail);
            }
        });
    }
    private static void runOnUiThread(Runnable runnable) {
        new Handler(Looper.getMainLooper()).post(runnable);
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
