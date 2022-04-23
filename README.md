![FireFlutter](https://raw.githubusercontent.com/thruthesky/fireflutter/main/readme/images/logo2.png?raw=true)

# Fire Flutter

A free, open source, complete, rapid development package for creating Social apps, Chat apps, Community(Forum) apps, Shopping mall apps, and much more based on Firebase.

- Complete features.\
  This package has complete features (see Features below) that most of apps require.

- Simple, easy and the right way.\
  We want it to be deadly simple yet, right way for ourselves and for the developers in the world. We know when it gets complicated, our lives would get even more complicated.

- Real time.\
  We design it to be real time. All the events like post and comment creation, voting(like, dislike), deletion would appears on all the user's phone immediately after the event.

- I am looking for community devleopers who can join this work. Please email me at thruthesky@gmail.com

- Please post your issues at https://github.com/thruthesky/fireflutter/projects/1

Table of contents

- [Fire Flutter](#fire-flutter)
- [Installation](#installation)
  - [Install fireflutter package](#install-fireflutter-package)
  - [Firebase Installation](#firebase-installation)
  - [Running the example](#running-the-example)
  - [Firebase Realtime Database Security Rules Installation](#firebase-realtime-database-security-rules-installation)
  - [Firebase Storage installation](#firebase-storage-installation)
  - [Firestore installation](#firestore-installation)
    - [Setting admin on firestore security rules](#setting-admin-on-firestore-security-rules)
  - [Cloud functions installation](#cloud-functions-installation)
    - [Run cloud function using shell](#run-cloud-function-using-shell)
- [Sources and packages](#sources-and-packages)
- [Coding Guideline](#coding-guideline)
- [Examples of fireflutter](#examples-of-fireflutter)
- [User](#user)
  - [User installation](#user-installation)
  - [User data and user profile](#user-data-and-user-profile)
  - [UserModel](#usermodel)
  - [UserService](#userservice)
  - [User setting service](#user-setting-service)
  - [Profile ready](#profile-ready)
  - [Phone number sign-in](#phone-number-sign-in)
  - [Email authentication under phone sign-in](#email-authentication-under-phone-sign-in)
    - [Email authentication under phone sign-in logic](#email-authentication-under-phone-sign-in-logic)
      - [When user has an email already](#when-user-has-an-email-already)
- [Admin](#admin)
  - [Admin status check & update](#admin-status-check--update)
- [Translation](#translation)
  - [Get translated text](#get-translated-text)
  - [Tr](#tr)
- [User presence](#user-presence)
  - [User presence overview](#user-presence-overview)
  - [User Presence Installation](#user-presence-installation)
  - [User presence logic](#user-presence-logic)
  - [Displaying user profile](#displaying-user-profile)
    - [MyDoc](#mydoc)
    - [UserDoc](#userdoc)
  - [User Auth State](#user-auth-state)
- [Chat](#chat)
  - [Chat todo;](#chat-todo)
  - [Chat structure of Firestore](#chat-structure-of-firestore)
  - [Chat logic](#chat-logic)
    - [Chat logic - block](#chat-logic---block)
- [Reminder](#reminder)
  - [Reminder code sample](#reminder-code-sample)
  - [Reminder input data & logic](#reminder-input-data--logic)
- [FriendMap](#friendmap)
  - [FriendMap installation](#friendmap-installation)
  - [FriendMap logic](#friendmap-logic)
    - [FriendMap informing logic](#friendmap-informing-logic)
  - [FriendMap testing](#friendmap-testing)
- [Inform](#inform)
  - [Informing logic](#informing-logic)
  - [Inform data](#inform-data)
  - [Use of inform](#use-of-inform)
- [For developer](#for-developer)
  - [Building your app](#building-your-app)
  - [Building fireflutter](#building-fireflutter)
  - [Updating fireflutter while building your app](#updating-fireflutter-while-building-your-app)
- [Test](#test)
  - [Test users](#test-users)
  - [To test user functionality](#to-test-user-functionality)
  - [Test method](#test-method)
  - [Local test on firestore security rules](#local-test-on-firestore-security-rules)
- [Sample code](#sample-code)
- [Node.js Utilities](#nodejs-utilities)
  - [User utilities](#user-utilities)
  - [Forum utilities](#forum-utilities)
    - [Deleting posts, comments, and uploaded files in a category.](#deleting-posts-comments-and-uploaded-files-in-a-category)
- [Issues](#issues)
  - [firebase_database/permission-denied](#firebase_databasepermission-denied)
  - [Firebase realtime database is not working](#firebase-realtime-database-is-not-working)
  - [firebase_auth/internal-error](#firebase_authinternal-error)
  - [Unauthorized permission error on storage.](#unauthorized-permission-error-on-storage)
- [Dyanmic Links Service](#dyanmic-links-service)
  - [Installation](#installation-1)
    - [Installation on Anroid](#installation-on-anroid)
    - [Installation on iOS](#installation-on-ios)
  - [Dynamic Links - Coding guide lines](#dynamic-links---coding-guide-lines)
    - [Terminated app](#terminated-app)
    - [For background(or foreground) apps](#for-backgroundor-foreground-apps)
  - [Test Dynamic Links](#test-dynamic-links)
- [Reports](#reports)
- [Forum](#forum)
  - [Category](#category)
    - [Subcategory](#subcategory)
    - [Category menu group](#category-menu-group)
  - [Post](#post)
  - [Comment](#comment)
  - [PostService and PostApi](#postservice-and-postapi)
  - [PostApi](#postapi)
- [Push notification](#push-notification)
  - [terms](#terms)
  - [How push notification wokr.](#how-push-notification-wokr)
  - [push notification logic](#push-notification-logic)
  - [Testing Push notification via terminal](#testing-push-notification-via-terminal)
- [Fil upload - Firebase Storage](#fil-upload---firebase-storage)
  - [pickUpload](#pickupload)
  - [Delete uploaded image](#delete-uploaded-image)
  - [FileUploadButton](#fileuploadbutton)
  - [Displaying Uploaded Image](#displaying-uploaded-image)
  - [Uploaded file management](#uploaded-file-management)
- [Location Service](#location-service)
- [Cloud Functions](#cloud-functions)
  - [Unit test for Cloud Functions](#unit-test-for-cloud-functions)
  - [Error handling](#error-handling)
    - [How to send error back to client](#how-to-send-error-back-to-client)
    - [Error handling on client end](#error-handling-on-client-end)
  - [Cloud functions - http trigger, restful api.](#cloud-functions---http-trigger-restful-api)
    - [Ready](#ready)
    - [Request and data handling](#request-and-data-handling)
    - [Post create](#post-create)
    - [Cloud functions Sample codes](#cloud-functions-sample-codes)
  - [Meilisearch](#meilisearch)
  - [Re-indexing documents](#re-indexing-documents)
- [Backup](#backup)
  - [Firestore backup](#firestore-backup)
- [Point](#point)
  - [Point settings](#point-settings)
  - [Poitn Event Logic](#poitn-event-logic)
  - [Category point setting](#category-point-setting)
  - [Point document](#point-document)
  - [Displaying Point](#displaying-point)
    - [Use point property to dispaly point.](#use-point-property-to-dispaly-point)
    - [PointBuilder](#pointbuilder)
    - [MyPointBuilder](#mypointbuilder)
    - [ForumPoint](#forumpoint)
  - [Point history](#point-history)
  - [Displaying point history](#displaying-point-history)
  - [Senario](#senario)
  - [User point and level](#user-point-and-level)
- [Extra Features](#extra-features)
  - [Job](#job)
- [Release mode error](#release-mode-error)
  - [How to fix](#how-to-fix)

# Installation

## Install fireflutter package

- Add the laste version of fireflutter into pubspec.yaml
- You may edit platform version to `platform :ios, '11.0'` in Podfile for firestore and firebase auth.


## Firebase Installation

- See the official document of [Using the FlutterFire CLI](https://firebase.flutter.dev/docs/overview#using-the-flutterfire-cli)

- After installing firebase, you will see `<fireflutter>/example/lib/firebase_options.dart` that is not stored on github since it is excepted by `.gitignore`.

- If you prefer to install manually (which is not recommended), you can follow [Manual Installation](https://firebase.flutter.dev/docs/manual-installation)


## Running the example

- Do the [Firebase installation](#firebase-installation).
- Git fork the [fireflutter](https://github.com/thruthesky/fireflutter).
- Run the example in `<fireflutter>/example/lib/main.dart`.
  - See the [examples of fireflutter](#examples-of-fireflutter)

## Firebase Realtime Database Security Rules Installation

- To install Firebase Realtime Database, enable it on Firebase console and put the security rules.

- Note, if you enable `Firebase Realtime Database`, you have to re-download and update the `GoogleService-Info.plist`.

  - You may need to update the `GoogleService-Info.plist` after enabling other features of the Firebase.

- Add the following security rules on firebase realtime database

```json
{
  "rules": {
    "presence": {
      ".read": true,
      "$uid": {
        ".write": true
      }
    },
    "inform": {
      "$uid": {
        ".read": true,
        ".write": true
      }
    },
    "users": {
      ".read": true,
      ".indexOn": ["disabled", "profileReady"],
      "$uid": {
        ".write": "$uid === auth.uid"
      }
    },
    "user-settings": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "settings": {
      "$docId": {
        ".read": true,
        ".write": true
      }
    },
  	"message-tokens": {
      ".indexOn": ["uid"],
      ".read": true,
      ".write": true
    },
    "point": {
      ".read": true,
        "$uid": {
          "$eventName": {
            ".indexOn": "timestamp"
          }
        }
    },
    "log": {
      ".read": true,
      ".write": true
    },
    "tests": {
      ".read": true,
      ".write": true
    }
  }
}
```

## Firebase Storage installation

- Install 'Image Resize' firebase extension with the following settings;

  - Upgrade billing plan
  - This extension will use cloud function. It will install `generateResizedImage` function.
  - Cloud functions location: Choose the same location as your project.
  - Cloud Storage bucket for images: don't touch(or use it as it is).
  - Sizes of resized images: 200x200
  - Deletion of original file: No
  - Cloud Storage path for resized images: leave it empty.
  - Paths that contain images you want to resize: /uploads
  - List of absolute paths not included for resized images: leave it empty.
  - Cache-Control header for resized images: max-age=86400
  - Convert image to preferred types: webp
    Note, that you can see the configuration in firebase extensions menu and reconfigure it.
    Note, that you can see the location in firebase cloud functions menu.

- Copy the following rules and paste it into the storage rules section.

```js
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
    	allow read: if request.auth!=null || resource.contentType.matches('image/.*');
      allow create: if willBeMine() && checkType() && lessThan(10);
      allow update: if isMine() && checkType();
      allow delete: if isMine();
    }
  }
}

function willBeMine() {
	return request.auth != null && request.resource.metadata.uid == request.auth.uid;
}

function isMine() {
	return request.auth != null && resource.metadata.uid == request.auth.uid;
}

function lessThan(n) {
	return request.resource.size < n * 1024 * 1024;
}

function checkType() {
	return request.resource.metadata.type == 'post' || request.resource.metadata.type == 'comment' || request.resource.metadata.type == 'user' || request.resource.metadata.type == 'chat';
}
```

## Firestore installation

- Enable firestore.
- Copy the [firestore securiy rules](https://raw.githubusercontent.com/thruthesky/fireflutter/main/firebase/firestore.rules) and update it on your firebase project.
- To install the firestore indexes, it is recommended to run the query and click the link of it to generate the indexes.

  - To do this, just call `getFirestoreIndexLinks` method and it will print the link on debug console. You just need to click the links.
    - See example of `getFirestoreIndexLinks` in the [example home screen](https://github.com/thruthesky/fireflutter/blob/main/example/lib/screens/home/home.screen.dart).
  - See the [firestore indexes](https://raw.githubusercontent.com/thruthesky/fireflutter/main/firebase/firestore.indexes.json) and if you want to update it manually on your firebase project.

- We use Firestore only for `Chat` and `Forum` features since they needs more support on query and search functionalities.
  - All other features should go to realtime database.

- Note that, you need to create your own composite indexes when you build functions that query on fields that are not indexed by fireflutter.
  - For instance, you make a function for getting posts that have most no of comments on this year. then, you may need to create an composite index with `noOfComments` and `year`.

### Setting admin on firestore security rules

- To set a user admin, Add the user's UID as field name(key) with the value of `true` in `/settings/admin`.
  - For instance, `{ "UID_AAA": true, "UID_BBB": true }`, then users whose uid is UID_AAA and UID_BBB are the admins.

![Security Rules Admin](https://raw.githubusercontent.com/thruthesky/fireflutter/main/readme/images/security-rules-admin.jpg?raw=true)




## Cloud functions installation

- We only use functions for the work that cannot be done by client end like sending push notifications.

  - We don't use cloud functions simply because we want to avoid multiple read and write on documents and to the logic simple in the client end.

- To install,
  - `cd firebase/functions`
  - `npm i`
  - `firebase deploy --only functions`



### Run cloud function using shell

```sh
$ cd firebase/functions
$ cd npm i
$ npm i -g firebase-tools
$ export GOOGLE_APPLICATION_CREDENTIALS=../firebase-admin-sdk-key.json
$ npm run shell
```

# Sources and packages

- [Jiffy](https://github.com/jama5262/jiffy/tree/master/doc) is used for date and time.

# Coding Guideline

- The file name of all model end with `xxxx.model.dart`
- All model have `.data` property (getter) to export its model data to a map which then can be saved into firestore.
  - Note, that `.data` must contain only the data to be saved in firestore.
- All model should have `.map` property(getter) to export its model data to a map. while `.data` only contains for saving firestore, `.map` may contain other values.


# Examples of fireflutter

- We put some easy to follow sample code in branches. Here are some
  - [example-setup](https://github.com/thruthesky/fireflutter/tree/example-setup) for the simplest code to run fireflutter.



# User
## User installation


- To make this happen,
  - for Android, SHA1 must be registered on debug mode.
  - for iOS,
    - push notification must be enabledand (URL scheme must be set on Xcode.
      - `Open Xcode by dobule clicking on example/ios/Runner/Runner.xcworkspace`.
      - `Add Push Notifications` under Signing & Capabilities.
      - `Add App ID into URL Scheme` under Info. Use `app-....` format.
    - APNs auth key should configured with FCM seeting in Firebase.

- Note, when you install with `flutterfire configure`, you don't need to input `REVERSED_CLIENT_ID` and `BUNDLE_ID` for sign-in with phone number.

- `UserService` needs to be called immediately after app boots to create and update user profile in realtime database.
  - Simply call `UserService.instance.init()` in `main.dart` after Firebase has initialized.


## User data and user profile

- User email and phone number are saved in firebase auth. So, use `UserService.instance.email` or `UserService.instance.phoneNumber` to get email or phone number.
- Other user properties (like name, photo url, birthday, etc) are saved in `/users` inside realtime database.

- Many apps share user name and photo. For instance, when a user chat to the other user, they shoud know each other's name and photo. Or on post list screen, there should be author name and photo on each post or comment.

  - User information would be displayed as extra information on chats, posts, comments, public profiles, and so on. Realtime database costs by GB download that is cheap enough to use it as normalized. But it would cost a lot how you use it.

- Warning, we do not denormalize user data. That means, user name will not be copied into other documents. Instead, the app will simply read `/users/<uid>` document whenever user data is needed. In this way, data integrity is guranteed. But often, more data will be downloaded and it will cost more money.

  - So, keep `/users/<uid>` slim. Try to keep only the following fields.
    - `birthday`
    - `gender`
    - `firstName`, `middleName`, `lastName`, `nickname`
    - `photoUrl`
    - `registeredAt`
    - `updatedAt`
      And think over again if it is really needed when you are trying to add another field.
  - Don't put user's setting data in `/users/<uid>`. Use may use `UserModel.updateSettings()` and `UserModel.readSettings()` to manage user's setting.

- Use `MyDoc` to display my profile data.

## UserModel


- Note that, If the app knows only user's uid, then it can create user model and use some of the user model's methods.

```dart
/// Put user uid on UserModel, and the app can use the model's member methods already.
user = UserModel(uid: uid);

/// Update last sign in stamp
user.updateLastSignInAt();

/// Load user data and set it into member variables.
await user.load();

/// Print user properties.
print(user);
```

## UserService

- The reason why we need `UserService` is to hold login user's `UserModel` and update it on user document's changes.


## User setting service


- User settings are saved under `/user-settings/<uid>` in realtime database.
- `UserSettinService` is handling the update of user setting.
- `UserSettinService.instance.changes` event is posted whenever user's setting is changed.
- `UserSettinService` is used in many places.
  - It` is connected to `UserModel.settings`.
  - It has methods for handling push notification topics.
- Best way to use it
  - Use with `changes` stream to display user setting.
  - To update, simple call `UserSettingsService.instance.update({ 'key': 'value', 'key': ... })`
  - Then, to apply the changes anywhere simple use `StreamBuilder(stream: UserSettingsService.instance.changes.stream, ... )`.
    With this way, app does not need state management.


- Use `UserSettingDoc` to apply user settgins instread of using `StreamBuilder`.

```dart
Widget build(BuildContext context) {
  return UserSettingDoc(builder: (settings) {
    final bool selected = settings.value('home-menu-category');
    // ...
  }
```

```dart
UserSettingDoc(
  builder: (settings) {
    return Text('settings; ${settings.value('forum-top-category')}');
  },
)
```


## Profile ready

- When user completes to update his profile, the app sets the user's profile field to be an int.
  - The criteria of user profile properties are in `UserModel.profileError`. If any of this property is missing, the profile is not ready.

- `UserService` is listening user's profile change. And when user updates his profile, it sets an int value to `profileReady` and with that int value, app can order(sort) by user's registered date.
  - Logic of setting `profileReady` value.
    - When user first registered, it sets `90000000000000` and it means, the profile is not ready, yet.
    - When user update his profile and completes, it sets `90000000000000 - registeredAt`
    - And when user changes his profile, user profile may be ready or not(on and off), and when it becomes not ready, it will be set back to `90000000000000`.
    - So, it is sortable by registeredAt.
  - So, if you want to dispaly new users who completed their profile, use `.orderByChild('profileReady').limitToLast(100)`.


- To know if user's profile is ready or not, use `UserModel.ready` boolean variable.


## Phone number sign-in

![Phone Sign In UI](https://raw.githubusercontent.com/thruthesky/fireflutter/main/readme/images/phone-sign-in-ui.jpg?raw=true)

- In most cases, you want to use `Firebase Flutter UI` for `Firebase Sign-In` and that's very fine.
  But with the `Phone Sign-In` built in UI, it's not easy to handle errors. So, fireflutter provides simple service for phone sign in.

- To use phone sign-in, enable it. (and add some test phone numbers if you wish to test with test phone numbers.)

- `PhoneService` has the service code of phone sign-in.

  - See [example/lib/phone_sign_in](https://github.com/thruthesky/fireflutter/tree/main/example/lib/screens/phone_sign_in) folder for sample code. You can copy paste it in your projects.

- Fireflutter also provides UI widgets to make it easy to use in your app.
  - Simply add `PhoneNumberInput` widget to your screen and on code sent, move to sms code input page and add `SmsCodeInput` widget.
  - See [example/lib/phone_sign_in_ui](https://github.com/thruthesky/fireflutter/tree/main/example/lib/screens/phone_sign_in_ui) foler for sample code.

Example of verifying phone number. Note this example is only for short sample codes.

```dart
PhoneService.instance.phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber!;
PhoneService.instance.verifyPhoneNumber(
  /// Once verification code is send via SMS, show a dialog input for the code.
  codeSent: (verificationId) => Get.defaultDialog(
    title: 'Enter SMS Code to verify it\'s you.',
    content: SmsCodeInput(
      success: () async {
        /// User logged in.
        Get.back();
      },
      error: error,
      submitButton: (callback) => TextButton(
        child: const Text('Submit'),
        onPressed: callback,
      ),
    ),
  ),
  success: () => Get.back(),
  error: error,
  codeAutoRetrievalTimeout: (String verificationId) {
    Get.defaultDialog(
      middleText:
          'SMS code timeouted. Please send it again',
      textConfirm: 'Ok',
    );
  },
);
```

## Email authentication under phone sign-in

- This `email authentication under phone sign-in` feature is only the case that the user logged in with `phone sign-in`. It may be used in other cases. But we consider the `email authentication` with `phone sign-in` only since we have `phone sign-in` service.

### Email authentication under phone sign-in logic

#### When user has an email already

- User can update email or verify without updating email.

- Before email verification screen,

  - Show `verify email` button when user has email but not verified.
  - Show `update email` button when user has
    - no email or
    - has verified email.

- When button is pressed, move to email verification screen
  - Show `verify email` button if the user has email but not verified.
  - Show `disabled update email` button if email is not changed, yet or has verified email.
    - Enable `update email` if email changes.
      - Note, when new email address is updated to Firebase auth, then, the status of `FirebaseAuth.instance.currentUser!.emailVerified` becomes automatically `false`.
        - And even if the user changed the email back to the original email address, still, email verification status will be set to `false`.
    - When `update email` button pressed,
      - Save email,
        - If `requires-recent-login` exception happens,
          - Send mobile number verification code
          - And display sms input code.
      - And, send verification email
      - Then, listen if email is verified.
      - If verified, alert and go home.

# Admin

- All the admin functionality must be written in Flutter since Flutter is the main framework for fireflutter.



## Admin status check & update

`UserService.instance.updateAdminStatus()` updates wether the user is an admin or not.

- Why; when user logs in, to know if the user is admin or not, the app must do an extra read on firestore document. And it costs money.
- How; this method will update `isAdmin` to true if he is admin or false if not.
- ide effect; there may be cases that `isAdmin` is set to true when the user is no longer an admin. In that case, UI may show admin buttons but the actions will fail based on the security rules.
- Usage; call this method when user enters admin page or on any demand.
- Recommendation; Put a secret(fake) widget like 'app version' that displays app version. And when user do 3 taps and long press, redirect the user to admin screen and call `updateAdminStatus()` on entering admin screen.
- after calling `updateAdminStatus()`, the user's document will have `isAdmin: true` if the user is admin.


# Translation

- Translation texts are saved in `/settings/translations` on realtime database.
  - The format of text field is like below. 
    - `{ name: { en: 'Name', ko: '이름' }, ... }`


- There is a sample code for updating translation texts. App can use `TranslationService.instance.showForm` to show the form.

- The translation texts are loaded on the constructor of `TranslationService` and the constructor will be run on first use of `TranslationService.instnace`.


- Common fitfall,
  - When the app use `tr` method for the first time on home screen, the translation text would probably not loaded yet.
  So, it will simply return the input text instread of translated text.
    - To solove this problem, it is one way to re-render home screen on `TranslationService.instance.changes` event happens.
    - Other subsequently loaded pages, (if `tr` method was used on home screen or translated texts are already loaded), `tr` would return translated texts.
    - Or for home screen, it would be better to use `Tr` widget instead of using `tr()` method.


## Get translated text

- To get the translated text, do the following.

```dart
TranslationService.instance.tr('ERROR')
```


## Tr

- You can use `Tr` widget to display the translated text.
  - `Tr` widget support all the text properties.

- Since `Tr` widget is a stream builder listenning changes of the text in realtime database, when translataion texts are updated, `Tr` would re-render immedialy.
    - Meaning, when `/settings/translation` changes, it will instantly update the text of `Tr` widget.

```dart
Tr('name', style: ...);
```




# User presence

## User presence overview

![User Presence](https://raw.githubusercontent.com/thruthesky/fireflutter/main/readme/images/user-presence.jpg?raw=true)

- More often, people want to know if their friends are online or not. Use this feature to know who is online. It has three status; 'online', 'offline', and 'away'.

## User Presence Installation

- To make it work, install

  - [Firebase Installation](#firebase-installation)
  - [Firebase Realtime Database Installation](#firebase-realtime-database-installation)

- To begin with the presence functionality of users, call `Presence.instance.activate()`.
- To stop(deactivate) the presence functionality, call `Presence.instance.deactivate()`.

```dart
class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    Presence.instance.activate();
  }

  @override
  void dispose() {
    super.dispose();
    Presence.instance.activate(
      onError: (e) => print('--> Presence error: $e'),
    );
  }
}
```

- To know if a user is online, offline or away, use `UserPresence` widget.

```dart
UserPresence(
  uid: uid,
  builder: (PresenceType type) => Row(
    children: [
      Icon(
        Icons.circle,
        color: type == PresenceType.online
            ? Colors.green
            : (type == PresenceType.offline ? Colors.red : Colors.yellow),
      ),
      Text(type.name),
    ],
  ),
),
```

## User presence logic

- Run `Presence.instance.activate()` at start if you want to track the presence status of users.
- If user didn't login to the device, the user will be offline by default.
- If `Presence` is working, you will see the record in firebase realtime database data section in firebase console.
  - If no documents appears in firebase realtime database data section, then see the installation and issues.
- `/presense/$uid` document will be written only when user logs in and out.
- When app is closed, the user will be offline.

## Displaying user profile

### MyDoc

- To display a user profile(name or photo), Use `MyDoc` widget that has builder function to build a widget based on the user profile data.

- For the efficiency, `MyDoc` does not listen to the realtime database document change on every instance, since reading the document over and over again may cost a lot of money if it is used in many places.
  - It listens `UserService.instance.changes` event which only read one time on every user document change.
  - By doing this, `MyDoc` may be used for the replacement of state management.

- `MyDoc` displays nothing when the user is not signed in.

```dart
MyDoc(
  builder: (UserModel u) {
    return Row(
      children: [
        Text('name: ${u.displayName}'),
        Text(', profile: ${u.photoUrl}'),
      ],
    );
  },
),
```

- Some use cases of `MyDoc`
  - When user had signed-in Firebase, `auth changes` event happens immediately while the user's document is not available in `UserService.instance`
    - For instance, when app restart, the user signs in to `Firebase Auth` very quickly, and then, `UserService` begins to work to get user document into `UserService.instance.user`. So, user document is not available at the time of user sign in.
      But it is safe to use `MyDoc` since it has default empty values until it reads the document for the first time after sign-in.
    - To know if the user is admin or not, user document must be downloaded from database.
    - When user document will updated on every document change, and `MyDoc` will update its child widgets. So, `MyDoc` is a perfect solution to use as state manage based on user data change.

### UserDoc

- To display a other user profile, use `UserDoc` widget. `UserDoc` does not listen to the document changes. It is one time read. And it is one time read only for all the app session. That means, it is caching user document and when `UserDoc` is re-used in other places, it does not read the user data again. In this way, it can save money.

  - For instance, when user scroll up and down on post list screen, the app has to read and download user document over again for the same post since flutter removes widget if it is invisible in list view. With `UserDoc`, you can display other user's data without worry of cost.

- `UserDoc` may be used for displaying signed-in user. Especially for forms.

```dart
UserDoc(
  uid: user.uid,
  builder: (UserModel u) {
    return Row(
      children: [
        Text('name: ${u.name}'),
        Text(', profile: ${u.photoUrl}'),
      ],
    );
  },
),
```

- Note, to display if the user is online or offline, see user presence.

## User Auth State

- Build and display widgets based on user's auth state changes.

```dart
 AuthState(
   signedIn: (user) => Text('logged in'),
   signedOut: () => Text('logged out'),
   loader: Text('loading...'),
 ),
```

# Chat

## Chat todo;

- when A enters a room with B, check if they are blocked. If yes, dispaly a warning.
- when sending message fails, check if they are block and warn properly.
  - for instance, A request FriendMap to B, and A cannot send message to B since they are blocked. Then, display proper warning like "failed due to blocked" instead of meaning less message like "failed or permission denied."

## Chat structure of Firestore

- `/chat/messages/<uid>__<uid>` is the collection of a chat room messages. Each document in this collection is the chat message documents that are handled by the `ChatMessageModel`. This is called `message doc`.

- `/chat/rooms/<uid>` is the collection of a user's chat friends. The documents inside this collection are the users that he chatted. For instance,
  - `/chat/rooms/<uid>/<uid>` is the document of a chat room. This document has the room information. (This is called `room info doc`.) For instance,
    - `/chat/room/A/B`
    - `/chat/room/A/C`
      Then, the user `A` have had chat with user B and C.
      Note that, `room info doc` is also handled by the `ChatMessageModel`.

## Chat logic

- If it needs a speed to work, then just rely on the security rules without check permission before action.

  - For instance, when A sends a message to B, it needs a speed. So, don't check if A is allowed to send message to B before it fails.
    - Once it fails to send the message, then check what causes the problem.

- If it does not need speed, then the app may check permission first.
  - For instance, blocking a user does not need a speed. so, the app can check if the user can be blocked before it fails by security rules.

### Chat logic - block

- Setting `blocked` properties in room info doc - `/chat/rooms/<uid>/<uid>.blocked: true` is not working deu to the `inequality` feature of Firestore.

  - You can order by `timestamp` where `blocked == true`. It's against `inequality` rule.

- To solve this,

  - remove blocked user's room info from `/chat/rooms/<my>/<other>`
  - save user uid at `/chat/blocked/<my>/<other>.timestamp`.

- When A blocked to B, both cannot send message to each other.

# Reminder

![Reminder](https://raw.githubusercontent.com/thruthesky/fireflutter/main/readme/images/reminder.jpg?raw=true)

- `ReminderService` is to remind some to users with custom UI.

  - When the app has some to remind its users, push notification may be one option.
    - But push notification does not deliver reminders to the users who registered after sending notifications.
    - And it does not have an option like 'remind me later`.
  - `ReminderService` can do this.

- It uses `/settings/reminder` document.
  - It is not recommended to edit the docuement directly insdie firebase console.
- `ReminderEdit` widget is a sample code for updating the document. you can customize by copy & paste.
- And `ReminderService.instance.display()` is the default UI to display reminder on app screen. You can also customize the UI by copy & paste.

## Reminder code sample

- To display reminder dialog when there is a reminder, use the code below.

```dart
/// Define global key somewhere.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey();


/// Apply it to MaterialApp.
class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            navigatorKey: navigatorKey,
          );
  }
}

/// Listen to reminder
///
/// Delay 3 seconds. This is just to display the reminder dialog 3 seconds
/// after the app boots. No big deal here.
Timer(const Duration(seconds: 3), () {
  /// Listen to the reminder update event.
  ReminderService.instance.init(onReminder: (reminder) {
    /// Display the reminder using default dialog UI. You may copy the code
    /// and customize by yourself.
    ReminderService.instance.display(
      /// Use the global NavigatorState to display dialog.
      context: navigatorKey.currentContext!,
      data: reminder,
      onLinkPressed: (page, arguments) {
        Get.toNamed(page, arguments: arguments);
      },
    );
  });
});
```

- For updating, reminder, see the sample come of [ReminderEditScreen](https://github.com/thruthesky/fireflutter/blob/main/example/lib/screens/reminder/reminder.edit.screen.dart).

- You may use `controller` to update `imageUrl` outside of `ReminderEdit` widget.

```dart
final controller = ReminderEditController();
ReminderEdit(
  controller: controller,
  // ...
);

// ...
controller.state.imageUrl.text = file.url;
controller.state.setState(() {});
```

## Reminder input data & logic

- There are `title, content, imageUrl, link` fields on the form.
- At least, One of `title, content, imageUrl` must have value or dialog will not appear.
- `link` has the information to which screen the app should move once user pressed on `more info` button. It must not be an empty string.

  - When `more info` button is pressed, `ReminderService` saves the link on local storage and calls the callback, then app can move the screen.
    - And when the app start again, it will not get the reminder document again from firestore since the link has already opened.
  - When user pressed on `don't show again` button, the link will be saved on local storage and when the app starts again, it will not get the reminder document again from firestore.
  - When `remind me later` button clicked, the app simply closes the dialog and when the app starts again, the app will fetch the reminder doc from firestore and display the reminder dialog again on screen.
  - When backdrop had touched, the app works the same as `remind me later` button pressed.
  - `link` can have in URL format. For instance, `/[screenName]?postId=123&option=a&v=1`.
    - When `more` button had been pressed, the callback function is being called and `[screenName]` parts goes to first parameter, and the rest part - `{'postId': 123, 'option': a, 'v': 1}` goes to next parameter.
      - So, the app can use these parameters to navigate into other route.
        - For instance, if `link` is `/otherUserProfile?uid=USERA...`, then when more button is pressed, the app will open the other user's profile screen.
    - If `link` changes, the `ReminderService` considers as a new link had been activated.
    - So, if you want to display a reminder dialog again with same url, then you may simply change the parameter a little like `/post-view?postId=123&option=a&v=2`.
  - Once `link` is saved on local storage, `ReminderService` does not get the same document of `link` again from firestore.

- The default dialog UI has three buttons.

  - `more info`, `don't show again`, and `remind me later`.
  - User can press on backdrop and it work just as `reminde me later` button.

- There are three buttons on `ReminderEdit` widget. You can update the `/settings/reminder` document with it.

  - When you press `preview` button, you can see the look of the default dialog UI with the reminder data.

    - When you press `don't show again` button on `preview` UI dialog, it saves the link on local storage.
    - When you press `more info` button button on `preview` UI dialog, it saves the link on local storage and calls the callback where the app can move to the intended screen.
    - Since the link saved, when the app restarts the reminder dialog would not appear.
    - One fitfall is that, when app starts, `ReminderService` will listen to the `/settings/reminder` with the link saved previously. and `don't show again` or `more info` button is pressed on `preview mode`. Then, new link had been saved on local storage. the but new link is not the same link that app is listening to.
      So, when `save` button pressed, the reminder dialog would popup.

  - When you edit and preview, you may add a version (test) value to see the changes.
    - For instance, `/post-view?postId=123&version=456`.
  - When you press on `preview`, it does not save the form data into reminder doc in firestore. So, you have to press `save` button to update the reminder doc. And then the updated reminder doc will be downloaded to users' app and reminder UI appears on all the online users' devices.
  - You may have an image upload button and update `imageUrl` with the uploaded image.
    But for now, you can input the imageUrl on the `imageUrl` field.

- Only admin whose UID is set in `/settings/admin` can edit the reminder documents.

- There is no fixed size of the image of `imageUrl`. The recommended size would be maximum of 512px width and the ratio of the width 3 and height 2.

- If admin updates the reminder with changes of `link` very quickly like 2 times in a minute, then two popup may appear on user's screen. This won't be happening in production mode and won't be a big trouble.

# FriendMap

- Idea\
  When someone is seeking someone and both of them are foreginers of the place, how would they find each other? Both of them do not understand the country's language.
  `FriendMap` feature send a user's latitude and longitude to the other user. So the other can navigate on the map.

## FriendMap installation

- Follow the installation instructions in [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) package.

  - `Hybrid Composition` could be an option.

- Follow the installation instructions in [geocoding](https://pub.dev/packages/geocoding) package.

- Follow the installation in [geolocator](https://pub.dev/packages/geolocator) package.

## FriendMap logic

- There are two users. User `A` and `B`.
- `A` sends his latitude and longitude to `B` on chat. (So, when `B` is offline, he will get push notification by the built in chat funciton)

- `B` opens chat room.
- `B` click the link of lat & lon to open `Friend Map`.
- the app navigates.

### FriendMap informing logic

- Use `Inform` feature to inform friend request to the other user.

## FriendMap testing

- Simply update `/location/<A's-uid>/` and `/location/<B's-uid>` manully.
  - To make it easy, update the location programatically.

# Inform

- When A likes B's post, how the app will inform B that he has a like from A?
  - Push notification is one option. But push notification may be delayed more than 1 hour.
  - `Inform` functionality make the communication in realtime.

## Informing logic

Let's say the app needs to deliver friend request from A to B.

- When User `A` request FriendMap to user `B`, it's not easy to open FriendMap by clicking the chat message. what if user `B` has lots of users and having difficulty to open the chat room `A`?.

  - The solution would be; when `A` request FriendMap to `B`, the app on `B` side will open `FriendMap` screen automatically.
  - When `B` is offline and got a push message of `FriendMap` request, the device of `B` will automatically run `WonderfulKorea` app and open `FriendMap` screen automatically.
  - Later; it may be an option to open `FriendMap` automatically or not.

- To make it work

  - All user must listen to `/inform/<uid>` when app starts.
  - When `A` request FriendMap to `B`, save lat & long in `/inform/<uid>`.
  - So, the app of `B` can open `FriendMap` with the data.

- When `B` is offline, or the app is not running,
  - `B` will open the app (by push notification or whatever),
  - the app of `B` listens `/inform/<uid>`
    - If there is data, then delete the doc, and open FriendMap.

## Inform data

- `type` has the data type.
  - `FriendMap` - it's a data for FriendMap and `latitude` and `longitude` properties are found.
  - `type` can be customizable and can have any value and addition properties.

## Use of inform

- To start listening the `inform data`, call `InformService.instance.init(callback: (data) {})`.

```dart
FirebaseAuth.instance.authStateChanges().listen((user) {
  if (user != null) {
    /// Re-init for listening the login user (when account changed)
    InformService.instance.init(callback: (data) {
      if (data['type'] == 'FriendMap') {
        /// If it's a freind map request, then open friend map screen.
        Get.toNamed('/friend-map', arguments: {
          'latitude': data['latitude'],
          'longitude': data['longitude'],
        });
      }
    });
  } else {
    InformService.instance.dispose();
  }
});
```

- When the app needs to inform to other user, call `InformService.instance.inform(<uid>, {...data....})`.

```dart
InformService.instance.inform(widget.room.otherUid, {
  'type': 'FriendMap',
  'latitude': pos.latitude,
  'longitude': pos.longitude,
});
```

# For developer

## Building your app

- To build your app with firelutter, simply add it on pubspec dependency.

## Building fireflutter

- Follow the steps
  - fork
  - clone
  - create a branch
  - update fireflutter
  - push
  - pull request.

## Updating fireflutter while building your app

- If you are going to use fireflutter, then simply add it on pubspec dependency.
- If you want to build fireflutter while you are building your app, then
  - fork fireflutter
  - add it as submodule in your project
  - add it as pubspec dependency with local path
  - when ever you want to update fireflutter, simple run `<submodule-folder>/example/main.dart`
  - after updating fireflutter, come back to your app and run your app.

# Test


## Test users

- Create the following four test user accounts with password of `12345a` using email & password sign-in.
  - `apple@test.com`, `banana@test.com`, `cherry@test.com`, `durian@test.com`
  - It is better to create test users with user utility. See [User utility](#user-utilities)

- Create an admin with `admin@test.com` as its email and `12345a` as its password.
  - And set the uid as admin. Read [Setting admin on firestore security rules](#setting-admin-on-firestore-security-rules) to know how to set admin.

## To test user functionality

- To test on point, by deleting point related document, you can observe(or restart) the point changes.
  - Delete `/users/<uid>` in realtime database.
  - Delete `/point/<uid>` in realtime database.

## Test method

- Since the Firebase libraries need to run on an actual device or emulator, we developped our own unit test & UI test.

## Local test on firestore security rules

- We have local unit test for firestore security rules at `<root>/firebase/test` folder.
- To run the test,

  - open `<root>/firebase/test/test.js` and update `TEST_PROJECT_ID` to your firebase project id.
  - run `$ firebase emulators:start` under `<root>/firebase` folder.
  - run `$ npm test` under `<root>/firebase/test` folder.

- To deploy,
  - open `<root>/firebase/.firebaserc` and update `projects.default` to your firebase project id.
  - run `$ firebase deploy --only firestore`


# Sample code

- See all tests code.
- `./firebase/lab` folder has some sample code.
  - `post.add-missing-properties.js` is for adding `noOfComments` and `deleted` fields on missing fields.
  - `create.test.user.js` is for creating test user accounts.


# Node.js Utilities

- To run utilities
  - `cd firebase/lab`
  - `npm i`


## User utilities

- Creating sample users
  - `node create.test.users.js`.

## Forum utilities


### Deleting posts, comments, and uploaded files in a category.

- Delete posts and its dependencies in a category.
  - It deletes posts and its uploaded files and comments and its uploaded files.
  - `node delete-category-data.js [categoryId]`
    - Example) `node delete-category-data.js discussion`
    - Warning! once this utility runs, there is no turning back. all posts & comments are deleted for good. You need to backup first before you run this.

- @todo - Note, this utility does not delete uploaded files, yet.


# Issues

- These are the common issues you may encount working this package.
- If you have any issues, please create an git issue.

## firebase_database/permission-denied

`Unhandled Exception: [firebase_database/permission-denied] Client doesn't have permission to access the desired data.`

- If you see this error, it means you didn't set the firebase database security rules properly. Refer [Firebsae Realtime Database Installation](#firebase-realtime-database-installation)

## Firebase realtime database is not working

- Open `GoogleService-Info.plist` under `ios/Runner` and see if the key `DATABASE_URL` is present. If not, enable firebase realtime database and download the `GoogleService-Info.plist` again. Remember to update related settings once you download it again.

## firebase_auth/internal-error

If you see this error message while working with Firebase Auth, check the followings;

- Check if REVERSE_CLIENT_ID is set on iOS.
- Check if GCP credential is properly set iOS.


## Unauthorized permission error on storage.

If fireflutter throws `[firestore_storage/unauthorized]`, then the user may try to delete file that does not belong him.
This may happens in testing or putting url(photoUrl) of other user's photo.

# Dyanmic Links Service

- The implementaion of `Dynamic Links` are based on https://firebase.flutter.dev/docs/dynamic-links/overview

## Installation

### Installation on Anroid

- Refer https://firebase.flutter.dev/docs/dynamic-links/android-integration

### Installation on iOS

- https://firebase.flutter.dev/docs/dynamic-links/apple-integration

## Dynamic Links - Coding guide lines

- There are two senarios to handle incoming dynamic link events.

### Terminated app

- First, initialize firebase app,
- Then, Pass `await DynamicLinksService.instance.initialLink` to main app.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MainApp(
    initialLink: await DynamicLinksService.instance.initialLink,
  ));
}
```

- Then, on MainApp, handle the dynamic links if it has any.

```dart
class MainApp extends StatefulWidget {
  const MainApp({required this.initialLink, Key? key}) : super(key: key);
  final PendingDynamicLinkData? initialLink;
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      /// If you do alert too early, it may not appear on screen.
      WidgetsBinding.instance?.addPostFrameCallback((dr) {
        alert('Terminated app',
            'Got dynamic link event. deepLink.path; ${deepLink.path},  ${deepLink.queryParametersAll}');
        // Get.toNamed(deepLink.path, arguments: deepLink.queryParameters);
      });
    }
    // ...
```

- One thing to note on the code above is that, If you do things like (alert, or navigation) too early before the app is rendered, the action may work strange (by racing). So, it would be better to take action after the app is rendered. You may use `Timer` instead of `WidgetsBinding.instance.addPostFrameCallback()`.

### For background(or foreground) apps

- Simply listen to the link event.

```dart
DynamicLinksService.instance.listen((Uri? deepLink) {
  alert('Background 2',
      'Dyanmic Link Event on background(or foreground). deepLink.path; ${deepLink?.path}, ${deepLink?.queryParametersAll}');
});
```

## Test Dynamic Links

- To test your dynamic link on iOS, you will need to use a real device as it will not work on a simulator. You will also have to run the app in release mode (i.e. flutter run --release) as iOS will block you from opening the app in debug mode from a dynamic link.
- On Android, you may test with emulator.

# Reports

- `target` is the data that is reported. It can be `post`, `comment`, `user`, `image` or any thing else.

- `targetId` is the key(or document id) of the `target`.
- `timestamp` is the timestamp of server.
- `reporterUid` is the uid of the reporter.
- `reporteeUid` is the uid of the user who is being reported. It is the user's uid who created the content.

- `/reports/` is the report collection.

- `/reports/{reportId}` document will have the following data.

```json
{
	reporterUid: "...uid of reporter ..."
  reporteeUid: "...uid of target data author..."
	target: "post, comment, user, file"
	targetId: ".... the key (or document id ) of the target"
	timestamp:  " server time stamp "
	reason: "reason of why reporter is reporting"
}
```

- The report document key format is `target-targetId-reporterUid`. This is to easily secure by the security rules.

  - For instance, `post-L8HDc07IYLGWd6puaVrT-1h0pWRlRkEOgQedJL5HriYMxqTw2`.

- A user cannot report same target & targetId.
  - To implement this, simple check if previous report exists.
    - This won't cost a lot since reporting does happens often.

# Forum

- Forum functionality uses firestore to provide maximum flexibility for customzation.

  - You may extend forum functionality for shopping app.
    - To build shopping app, you may need to manage products as a post model and reviews as comment model.
      - You may add extra properties for products(product name, price, etc) and its reviews(rating, etc). And to search the properties, firestore would be better fit than realtime database.

- Security
  - We want to avoid complicated security rules and cloud functions.
  - Mandatory permission check must be done by the security rules, like only allowing document update by the author.
  - But counting the like or dislike is not really critical. It won't be a big harm even if there would be a mis-counting. So, we don't do this work on clould functions. Instead, we do it on client side with transaction.

## Category

- Only admin can write the category, but readable to every one.

  - Admin can set `backgroundColor` and `foregroundColor` that are only extra properties for UI design.
    - There are no fixed usage of those. It's up to you where you want to use these colors. You may use them to display colors on category menu.
  - Admin can set `order` for the priority on the listing.

- If category does not exists, posting will be failed.

- If admin deletes category,

  - The existing posts are still remained.
  - No more post can be created for the deleted category anymore.
  - If admin create a with the same category as the deleted one, then,
  - User can create posts again with that category.

  - One thing to know is that, when category had deleted, the no of posts and no of comments properties are deleted also. And when category had re-created with same category id, the numbrers are not restored. This may lead a problem.
  - **_@todo so, in the future, if a category has a post, it should not be deleted. And there must be a function to move all the posts from one category to another._**


- If admin set `order` to `-1`, then the app should not display the category in menu. There is no obligation on it. It's just a recommended rule.

### Subcategory

- `subcategory` field is an optional field. It is not restricted by security rule. It is up to you how you use it.
  - One use case would be;
    - You want to make a separate screen(page) for daily log where user can post their daily affairs.
    - And you want the daily log appears in discussion category.
    - Then when a user creates daily log, app can set `category` as `discussion` and `subcategory` as `dailylog`.
    - So, the daily log will appear within `discussion` category and the app can display `subcategory=dailylog` on daily log screen. 


### Category menu group

- Admin can set category menu(or category group) at `categoryGroup` field in `settings/forum` of firetore document.
  - You can input multiple menu name separated by comman. For instance, "community,job".
- The app can display the category menu on select box in the admin category setting screen.
- Admin can, then, choose one of `category group` for the category.
- Use case.
  - App can display categories of `community` category menu on the menu of community screen.
  - App can display categories of `community` category on the notifications setting screen. So that, users can only subscribe(or unsubscribe) community categories only.
  - Use `categoryGroup` to group categories for listing, managing and more.






## Post

- Post model and comment model are a lot similiar, so they use same `PostModel`.

- `PostModel` can be customized and used for something else like shopping mall feature.
  When you want to build a shopping mall app, it needs product model and the product model may have comments or reviews. The forum functionality with customized `PostModel` can do the shopping mall feature.

- `PostModel` has methods like create, update, delete, like, dislike, and so on.

- When user deletes a post,
  - If the post has no comment, then the post document will be deleted.
  - If the post has comment, then the document is marked as deleted, instead of deleting the document from the database. And user may update the document even if the post is marked as deleted. Editing post of delete mark is banned by security rule. This is by design and is not harmful. So, there should be some code to inform user not to edit deleted post. This goes the same to comment delete.

- `hasPhoto` becomes true if the post has a photo.

  - This is a helper property for searching posts that have pohtos. Since firestore cannot have inequality expression on multiple fields, it wil help to search posts that have photos.

- Date

  - When you want to get 5 posts that have most noOfComments within 7 days,
    how you would search?
    The answer is `not so simple`.
    You may want to keep a separate collection that holds posts that are created within 7 days. And it's not simple work.

    So, there we added some date information for a better search.

    You may do `get 5 posts that have most noOfComments in last week`. But not `within 7 days`.

  - Post document has date information like below
    - `year` - the year
    - `month` - the month of a year (1-12)
    - `day` - the day of a month (1-31)
    - `dayOfYear` - the day of a year (1-366)
    - `week` - the week number since epoch ( from Jan 1st, 1970)
    - `createdAt` - database's server time stamp for the time of document creation.
    - `updatedAt` - server timestamp for update.
    Note that, these date properties except `createdAt` and `updatedAt` are optional fields, and added by `PostModel.create()`

- When admin creates a post, he can specify the document id. With this, posts can be managed easily.
  - For instance, admin puts `welcome` as document id, and he design the app that when user press on welcome button, the app read the post document of `welcome` and display it to the user.
  - Document id is easy to remember and easy to manage.

- `summary` field is used for the short description for the post.
  - `summary` should not be seen or searched as part of the post. But it can be dispalyed as short description on widget, or anywhere.
  - It's not part of security rule, so if you want, to use it or not.


- In the source code, `documentId` is being used to create a post with named document id. And this gives an easy way of managing posts since the named document id is easy to remember.
  - On the sample code, admin can input document id when he creates a post.
  - Then, the document id can be used to view the post or get the post.
    - App can display a banner and when user taps, app can redirect to post view screen by give the `named-document-id`.


- Update at Mar 5, 2022 - `noOfComments` is required to create a post. The value must be 0.
  - By this, app can search posts with `.where('noOfComments', isEqualTo: 0)`.
- Update at Mar 5, 2022 - `deleted` is required to create a post and the value must be `false`.
  - By this, app can search posts with `.where('deleted', isEqualTo: false)`.


## Comment

- Comments are saved in `/comments` so it is better to be search. If it is saved under `/posts/(postId)/comments/`, then it is not easy to search.

- Properties
  - `postId` has the post id of that the comment belongs to.
  - `parentId` is the post id if the comment is the immediate child coment of the post.Or parent comment id.
  - `uid` is the author id.
  - `timestamp` is the server time.



## PostService and PostApi


- `PostService` is a flutter helper class for post crud while `PostApi` is a restful api helper class to call cloud function via http.
- `PostApi` uses `Dio` to communicate to cloud function.
- It is recommended to use `PostApi` and `CommentApi` instead of `PostService` and `CommentService` for post & comment crud.


## PostApi

- App can do post CRUD with `PostApi`.
- `documentId` on create is the document id of the post to be created. By giving document id(as post id), developer can do better coordination. For istance, give `help` as document id and on view screen, get the `help` as post id and display.


# Push notification

- User tokens are saved under `/message-tokens/(tokenId)`

  - properties;
    - `uid` - user id or empty string if user didn't logged in.

- user topic are saved under `/users/(uid)`.
  - `{ topics: ['posts_qna', 'posts_discussion', 'comments_qna', ...] }`

## terms

- `comment notification` is an option to get notification whenever a new comment had posted under his post or comment.
  - `comment notifyee` is a user who will get notification when there is a comment under his post or comment.





## How push notification wokr.

- When a post created, the app sends a message to the posts_category topic. That's all it needs.
- When a comment is created,
  - the app sends a message to the comments_category topic,
  - And the app sends a message to authors of the parent(post) of the comments who didn't subscribed the 'comments_category' topic, but subscribed for 'new comments topic'.

## push notification logic

new logic)
terms;

    - 'comment notification' - Send me notification for new comments under my posts or comments.

    - new sign-in user must unsubscribe to all topics before subscribing to user topics

conditions; - There is no more subscribing for all new posts and all new comments.
Users must enable or disable each category indivisually.

ui;

- User can also enable all or disable all by one button touch in the setting screen.
- User can enable or disable selectively in settings screen.
- See https://github.com/withcenter/wonderfulkorea/issues/70 for ui design;

how; - When a user subscribed 'comments_qna' and the user also enabled 'comment notification',
and if the user create a post under qna forum, and somebody commented on it.
Then, 'comment notification' will be ignored.

    - for posts,
    	A - subscribed 'posts_qna'.
    	B wrote a post under 'qna'. then send push notification to 'posts_qna'.
    	then A gets a push notification.


    - for comments
    	R - didn't subscribe both of comments_job and "comment notification".
    	A - subscribed "comments_job" only.
    	B - subscribed "comment notification" only.

    	R wrote a post(postJob) under job cateogry.
    	A wrote a comment A-1 under postJob.
    	B wrote a comment B-1 under A-1.
    	C wrote a comemnt C-1 under B-1.
    	Then, send push notifications to topic 'comment notification'.
    	Then, the app needs to find the authors of ancesters. that are R, A and B.
    	And, see if they subscribed 'comment notification'.
    		B subscribed 'comment notification', so he got push notification already.
    		A didn't subscribe 'comment notification', so need to check if he subscribed 'comments_job' and yes, he subscribed to it. so, send a push notification.
    		R didn't subscribe 'comment notification', so check if he subscribed to 'comments_job' and no, he didn't. so, he gets no push notification.

when user changes devices; - The app knows when the device has a token that are not saved in firestore, it is considered as new device. - Subscribe all the topics that the user has.

when sending push notification fails, see the error messages and remove that token from the database. so, it won't waste the network bandwidth.

## Testing Push notification via terminal

- Prepare the data information and replace the value of `to`. Either `token` or `topic` ex. `/topics/posts_qna`

```
DATA='{"notification": {"body": "this is a body","title": "this is a title"}, "priority": "high", "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "1", "status": "done"}, "to": "/topics/posts_qna"}'
```

- use curl to google api to send push notification attaching the data above. make sure to replace the `FCM SERVER KEY` with the google console `Cloud Messaging Server Key` can be found in google console project setting > cloud messaging > server key

```
curl https://fcm.googleapis.com/fcm/send -H "Content-Type:application/json" -X POST -d "$DATA" -H "Authorization: key=2hU:AP8FpX2kNKZqqzmBdUg_BWuluihF6n............t3ykfXvzks83HWSpA.....oVjaCFN7S"
```

# Fil upload - Firebase Storage

- Install `Image Resize` extension as described in [Firebase Storage Installation](#firebase-storage-installation).
- Set the rules in Firebase Storage section as described in [Firebase Storage Installation](#firebase-storage-installation).

## pickUpload

- `StorageService.instance.pickUpload` will let user to pick an image(or file) and upload it in `uploads` folder in firebase storage.

```dart
try {
  String uploadUrl = await StorageService.instance
      .pickUpload(source: ImageSource.gallery, onProgress: print);
  alert('Success', 'Image uploaded successfully');
} catch (e) {
  error(e);
}
```

- This will ask user to take a photo from camera or choose a photo from photo library and compress & adjust rotation, then uploads an image into firebase storage. It will generate thumbnail image with `_200x200.webp` suffix.

## Delete uploaded image

- `StorageService.instance.delete()` will delete uploaded image and its thumbnail image.

## FileUploadButton

- When a user presses upload button, the app will ask to choose image selection method.
- Then, upload image using `pickUpload` method.

## Displaying Uploaded Image

- `UploadedImage` widget will display the uploaded image.
  - It will first try to display thumbnail image. if it fails to display thumbnail image,
    - then, it will try to display original image. If it fails to dsipaly original image,
      - then it will display the error widget.

- Errors with `UploadedImage`.
  When thumbnail does not exists, the error message below may appear. And this is not a critical error. Thumbnails are generated automatically by the cloud function. And sometimes, very rarely happens when there is no thumbnail generated.
```text
════════ Exception caught by image resource service ════════════════════════════
The following HttpExceptionWithStatus was thrown resolving an image codec:
HttpException: Invalid statusCode: 403, uri = https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/test%2F6_200x200.webp?alt=media
```

## Uploaded file management

- When a file is uploaded,
  - `type`, `uid`, `basename` must be added as custom meta.
    - `type` is the type of parent object. it can be one of `post`, `comment`, `user`, or `chat`.


- When files are uploaded with a post(or comment), the URLs will be saved in `files` property of the post(or comment).

- When a post(or a comment) is submitted with uploaded files, then `cloud functions` will update custom metadata of those files in storage with the id of the post(or comment).
  - That means, when a post(or comment) has attached files, the files will have the id of the post(or comment) in its custom metadata.
  - So, you can delete files in storage if
    - they don't have `id` in custom metadata when their `type` is one of `post` or `comment`.
    - the url is no longer being used by the `id` of the post(or comment).
    - their parent (post or comment) has deleted.
  - @todo - Firefluter does not provide the deletion funtionality for some cases like user closed the app while posting with some image uploaded. You may delete it by yourself at this time. @see https://github.com/withcenter/wonderfulkorea/issues/77



# Location Service

- Use this service to get current location positoin.

# Cloud Functions

- Cloud functions are re-written in Typescript by Apr 1, 2022.

- We want to avoid using `cloud functions` as much as possible. But there are some cases that we must use it like sending push notifications.
- We also use `cloud functions` to send(for indexing) posts and comments into `meilisearch` and our own backend.
  - And we think, sending posts and comments into different palce can be done by flutter app, we may remove those cloud functions in the future.
    - One good reason why we do it in `cloud functions` is that, user can create a post or a comemnt not only using flutter app, but also using web site. And we don't have to implement the same code (for sending posts and comments into another place) twice.

- Since `Firebase Hosting` supports only `us-central1` region, the cloud functions are distributed in mutiple region in `index.ts`.

## Unit test for Cloud Functions

- `<root>/firebase/functions/tests` folder has all the tests.


## Error handling

### How to send error back to client

- Below is an example of sending error from cloud function to client.

```ts
export const produceErrorString = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: false }, async () => {
        res.status(200).send(ERROR_TEST);
      });
    });

export const produceErrorObject = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: false }, async () => {
        res.status(200).send(sanitizeError(ERROR_TEST));
      });
    });
```

- Below is how to handle error on flutter.

```dart
ElevatedButton(
  onPressed: () => FunctionsApi.instance
      .request(FunctionName.produceErrorString)
      .catchError(service.error),
  child: Text('Produce error string'),
),
ElevatedButton(
  onPressed: () => FunctionsApi.instance
      .request(FunctionName.produceErrorObject)
      .catchError(service.error),
  child: Text('Produce error object'),
),
```

- You can update the translation to display the error text nicely.
  - App uses (or should use) translated text on error if translation is available.

### Error handling on client end

- The response from could funtion http call must be an object.
  - So, if the http cloud function method sends any string (or num) then, it will be an error.
  - Note that if there is an error on cloud function itself, then a string of json-encrypted will be returned and it will be parsed as JSON on client end.
- If there is a non-empty value of `code` property in response object, then it is considered as an error. And the value of `code` property is the error message or an informational string of the error.
- The `request` may produce an error from `Dio` and that will also throw an error.

- Example of error response from http cloud function
  - `{ code: 'ERROR_EMPTY_UID' }`

- Note, the helper classes may still return a string of error and it would be encapsulated as error response object in `ready`.




## Cloud functions - http trigger, restful api.

- There are helper classes for cloud functions http call that ends with `Api`. Most (or all) of Firebase client helper classes ends with `Service`.
  - For instance,
    - `PostApi` is the http call helper class while `PostService` is firebase client helper class.


### Ready

- Cors and pre-flight.
  - `ready` function takes care of cors and preflight. and it also takes care of user authentication.
  - To authenticate a user, call `ready({ req, res, auth: true}, (data) => {})`.

- The callback of `ready` has one arguement that has all the input.
  - Note that, input may be delivered as query, body, params. and `data` merges all the input and has all input data.
  - The two following code samples call the cloud function via http and one send data to server as json and the other as query params. Even though their body format are different, the callback parameter `data` of `ready` has same object from the two requests.

```sh
curl -X POST -H "Content-Type: application/json" "http://localhost:5001/withcenter-test-project/asia-northeast3/inputTest?a=apple&b=banana" -d '{"c":"cherry", "d": "durian"}'

curl -X POST -H "Content-Type: application/x-www-form-urlencoded" "http://localhost:5001/withcenter-test-project/asia-northeast3/inputTest?a=apple&b=banana" -d 'c=cherry&d=durian'
```

- You need to use `ready` on http call only.


### Request and data handling

- To request using http call to cloud functions, use `FunctionsApi.instance.request` method.
  - It will return the data that the clound function sends back to client.
  - When there is an error it will throw an exception.


- First, initialize the cloud function server url before using the api.

```dart
FunctionsApi.instance.init(
  serverUrl: "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/",
  onError: error,
);
```

- Secondly, you can request to cloud functions like below.

```dart
class _ServerTimeState extends State<ServerTime> {
  Map? data;
  @override
  void initState() {
    super.initState();
    FunctionsApi.instance.request('inputTest', {'a': 'apple', 'b': 'banana'}).then((value) {
      setState(() {
        data = value;
      });
    }).catchError((e) {
      error(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text("Cloud functions server time: ${data?['b']}");
  }
}
```

- This is another example code of displaying server time

```dart
class _ServerTimeState extends State<ServerTime> {
  Map? data;
  @override
  void initState() {
    super.initState();
    FunctionsApi.instance
        .request('serverTime')
        .then((value) => setState(() => data = value))
        .catchError((e) => error(e));
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        "Sserver time: ${DateTime.fromMillisecondsSinceEpoch(data?['timestamp'] * 1000).toString()}");
  }
}
```





### Post create

- App can call `postCreate` via http to create a post.
  - This can be used in all cases. But since we have `Post` model and `PostService` for flutter app, flutter app may not need to use this.
  - But it is way better to use `postCreate` via http in Flutter app also.
  - And use it everywhere like in Node.js, Vue.js, PHP, or from anywhere.
  - This is a recommended way of creating a post.

- To create a post, you need to provide uid and password. See the test code how you can provide password.

- It saves some time information like `year, month, day, dayOfYear, week, createdAt, updatedAt` for better filtering and sorting.

- App can save extra values, so it can store additional fields for different services.



### Cloud functions Sample codes

- See `tests` folder for the sample code. These sample codes are the best examples you can refer.


## Meilisearch

https://docs.google.com/document/d/1tSJJt8iJsXNl9vcBqYhKPkiRZR5JFo-SQE2SJ90GItA/edit#heading=h.g94frts1xgxo

## Re-indexing documents

- Forum and user documents can be re-indexed if needed.
- see `meilisearch-reindex.ts` for more info.

# Backup

- For `Realtime database`, use built-in backup feature in firebase console.

- For `Firestore`, use `fireflutter/backup/index.js` to backup.

## Firestore backup

- We use `https://www.npmjs.com/package/firestore-export-import` to backup.
  - It is best to place the backup server in same area(or country) of firebase region.

- To install firebase backup node environment
  - `# apt install npm`
  - `$ npm i`

- Make sure the node version is 14.x and above.

- To backup
  - `$ node index.js`


- To daily backup, put it in cron
  - The cron below will backup fierstore at 10:50 am every day.


```txt
50 10 * * * cd ~/fireflutter/firebase/backup; node index.js
```



# Point

## Point settings

- There are 4 point event triggered by user activity.
  - And there are might be more point event later like point increase by payment.
- Each point event criteria is set to `randomPoint` in `lib.js`
- On each event, the cloud funtion will randomly generate point between `min` and `max`. `min` is the minimum point and `max` is the maximum point.
- Some event has `within` property. `within` property has seconds that if the action happens again within that seconds, there will be no point event.

## Poitn Event Logic

- A point event document will be created under `/point/<uid>` with properties of `timestamp`, and `point` when user action happens.
  - When event happens (document create or update), random point will be generated acoording to `lib.js::pointEventRule`.

- User actions that trigger point document would be;
  - register,
    - When a user registers, cloud function event trigger will create a record at `/point/<uid>/register` with `{ timetstamp: timestamp, point: ... }`.
  - app run,
    - When a user runs app on every 24 hours, `/point/<uid>/signIn` will be created.
  - create post,
    - When a user creates a post, `/point/<uid>/post/<postId>` will be created
  - create comment,
    - When a user creates a comment, `/point/<uid>/comment/<commentId>`,

- Note that, `signIn`, `postCreate` and `commentCreate` has a time limit that it cannot have new point event within x-number of minutes.
  - For instance, if the limit of `postCreate` within 15, then, even if the create many posts within 15 hours, only one will get point event. When the user creates another post after 15 hours, it will take point event again.



## Category point setting

- When a category has point value in its setting, then the point event will not work. Instead, the point of the category will be applied.
- The point of the category will be applied on every post create.
  - So, you can use this kind of cases;
    - If you want a user's point deducted by 500 points, when the user creates a post on buy and sell, then set -500 on the buy and sell category setting.
    - If you want a category (like new category) not to be affected by the point event, then you may set the point value in category setting to 1 or -1. So it will take minimal affects on that category.





## Point document

- User point is saved under `/point/<uid>/point` document with `point` and `history`.
  - `/point/<uid>/point/point` is the amount of point that the user posseses. This point can be increased or decreased depending on the events.
  - `/point/<uid>/point/history` is the amout of point that was earned (without deduction) by the user for the life time.
- User point is also saved in user document and it is only because of the flat design. Point saved in user document can be modified by hacker. it does not matter since the real point data is saved in `/post/<uid>/point`.


## Displaying Point

### Use point property to dispaly point.

- post and comment have `point` property that was set(generated) by creating post and comment.
  - So, you can do `Text('* earned ${post.point} points')` to dislay the point of the post or comment.
- user profile also has `point` property that is only a copy of `/point/<uid>/point/point`.
  - So, you can do `MyDoc(builder: (u) => Text('Point: ${u.point}'))` to display user point.

### PointBuilder

- To display point of a user from `/point/<uid>/point/point`, you can use `MyPointBuilder`.

- To display point of a post or comment from `/point/<uid>`, you can use `PointBuilder` which displays point earned by post and comment.

```dart
PointBuilder(
  uid: post.uid,
  id: post.id,
  type: 'post',
  builder: (point, user) {
    return point == 0
        ? SizedBox.shrink()
        : Text(
            '* ${user?.displayName ?? ''} earned $point points.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          );
  },
),
```

### MyPointBuilder

- For display login user's point, use `MyPointBuilder`.


### ForumPoint

- Use this widget to dsipaly point of post and comment create.
- This is not based on `/point/<uid>/postCreate` or `/point/<uid>/commentCreate`.
  - It is based on the `point` field of post document or comment document.


```dart
ForumPoint(
  uid: comment.uid,
  point: comment.point,
  padding: EdgeInsets.only(top: 8.0, left: 8.0),
),
```




## Point history

- Some point history folders (like sign, postCreate, commentCreate) are used to limit the point event within a period of time.

- Since the histories are saved in realtime database, each events are segregated in different folders.
  - But some point history that are not used for the time limit purpose are saved under `/point/<uid>/extra` folder.
  - use `Point.extraPoint` in `point.ts` to leave history in `extra` folder with the reason why the point has added(or deducted).







## Displaying point history

- Point history are scattered around `/point/<uid>` folder in realtime database.
  - `/point/<uid>/register` is the register bonus point.
  - `/point/<uid>/signIn` is the sign-in bonus point folder.
  - `/point/<uid>/commentCreate` is the comment creation bonus point folder.
  - `/ponit/<uid>/postCreate` is the post creation bons point folder.

- There might be more point event like `payment` in the future.

- You can use `pointHistory` http cloud function to get point histories by monthly.
  - For instance, `pointHistory?year=2022&month=4` will give the point change list on April, 2022.

- The unit test for this is in `tests/point/list.spec.ts`.






## Senario

- When a user registers, he gets registration point. and If here sign out and sign in (or close app and run again) immediately, he can get sign-in point.

- Point histories are on the `/point/<uid>/...` in realtime database.
  - You can develop point history screen. since the histories are splited into many sub folders,
    It is one way to collect all of the histories on the folders by day, week, month, year.



## User point and level

- Level will be set on user's document by cloud function.
- The formula in dart of computing level from point is like below.

```dart
final seed = 1000;
int acc = 0;
for (int i = 1; i < 500; i++) {
  acc = seed * i + acc;
  print('lv. $i: $acc');
}
```

- The level is saved in user document every time point changes by cloud function.

- The level list is like below.

```text
lv. 1: 1000
lv. 2: 3000
lv. 3: 6000
lv. 4: 10000
lv. 5: 15000
lv. 6: 21000
lv. 7: 28000
lv. 8: 36000
lv. 9: 45000
lv. 10: 55000
lv. 11: 66000
lv. 12: 78000
lv. 13: 91000
lv. 14: 105000
lv. 15: 120000
...
lv. 99: 4950000
lv. 100: 5050000
...
lv. 139: 9730000
lv. 140: 9870000
lv. 141: 10011000
lv. 142: 10153000
...
lv. 445: 99235000
lv. 446: 99681000
lv. 447: 100128000
lv. 448: 100576000
...
lv. 498: 124251000
lv. 499: 124750000
```

# Extra Features

## Job

- See `<fireflutter>/lib/src/extra/job/README.md` for details.
- See `<fireflutter>/lib/src/extra/job` for the source code and details.

# Release mode error

```
java.lang.LinkageError: Method java.lang.Object com.google.android.gms.internal.ads.lo3.zzb() overrides final method in class Lcom/google/android/gms/internal/ads/do3; (declaration of 'com.google.android.gms.internal.ads.lo3' appears in /data/app/com.sonub.app-IZie7riyQF-iBzjhN4a3Dw==/base.apk)
```

## How to fix
- [source](https://github.com/googleads/googleads-mobile-flutter/issues/471)
- Update `android\build.gradle`
```gradle
buildscript {
  ...
    dependencies {
        classpath 'com.android.tools.build:gradle:4.2.2'
        // classpath 'com.android.tools.build:gradle:4.1.0' (from old version)
        ...
    }
}
...
```
- Update `android\gradle\wrapper\gradle-wrapper.properties`
```properties
...
distributionUrl=https\://services.gradle.org/distributions/gradle-6.7.1-all.zip
# distributionUrl=https\://services.gradle.org/distributions/gradle-6.7-all.zip (from old version)
```