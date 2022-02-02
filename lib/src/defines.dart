import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

typedef Json = Map<String, dynamic>;

typedef ErrorCallback = void Function(dynamic e);
typedef CodeSentCallback = void Function(String verificationId);
typedef VoidStringCallback = void Function(String);
typedef VoidNullableCallback = void Function()?;
typedef BuilderWidgetFunction = Widget Function();
typedef WidgetFunction = Widget Function();
typedef WidgetFunctionCallback = Widget Function(Function);
typedef BuilderWidgetUserFunction = Widget Function(User);
// typedef MapCallback = Map<String, dynamic> Function();
typedef VoidMapCallback = void Function(Map<String, dynamic>);

const ERROR_SIGN_IN = 'ERROR_SIGN_IN';
const ERROR_CATEGORY_EXISTS = 'ERROR_CATEGORY_EXISTS';
const ERROR_ALREADY_REPORTED = 'ERROR_ALREADY_REPORTED';
