
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
  - [Chat logic](#chat-logic)
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

- put many chat messages in one chat message box(balloon) if they are written in 20 minutes.




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


- `/chat/rooms/<uid>/<uid>.blocked` will be true if the user is blocked.
- `/chat/rooms/<uid>/<uid>.deleted` will be true if the user is deleted.
  So, the deleted user will not be appears on list.

## Chat logic

- When a user is reported, the app will save the user into backend.

- `/chat/room/<uid>/<uid>` must not be over-written. It must always be updated(merged) on existing document since `blocked`, `deleted` properties must remain even if other properties are changed.
  - @todo it's best to restrict by permission rule not to overwrite.



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



