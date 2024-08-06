import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'sua_api_key_web_aqui',
    appId: '1:284363264618:web:b434bf8e0c8d613ec57013',
    messagingSenderId: '284363264618',
    projectId: 'ad-ipet',
    authDomain: 'ad-ipet.firebaseapp.com',
    storageBucket: 'ad-ipet.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'sua_api_key_android_aqui',
    appId: '1:284363264618:android:20948f56cf64138cc57013',
    messagingSenderId: '284363264618',
    projectId: 'ad-ipet',
    storageBucket: 'ad-ipet.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'sua_api_key_ios_aqui',
    appId: '1:284363264618:ios:aa6dc6a1e8272c9dc57013',
    messagingSenderId: '284363264618',
    projectId: 'ad-ipet',
    storageBucket: 'ad-ipet.appspot.com',
    iosBundleId: 'ipet.adocao.com.projetoipet',
  );
}
