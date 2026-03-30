import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:outtadebt/core/utils/navigation/url_strategy/url_strategy.dart';
import 'package:outtadebt/firebase_options.dart';
import 'package:outtadebt/startup/startup_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {

  // Required before any async work in main()
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  // Initialize Firebase before the app boots.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences before the app boots.
  // We do this here not inside initializeApp() because the kit's
  // Module builder is synchronous and must run without awaiting.
  final prefs = await SharedPreferences.getInstance();

  runApp(StartupView(prefs: prefs));

}

