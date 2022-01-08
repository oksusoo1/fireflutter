
# Fire Flutter

A free, open source, complete, rapid development package for creating Social apps, Chat apps, Community(Forum) apps, and much more based on Flutter and Firebase.

I am looking for community devleopers who can join this work. Please email me at thruthesky@gmail.com

Table of contents

- [Fire Flutter](#fire-flutter)
- [Features](#features)
- [Installation](#installation)
  - [Running the example](#running-the-example)
  - [Creating a new project](#creating-a-new-project)
  - [Firebase installation](#firebase-installation)
  - [Firebase Realtime Database Installation](#firebase-realtime-database-installation)
- [Packages](#packages)
- [User](#user)
  - [User Installation](#user-installation)
- [User Presence](#user-presence)
  - [User Presence Overview](#user-presence-overview)
  - [User Presence Installation](#user-presence-installation)
  - [User Presence Logic](#user-presence-logic)
- [TODOs](#todos)
  - [Find Friends](#find-friends)

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


- Download ios app's `GoogleService-Info.plist`. And save it under `<root>/example/ios/Runnder`, Then open Xcode and drag it under Runner.

## Firebase Realtime Database Installation

- To install Firebase Realtime Database, enable it on Firebase console and put the security rules.

- Note, if you enable `Firebase Realtime Database`, you have to re-download and update the `GoogleService-Info.plist`.
  - You may need to update the `GoogleService-Info.plist` after enabling other features of the Firebase.






# Packages

- We use [Getx](https://pub.dev/packages/get) for route & state management.
- We use [FlutterFire UI](https://firebase.flutter.dev/docs/ui/overview) for Firebase auth and other UI examples.
  - You may build your own UI.




# User

## User Installation

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

# User Presence

## User Presence Overview

![User Presence](https://raw.githubusercontent.com/thruthesky/fireflutter/main/readme/images/user-presence.jpg?raw=true)


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
    Presence.instance.deactivate();
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

- If user didn't login to the device, nothing will happens.
- `/presense/$uid` document will be written only when user logs in and out.
- When app is closed, the user will be offline.



# TODOs

## Find Friends

- Idea: See if you are looking for a friend in a busy city. When you and your friend are connected, you can find each other by sharing geo location.
- Implementaion: put find button and when connected, display position in map and update the geo location.


