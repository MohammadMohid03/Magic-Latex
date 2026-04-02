import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/scan_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ScanProvider(),
      child: const DocScanApp(),
    ),
  );
}

// ==========================================
// Android Permissions (AndroidManifest.xml)
// ==========================================
// Add the following to android/app/src/main/AndroidManifest.xml, inside <manifest>:
//
// <uses-permission android:name="android.permission.CAMERA" />
// <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
// <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
// <uses-permission android:name="android.permission.INTERNET" />
//
// Also inside <application> tag, add:
// android:requestLegacyExternalStorage="true"

// ==========================================
// iOS Permissions (Info.plist)
// ==========================================
// Add the following to ios/Runner/Info.plist, inside <dict>:
//
// <key>NSCameraUsageDescription</key>
// <string>DocScan AI needs camera access to scan documents.</string>
// <key>NSPhotoLibraryUsageDescription</key>
// <string>DocScan AI needs photo library access to upload document images.</string>
// <key>NSMicrophoneUsageDescription</key>
// <string>DocScan AI may need microphone access for camera features.</string>
