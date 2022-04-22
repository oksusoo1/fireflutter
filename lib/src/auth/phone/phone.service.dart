import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../defines.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneService {
  static PhoneService? _instance;
  static PhoneService get instance {
    _instance ??= PhoneService();
    return _instance!;
  }

  /// Selected country code.
  ///
  /// This is used for Phone Sign In UI only.
  CountryCode? selectedCode;

  /// Phone number without country dial code. used in Phone Sign In UI only
  String domesticPhoneNumber = '';

  /// Remove the leading '0' from phone number and non-numeric characters.
  String get completeNumber {
    // Remove non-numeric character including white spaces, dash,
    String str = domesticPhoneNumber.replaceAll(RegExp(r"\D"), "");
    if (str[0] == '0') str = str.substring(1);

    return selectedCode!.dialCode! + str;
  }

  /// This is used only for sign in ui.
  /// Since [PhoneService.instance] is singleton, it needs to reset progress bar also.
  bool codeSentProgress = false;
  bool verifySentProgress = false;

  ///
  String phoneNumber = '';
  String verificationId = '';
  String smsCode = '';
  int? resendToken;

  /// Get complete phone number in standard format.
  // String get completePhoneNumber => selectedCode!.dialCode! + phoneNumber;

  /// [verified] becomes true once phone auth has been successfully verified.
  bool verified = false;

  reset() {
    selectedCode = null;
    phoneNumber = '';
    domesticPhoneNumber = '';
    verificationId = '';
    smsCode = '';
    codeSentProgress = false;
    verifySentProgress = false;
    resendToken = null;
  }

  /// This method is invoked when user submit sms code, then it will begin
  /// verification process.
  Future verifySMSCode(
      {required VoidCallback success, required ErrorCallback error}) {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    return verifyCredential(credential, success: success, error: error);
  }

  /// Verify SMS code credential
  ///
  /// Logic
  ///   - User entered phone number,
  ///   - And verifyPhonenumber() is invoked,
  ///   - And sms has been sent to user
  ///   - User entered sms code,
  ///   - Then, this method is invokded.
  Future verifyCredential(
    PhoneAuthCredential credential, {
    required VoidCallback success,
    required ErrorCallback error,
  }) async {
    try {
      /// Try to sign in with the credential that comes after sms code sent.
      await FirebaseAuth.instance.signInWithCredential(credential);

      /// If there is no error, then sms code verification had been succeed.
      verified = true;

      /// Note that, when this succeed, `FirebaseAuth.instance.authStateChanges`
      /// will happen, and firebase_auth User data has the phone number.
      /// If you want to get user's phone number, you get it there.
      success();
    } catch (e) {
      error(e);
    }
  }

  /// When user submit his phone number, verify the phone numbrer first before
  /// sending sms code.
  ///
  /// on `codeSent`, move to sms code input screen since SMS code has been delivered to user.
  /// on `codeAutoRetrievalTimeout`, alert user that sms code timed out. and redirect to phone number input screen.
  /// on `error`, display error.
  /// on `androidAutomaticVerificationSuccess` handler will be called on phone verification complete.
  /// This `androidAutomaticVerificationSuccess` handler is only for android that may do automatic sms code resolution and verify the phone auth.
  Future<void> verifyPhoneNumber({
    required CodeSentCallback codeSent,
    required VoidStringCallback codeAutoRetrievalTimeout,
    required VoidCallback androidAutomaticVerificationSuccess,
    required ErrorCallback error,
  }) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        /// Automatic SMS code resolution
        ///
        /// This code is only for Android, and this method is invoked after
        /// automatic sms verification has succeed.
        /// Note that, not all Android phone support automatic sms resolution.
        verificationCompleted: (PhoneAuthCredential c) {
          verifyCredential(c,
              success: androidAutomaticVerificationSuccess, error: error);
        },
        verificationFailed: (FirebaseAuthException e) {
          // print(e);
          error(e);
        },
        codeSent: (String verificationId, resendToken) {
          this.verificationId = verificationId;
          this.resendToken = resendToken;
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (verified) return;
          codeAutoRetrievalTimeout(this.verificationId);
        },
        forceResendingToken: resendToken,
      );
    } catch (e) {
      error(e);
    }
  }
}
