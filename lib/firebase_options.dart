import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // On Flutter web builds the [defaultTargetPlatform] can sometimes report
    // a desktop platform (e.g. TargetPlatform.linux). Use kIsWeb to reliably
    // detect web and return the web FirebaseOptions.
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDu7dN9xx9nYamV479mmtm8y_69uLaBYOw',
    appId: '1:220605655822:web:4e702c1d60368c2b0b055f',
    messagingSenderId: '220605655822',
    projectId: 'ginaflashcard',
    storageBucket: 'ginaflashcard.firebasestorage.app',
    authDomain: 'ginaflashcard.firebaseapp.com',
  );
}
