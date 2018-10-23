package com.mateusrodcosta.flutter.hedgehoglauncher;

import android.annotation.TargetApi;
import android.app.WallpaperManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.UserManager;
import android.util.Base64;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL_LAUNCHER_HELPER = "com.mateusrodcosta.flutter.hedgehoglauncher/launcher_helper";
    private static final String CHANNEL_SYSTEMUI_HELPER = "com.mateusrodcosta.flutter.hedgehoglauncher/systemui_helper";
    private PackageManager pm;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL_LAUNCHER_HELPER).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                        String method = methodCall.method;

                        if (method.equals("getListApps")) {
                            List<HashMap<String, String>> list = getListApps();
                            if (!list.isEmpty()) {
                                result.success(list);
                            } else {
                                result.error("UNAVAILABLE", "Couldn't get packages", null);
                            }
                        } else if (method.contains("openAppSettings")) {
                            String methodParameters[] = method.split("-");
                            String packageName = methodParameters[1];
                            openAppSettings(packageName);
                        } else if (method.contains("openApp")) {
                            String methodParameters[] = method.split("-");
                            String packageName = methodParameters[1];
                            openApp(packageName);

                        }
                    }
                }
        );

        new MethodChannel(getFlutterView(), CHANNEL_SYSTEMUI_HELPER).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
                @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
                @Override
                public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

                    String method = methodCall.method;

                    if (method.equals("getUserWallpaper")) {
                        String wallpaper = getUserWallpaper();
                        if (wallpaper != null) {
                            result.success(wallpaper);
                        } else {
                            result.error("UNAVAILABLE", "Couldn't get wallpaper", null);
                        }
                    } else if(method.equals("getUsername")) {
                        UserManager um = (UserManager) getSystemService(Context.USER_SERVICE);
                        String username = "Guest";
                        if (um != null) {
                            username = um.getUserName();
                        }
                        Log.d("Username", username);
                        result.success(username);
                    }
                }
            }
        );


    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private void openApp(String packageName) {
        pm = getPackageManager();
        startActivity(pm.getLaunchIntentForPackage(packageName));
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private void openAppSettings(String packageName) {

        startActivity(new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.parse("package:" + packageName)));
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private List<HashMap<String, String>> getListApps() {

        Intent intent = new Intent()
                .setAction(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_LAUNCHER);

        pm = getPackageManager();

        List<ResolveInfo> list = pm.queryIntentActivities(intent, 0);

        List<ApplicationInfo> appInfoList = new ArrayList<>();

        for (ResolveInfo info : list) {
            ApplicationInfo appInfo;
            try {
                appInfo = pm.getApplicationInfo(info.activityInfo.packageName, PackageManager.GET_META_DATA);
                appInfoList.add(appInfo);
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
        }

        List<HashMap<String, String>> result = new ArrayList<>();

        for (ApplicationInfo info : appInfoList) {
            if (info != null) {
                HashMap<String, String> object = new HashMap<>();

                object.put("packageName", info.packageName);
                object.put("appIcon", getAppIcon(info));
                object.put("appLabel", pm.getApplicationLabel(info).toString());

                result.add(object);
            }
        }

        return result;
    }

    String getAppIcon(ApplicationInfo info) {

        Drawable drawable = pm.getApplicationIcon(info);

        return bitmapToBase64(getBitmapFromDrawable(drawable));
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    String bitmapToBase64(Bitmap bitmap) {

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
        byte[] byteArray = byteArrayOutputStream.toByteArray();

        String base64 = Base64.encodeToString(byteArray, Base64.NO_WRAP);
        //Log.d("Encoded", base64);
        return base64;

    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private Bitmap getBitmapFromDrawable(Drawable drawable) {
        final Bitmap bmp = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        final Canvas canvas = new Canvas(bmp);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bmp;
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private String getUserWallpaper() {
        final WallpaperManager wallpaperManager = WallpaperManager.getInstance(this);
        final Drawable wallpaperDrawable = wallpaperManager.getDrawable();

        return bitmapToBase64(getBitmapFromDrawable(wallpaperDrawable));
    }
}
