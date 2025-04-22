import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDC8H5sq7uhNDSPNuy0e2HdHBvS1lg81hU',
    appId: '1:991927031085:android:e7bc545605ad77c8bfafa4',
    messagingSenderId: '991927031085',
    projectId: 'empettoy',
    storageBucket: 'empettoy.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDC8H5sq7uhNDSPNuy0e2HdHBvS1lg81hU',
    appId: '1:191874077722:ios:fb39ff7c3c2bdc826c6da3',
    messagingSenderId: '191874077722',
    projectId: 'toyvalley-app',
    storageBucket: 'toyvalley-app.appspot.com',
    iosClientId:
        '191874077722-c70dfhptadv3vqcr51v1dkdgb4c004c2.apps.googleusercontent.com',
    iosBundleId: 'empettoy.firebasestorage.app',
  );
}
