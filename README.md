
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
- [Installation](#installation)
  - [Running the example](#running-the-example)
  - [Creating a new project](#creating-a-new-project)
  - [Firebase installation](#firebase-installation)
    - [iOS installation](#ios-installation)
  - [Firebase Realtime Database Installation](#firebase-realtime-database-installation)
- [Packages](#packages)
- [User](#user)
  - [User installation](#user-installation)
  - [Phone number sign-in](#phone-number-sign-in)
- [User presence](#user-presence)
  - [User presence overview](#user-presence-overview)
  - [User Presence Installation](#user-presence-installation)
  - [User Presence Logic](#user-presence-logic)
- [TODOs](#todos)
  - [Find Friends](#find-friends)
- [For developer](#for-developer)
  - [Building your app](#building-your-app)
  - [Building fireflutter](#building-fireflutter)
  - [Updating fireflutter while building your app](#updating-fireflutter-while-building-your-app)
- [Issues](#issues)
  - [firebase_database/permission-denied](#firebase_databasepermission-denied)
  - [Firebase realtime database is not working](#firebase-realtime-database-is-not-working)

# Features

- User
  - User registration is done with Firebase Flutter UI.


- User presence
  - To know if a user is online or offline.



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



# Packages

- We use [Getx](https://pub.dev/packages/get) for route & state management.
- We use [FlutterFire UI](https://firebase.flutter.dev/docs/ui/overview) for Firebase auth and other UI examples.
  - You may build your own UI.




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

## Phone number sign-in

- In most cases, you want to use `Firebase Flutter UI` for `Firebase Sign-In` and that's very fine.
  But when you do `Phone Sign-In`, it's not easy to handle errors. So, fireflutter have this functionality.

- To use phone sign-in, enable it and add some test phone numbers.

- Fireflutter provides UI that is highly customizable.



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

## User Presence Logic

- Run `Presence.instance.activate()` at start if you want to track the presence status of users.
- If user didn't login to the device, the user will be offline by default.
- If `Presence` is working, you will see the record in firebase realtime database data section in firebase console.
  - If no documents appears in firebase realtime database data section, then see the installation and issues.
- `/presense/$uid` document will be written only when user logs in and out.
- When app is closed, the user will be offline.



# TODOs

## Find Friends

- Idea: See if you are looking for a friend in a busy city. When you and your friend are connected, you can find each other by sharing geo location.
- Implementaion: put find button and when connected, display position in map and update the geo location.


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

- These are the common issues you may encount.
- If you have any issues, please create an git issue.


## firebase_database/permission-denied

`Unhandled Exception: [firebase_database/permission-denied] Client doesn't have permission to access the desired data.`

- If you see this error, it means you didn't set the firebase database security rules properly. Refer [Firebsae Realtime Database Installation](#firebase-realtime-database-installation)



## Firebase realtime database is not working

- Open `GoogleService-Info.plist` under `ios/Runner` and see if the key `DATABASE_URL` is present. If not, enable firebase realtime database and download the `GoogleService-Info.plist` again. Remember to update related settings once you download it again.

