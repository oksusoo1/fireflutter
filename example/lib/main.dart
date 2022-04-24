import 'dart:async';
import 'dart:developer';

import 'package:example/screens/home/home.screen.dart';
import 'package:example/services/app.router.dart';
import 'package:example/services/global.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = (FlutterErrorDetails details) {
      /// Flutter exceptions come here.
      log("--> FlutterError.onError : from (the inside of) Flutter framework.");
      log("------------------------------------------------------------------");
      FlutterError.dumpErrorToConsole(details);
      service.error(details.exception);
    };
    runApp(const ExampleApp());
  }, (error, stackTrace) {
    /// Firebase exceptions and dart(outside flutter) exceptions come here.
    log("--> runZoneGuarded() : exceptions outside flutter framework.");
    log("------------------------------------------------------------");
    log("--> runtimeType: ${error.runtimeType}");
    log("Dart Error :  $error");
    log("StackTrace :  $stackTrace");
    service.error(error);
  });
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  @override
  void initState() {
    super.initState();
    UserService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: HomeScreen.routeName,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
