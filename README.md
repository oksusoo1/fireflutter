
# Fire Flutter

A free, open source, complete, rapid development package for creating Social apps, Chat apps, Community(Forum) apps, Shopping mall apps, and much more based on Firebase.

- Complete features.\
  This package has complete features (see Features below) that most of apps require.

- Simple, easy and the right way.\
  We want it to be deadly simple yet, right way for ourselves and for the developers in the world. We know when it gets complicated, our lives would get even more complicated.

- Real time.\
  We design it to be real time. All the events like post and comment creation, voting(like, dislike), deletion would appears on all the user's phone immediately after the event.

- I am looking for community devleopers who can join this work. Please email me at thruthesky@gmail.com

Table of contents

- [Fire Flutter](#fire-flutter)
- [Features](#features)
- [TODOs](#todos)
  - [Chat](#chat)
- [Installation](#installation)
  - [Running the example](#running-the-example)
  - [Creating a new project](#creating-a-new-project)
  - [Firebase installation](#firebase-installation)
    - [iOS installation](#ios-installation)
  - [Firebase Realtime Database Installation](#firebase-realtime-database-installation)
- [User](#user)
  - [User installation](#user-installation)
  - [Test users](#test-users)
  - [Phone number sign-in](#phone-number-sign-in)
- [User presence](#user-presence)
  - [User presence overview](#user-presence-overview)
  - [User Presence Installation](#user-presence-installation)
  - [User presence logic](#user-presence-logic)
- [User profile](#user-profile)
  - [Displaying user profile](#displaying-user-profile)
  - [User Auth State](#user-auth-state)
- [Chat](#chat-1)
  - [Chat structure of Firestore](#chat-structure-of-firestore)
- [FriendMap](#friendmap)
  - [FriendMap installation](#friendmap-installation)
  - [FriendMap logic](#friendmap-logic)
  - [FriendMap testing](#friendmap-testing)
- [For developer](#for-developer)
  - [Building your app](#building-your-app)
  - [Building fireflutter](#building-fireflutter)
  - [Updating fireflutter while building your app](#updating-fireflutter-while-building-your-app)
- [Issues](#issues)
  - [firebase_database/permission-denied](#firebase_databasepermission-denied)
  - [Firebase realtime database is not working](#firebase-realtime-database-is-not-working)
  - [firebase_auth/internal-error](#firebase_authinternal-error)

# Features

- User
  - User registration is done with Firebase Flutter UI.


- User presence
  - To know if a user is online or offline.


- User Profile
  - Saving & displaying user profile.


- Chat

- Friend map
  - To find friend easily.


# TODOs

## Chat

- bundle many chat messages if they are written in 20 minutes.




# Installation


## Running the example

- Do the [Firebase installation](#firebase-installation).
- Git fork the [fireflutter](https://github.com/thruthesky/fireflutter).



## Creating a new project

- Do the [Firebase installation](#firebase-installation).
- Edit platform version to `platform :ios, '10.0'` in Podfile.

## Firebase installation
- Refer the instructions of [FlutterFire Overview](https://firebase.flutter.dev/docs/overview)


### iOS installation

- Download ios app's `GoogleService-Info.plist`. And save it under `<root>/example/ios/Runnder`, Then open Xcode and drag it under Runner.
  - Remember to update other settings like `REVERSED_CLIENT_ID` into `Info.plist`.
    - When you change the firebase project, you have to update all the related settings again.

## Firebase Realtime Database Installation

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
    }
  }
}
```




# User

## User installation

- Do [Firebase installation](#firebase-installation)
- Enable Email/Password Sign-In method to login with email and password.
- Enable Google Sign-In method and add the following in `Info.plist` to login with Google account
```xml
<!-- Google Sign-in Section -->
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- TODO Replace this value: -->
			<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
			<string>com.googleusercontent.apps.------------------------</string>
		</array>
	</dict>
</array>
<!-- End of the Google Sign-in Section -->
```

## Test users

- Create the following four test user accounts with password of `12345a`.
  - `apple@test.com`, `banana@test.com`, `cherry@test.com`, `durian@test.com`

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
  onlineBuilder: () => Row(
    children: const [
      Icon(Icons.circle, color: Colors.green),
      Text('Online'),
    ],
  ),
  offlineBuilder: () => Row(
    children: const [
      Icon(Icons.circle, color: Colors.red),
      Text('Offline'),
    ],
  ),
  awayBuilder: () => Row(
    children: const [
      Icon(Icons.circle, color: Colors.yellow),
      Text('Away'),
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



# User profile

- Many apps share user name and photo. For instance, when a user chat to the other user, they shoud know each other's name and photo.

- User name and photo are saved in `/user/<uid>` document of Firestore.

## Displaying user profile

- To display a user profile(name or photo), Use `UserDoc` widget with the user's uid and you can build a widget based on the user profile.
  - The builder of `UserDoc` comes from a stream builder, which means when the user profile document changes, it will rebuild the builder widget to update realtime.

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

- To display a user profile, but only one time build (not automatic rebuild), use `UserFutureDoc` widget. The builder of `UserFutureDoc` is based on future builder. So, it does not rebuild even if the user profile document changes.
  - This widget may be used for forms. Like display user profile data in input fields.

```dart
UserFutureDoc(
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

## Chat structure of Firestore

- `/chat/messages/<uid>__<uid>` is the collection of a chat room messages. Each document in this collection is the chat message documents that are handled by the `ChatMessageModel`. This is called `message doc`.

- `/chat/rooms/<uid>` is the collection of a user's chat friends. The documents inside this collection are the users that he chatted. For instance,
  - `/chat/rooms/<uid>/<uid>` is the document of a chat room. This document has the room information. (This is called `room info doc`.) For instance,
    - `/chat/room/A/B`
    - `/chat/room/A/C`
    Then, the user `A` have had chat with user B and C.
    Note that, `room info doc` is also handled by the `ChatMessageModel`.

# FriendMap

- Idea\
  When someone is seeking someone and both of them are stranger of the place, how would they find each other? Some country may use road name as land marks while some country has no names on roads, instead, they use building names as land marks. But both of them are foreginers and they don't know the country's language.
  If there is a map which display two markers of each user's position, it would be a big help.

  `FriendMap` feature provides a functionality to find a friend on map. It shares both of user's geo locations and the app can display markers on the map and updates the markers on every move.


## FriendMap installation


- Follow the installation instructions in [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) package.
  - `Hybrid Composition` could be an option.

- Follow the installation instructions in [geocoding](https://pub.dev/packages/geocoding) package.

- Follow the installation in [geolocator](https://pub.dev/packages/geolocator) package.



## FriendMap logic

- There are two users who wants to meet. User `A` and `B`.
- `A` requests 'FriendMap' to `B` by pressing the chat room list menu.
  - App automatically sends a chat message to `B`, so even if `B` closed the app, `B` will get push notification.
  - And when `B` is online, app will show dialog box to inform.

- `B` can accept or reject the request.
  - Once rejected, there will be more `informing dialog` when `A` requests again.
  - When `B` accepts,
    - `FriendMap` screen will be automatically opened on both of `A` and `B`'s device.

- (logic-updating-location) When `FriendMap` is opened, the app will beging to save each user's location on `/location/<uid>`.
  - For instance, `A` will update his location in `/location/<A's-uid>` while `B` will update his location in `/location/<B's-uid>`.

- (logic-display-marker)
  - And, on `A` device, the app simply draws the marker of `A` from his device location on the map and get `B`'s location from `/location/<B's-uid>` and display the marker on map.
  - And, on `B` device, the app simply draws the marker of `B` from his device location and get `A`'s location from `/location/<A's-uid>` and display `B`'s marker on the map.

- Optionally, `FriendMap` can display the address of location of each user.


## FriendMap testing

- Simply update `/location/<A's-uid>/` and `/location/<B's-uid>` manully.
  - To make it easy, update the location programatically.


# For developer

## Building your app

- Simple add it on pubspec dependency

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



