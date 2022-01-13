import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

typedef ErrorCallback = void Function(dynamic e);
typedef CodeSentCallback = void Function(String verificationId);
typedef VoidStringCallback = void Function(String);
typedef VoidNullableCallback = void Function()?;
typedef BuilderWidgetFunction = Widget Function();
typedef BuilderWidgetUserFunction = Widget Function(User);
