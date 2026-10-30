import 'dart:convert';

/// Placeholder Firebase config files.
///
/// The strings are valid JSON / XML. Create used to embed `///` comments
/// inside these files, which made `google-services.json` unreadable. Both
/// project creation and `xproject setup firebase` call these helpers.
///
/// Existing files are never overwritten by the setup command: a developer may
/// already have replaced the placeholder with a download from Firebase Console.
abstract final class FirebaseNativeFiles {
  /// `google-services.json` for one Android application id.
  static String googleServicesJson(String packageName) {
    final payload = <String, Object>{
      'project_info': <String, String>{
        'project_number': 'YOUR_PROJECT_NUMBER',
        'project_id': 'YOUR_PROJECT_ID',
        'storage_bucket': 'YOUR_STORAGE_BUCKET',
      },
      'client': <Object>[
        <String, Object>{
          'client_info': <String, Object>{
            'mobilesdk_app_id': 'YOUR_APP_ID',
            'android_client_info': <String, String>{
              'package_name': packageName,
            },
          },
          'api_key': <Object>[
            <String, String>{'current_key': 'YOUR_API_KEY'},
          ],
        },
      ],
      'configuration_version': '1',
    };
    return '${const JsonEncoder.withIndent('  ').convert(payload)}\n';
  }

  /// `GoogleService-Info.plist` for one iOS bundle id.
  static String googleServiceInfoPlist(String bundleId) {
    final escaped = _xml(bundleId);
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CLIENT_ID</key>
	<string>YOUR_CLIENT_ID</string>
	<key>REVERSED_CLIENT_ID</key>
	<string>YOUR_REVERSED_CLIENT_ID</string>
	<key>API_KEY</key>
	<string>YOUR_API_KEY</string>
	<key>GCM_SENDER_ID</key>
	<string>YOUR_GCM_SENDER_ID</string>
	<key>PLIST_VERSION</key>
	<string>1</string>
	<key>BUNDLE_ID</key>
	<string>$escaped</string>
	<key>PROJECT_ID</key>
	<string>YOUR_PROJECT_ID</string>
	<key>STORAGE_BUCKET</key>
	<string>YOUR_STORAGE_BUCKET</string>
	<key>IS_ADS_ENABLED</key>
	<false/>
	<key>IS_ANALYTICS_ENABLED</key>
	<false/>
	<key>IS_APPINVITE_ENABLED</key>
	<true/>
	<key>IS_GCM_ENABLED</key>
	<true/>
	<key>IS_SIGNIN_ENABLED</key>
	<true/>
	<key>GOOGLE_APP_ID</key>
	<string>YOUR_GOOGLE_APP_ID</string>
</dict>
</plist>
''';
  }

  static String _xml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
