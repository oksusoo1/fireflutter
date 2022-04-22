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
const ERROR_NOT_SIGN_IN = 'ERROR_NOT_SIGN_IN';

/// User may be signed in, but the user didn't update his profile
/// and user document under `/users` collection does not eixsts.
const ERROR_USER_DOCUMENT_NOT_EXISTS = 'ERROR_USER_DOCUMENT_NOT_EXISTS';
const ERROR_CATEGORY_EXISTS = 'ERROR_CATEGORY_EXISTS';
const ERROR_ALREADY_REPORTED = 'ERROR_ALREADY_REPORTED';
const ERROR_ALREADY_DELETED = 'ERROR_ALREADY_DELETED';
const ERROR_IMAGE_NOT_SELECTED = 'ERROR_IMAGE_NOT_SELECTED';
const ERROR_IMAGE_NOT_FOUND = 'ERROR_IMAGE_NOT_FOUND';

const ERROR_NO_PROFILE_PHOTO = 'ERROR_NO_PROFILE_PHOTO';
const ERROR_NO_EMAIL = 'ERROR_NO_EMAIL';
const ERROR_MALFORMED_EMAIL = 'ERROR_MALFORMED_EMAIL';

const ERROR_NO_FIRST_NAME = 'ERROR_NO_FIRST_NAME';
const ERROR_NO_LAST_NAME = 'ERROR_NO_LAST_NAME';
const ERROR_NO_GENER = 'ERROR_NO_GENER';
const ERROR_NO_BIRTHDAY = 'ERROR_NO_BIRTHDAY';
const ERROR_UNKNWON = 'ERROR_UNKNWON';

const COMMENT_CONTENT_DELETED = "COMMENT_CONTENT_DELETED";

/// This happens when the app tries to save(update) a field with data on user information where the field is not supported.
const ERROR_NOT_SUPPORTED_FIELD_ON_USER_UPDATE =
    'ERROR_NOT_SUPPORTED_FIELD_ON_USER_UPDATE';

const ERROR_USER_ALREADY_BLOCKED = "ERROR_USER_ALREADY_BLOCKED";
const ERROR_USER_ALREADY_UNBLOCKED = "ERROR_USER_ALREADY_UNBLOCKED";

const ERROR_NO_PHOTO_ATTACHED = 'ERROR_NO_PHOTO_ATTACHED';
