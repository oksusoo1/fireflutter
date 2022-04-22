import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import '../../fireflutter.dart';

class EmailVerificationService {
  static EmailVerificationService? _instance;
  static EmailVerificationService get instance {
    _instance ??= EmailVerificationService();
    return _instance!;
  }

  /// True if the user has email on FirebaseAuth user instance.
  bool get userHasEmail {
    return email != '';
  }

  /// Email or empty string
  /// If user is not logged in, it will return empty string.
  String get email => FirebaseAuth.instance.currentUser?.email ?? '';

  bool get userHasPhoneNumber => phoneNumber != '';

  /// Phone number or empty string.
  String get phoneNumber =>
      FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

  Timer? timer;
  late int _verificationIntervalSeconds;
  late Function _onVerified;
  late Function _onVerificationEmailSent;
  late Function _onTooManyRequests;
  late Function _onUserTokenExpired;

  late ActionCodeSettings? _actionCodeSettings;

  /// Initialize the service and run email verification checker.
  ///
  /// It will unsubscribe / stop when:
  ///  A. Email verification process is done.
  ///  B. When it is no longer needed to watch.
  ///   - User cancels the operation by pressing cancel button.
  ///   - User leaves the screen.
  ///  B. 1.
  ///   - What if it had unsubscribed(cancelled) before email had verified?
  ///     - Most of the case, when it had unsubcribed, the user is no longer
  ///       interested in verifying the email address. It's just fine.
  ///       And if the user click the verification link later, that is just fine
  ///       also.
  ///
  /// Run email verification checker on entering the screen like inside initState()
  /// It would be also fine to start email verification checker only when
  /// the email verification button had pressed. But it is recommended to run
  /// immediately on entering the screen.
  init({
    required Function onVerified,
    int verificationIntervalSeconds = 3,
    required Function(dynamic) onError,
    required Function onVerificationEmailSent,
    required Function onTooManyRequests,
    required Function onUserTokenExpired,
    ActionCodeSettings? actionCodeSettings,
  }) {
    _verificationIntervalSeconds = verificationIntervalSeconds;
    _onVerified = onVerified;
    _onVerificationEmailSent = onVerificationEmailSent;
    _onTooManyRequests = onTooManyRequests;
    _onUserTokenExpired = onUserTokenExpired;
    _actionCodeSettings = actionCodeSettings;

    /// Whether the user is verifying or not, don't run verification checker on init.
    /// Once email verification checker runs, it will automatically invoke the callback function `onVerified` if the user's email is verified.
    /// `onVerified` will run even if the user is just changing their email.
    ///
    /// Run email verification checker
    // _emailVerificationChecker();
  }

  _emailVerificationChecker() {
    if (timer != null) timer!.cancel();
    timer = Timer.periodic(
      Duration(seconds: _verificationIntervalSeconds),
      (_t) async {
        // print('check verification result');

        if (FirebaseAuth.instance.currentUser == null)
          throw 'User has not signed in.';

        /// Note, if there is no internet, 'firebase_auth/network-request-failed' error will be happened.
        try {
          await FirebaseAuth.instance.currentUser!.reload();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-token-expired') {
            /// The user's credential is no longer valid. The user must sign in again.
            _t.cancel();
            _onUserTokenExpired();
          } else {
            rethrow;
          }
        } catch (e) {
          rethrow;
        }
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          _t.cancel();
          timer = null;
          _onVerified();
          UserService.instance.user.updateUpdatedAt();
        }
      },
    );
  }

  /// Stop email verification checker when
  /// 1. email had verified
  /// 2. user is not interested in verifying email address
  ///   - like when user leaves the screen.
  ///
  dispose() {
    if (timer != null) timer!.cancel();
  }

  sendVerificationEmail() async {
    /// Once email update is successful, send an email verification.
    try {
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        throw 'Email address had already verified.';
      }
      await FirebaseAuth.instance.currentUser!
          .sendEmailVerification(_actionCodeSettings);
      _onVerificationEmailSent();
      _emailVerificationChecker();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        _onTooManyRequests();
      } else {
        rethrow;
      }
    }
  }
}
