package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import io.agora.agorartcengine.AgoraRtcEnginePlugin;
import xyz.luan.audioplayers.AudioplayersPlugin;
import com.example.citypickers.CityPickersPlugin;
import io.flutter.plugins.connectivity.ConnectivityPlugin;
import yy.inc.flutter_custom_dialog.FlutterCustomDialogPlugin;
import vn.hunghd.flutterdownloader.FlutterDownloaderPlugin;
import com.example.flutter_drag_scale.FlutterDragScalePlugin;
import com.example.flutter_geetest.FlutterGeetestPlugin;
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import com.dooboolab.fluttersound.FlutterSoundPlugin;
import com.flutter_webview_plugin.FlutterWebviewPlugin;
import io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin;
import vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import com.zaihui.installplugin.InstallPlugin;
import com.crazecoder.openfile.OpenFilePlugin;
import sk.fourq.otaupdate.OtaUpdatePlugin;
import io.flutter.plugins.packageinfo.PackageInfoPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import com.baseflow.permissionhandler.PermissionHandlerPlugin;
import top.kikt.imagescanner.ImageScannerPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import com.yoozoo.sharesdk.SharesdkPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import io.flutter.plugins.urllauncher.UrlLauncherPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    AgoraRtcEnginePlugin.registerWith(registry.registrarFor("io.agora.agorartcengine.AgoraRtcEnginePlugin"));
    AudioplayersPlugin.registerWith(registry.registrarFor("xyz.luan.audioplayers.AudioplayersPlugin"));
    CityPickersPlugin.registerWith(registry.registrarFor("com.example.citypickers.CityPickersPlugin"));
    ConnectivityPlugin.registerWith(registry.registrarFor("io.flutter.plugins.connectivity.ConnectivityPlugin"));
    FlutterCustomDialogPlugin.registerWith(registry.registrarFor("yy.inc.flutter_custom_dialog.FlutterCustomDialogPlugin"));
    FlutterDownloaderPlugin.registerWith(registry.registrarFor("vn.hunghd.flutterdownloader.FlutterDownloaderPlugin"));
    FlutterDragScalePlugin.registerWith(registry.registrarFor("com.example.flutter_drag_scale.FlutterDragScalePlugin"));
    FlutterGeetestPlugin.registerWith(registry.registrarFor("com.example.flutter_geetest.FlutterGeetestPlugin"));
    FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
    FlutterSoundPlugin.registerWith(registry.registrarFor("com.dooboolab.fluttersound.FlutterSoundPlugin"));
    FlutterWebviewPlugin.registerWith(registry.registrarFor("com.flutter_webview_plugin.FlutterWebviewPlugin"));
    FluttertoastPlugin.registerWith(registry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FluttertoastPlugin"));
    ImageCropperPlugin.registerWith(registry.registrarFor("vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin"));
    ImagePickerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
    InstallPlugin.registerWith(registry.registrarFor("com.zaihui.installplugin.InstallPlugin"));
    OpenFilePlugin.registerWith(registry.registrarFor("com.crazecoder.openfile.OpenFilePlugin"));
    OtaUpdatePlugin.registerWith(registry.registrarFor("sk.fourq.otaupdate.OtaUpdatePlugin"));
    PackageInfoPlugin.registerWith(registry.registrarFor("io.flutter.plugins.packageinfo.PackageInfoPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    PermissionHandlerPlugin.registerWith(registry.registrarFor("com.baseflow.permissionhandler.PermissionHandlerPlugin"));
    ImageScannerPlugin.registerWith(registry.registrarFor("top.kikt.imagescanner.ImageScannerPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
    SharesdkPlugin.registerWith(registry.registrarFor("com.yoozoo.sharesdk.SharesdkPlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    UrlLauncherPlugin.registerWith(registry.registrarFor("io.flutter.plugins.urllauncher.UrlLauncherPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
