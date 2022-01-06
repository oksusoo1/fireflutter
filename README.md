
# Fire Flutter

A free, open source, complete, rapid development package for creating Social apps, Chat apps, Community(Forum) apps, and much more based on Flutter and Firebase.

- Complete features.\
  This package has complete features (see Features below) that most of apps require.

- `Simple, easy and the right way`.\
  We want it to be deadly simple, yet right way for ourselves and for the developers in the world.
  We know when it gets complicated, our lives would get even more complicated.

- Real time.\
  We design it to be real time. All the events like post and comment creation, voting(like, dislike), deletion would appears on all the user's phone immediately after the event.

- This project, as of January 2022, is under heavy revision to match the latest version of Flutter and Firebae. To see old version, refer [v0.1 branch](https://github.com/thruthesky/fireflutter/tree/v0.1).


Table of contents

- [Fire Flutter](#fire-flutter)
- [Features](#features)
- [Installation](#installation)
  - [Running the example](#running-the-example)
  - [Creating a new project](#creating-a-new-project)
  - [Firebase installation](#firebase-installation)
- [Packages](#packages)

# Features

- User
  - User registration is done with Firebase Flutter UI.


- Chat

  - A complete chat functionality which includes
    - Group chat
    - Inviting users
    - Blocking users
    - Kickout users
    - Changing settings of chat room
  - Expect more to come.


- Push notification



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

- You need enable neccessary Firebase settings to login, chat, and do more.



# Packages

- We use [Getx](https://pub.dev/packages/get) for route & state management.
- We use [FlutterFire UI](https://firebase.flutter.dev/docs/ui/overview) for Firebase auth and other UI examples.
  - You may build your own UI.



