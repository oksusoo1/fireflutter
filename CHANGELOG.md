# Change Log

## [0.2.21]

- Transform more functions from flutter code.

## [0.2.20]

- Refactoring Flutter models. Transfer post and comment CRUD into cloud funtions HTTP call.


## [0.2.19]

- Refactoring `UserService`.
- Working on user points.

## [0.2.18]

- Add `LocationService`.


## [0.2.17]

- Add `UserSettingsDoc`.
- Fix. Push notification on cloud function. Removing html tags and cut into 255 letters if body is too long.


## [0.2.16] - Minor updates on forum, chat.

- Delete uploade files when post or comment is deleted.
- Chat room id is formed as `UID__UID`.
- Meilisearch index management utility added.


## [0.2.15] - Changes on user, post, cloud function.

- Post properties had changed. `noOfComments`, `deleted`, `createdAt`, `updatedAt`. Its security rules had changed accordingly.
- Cloud functions for meilisearch had been added.
- Could functions for post management had been added.
- Report functionality had been added.
- Email verification had been added. It's working with dynamic links.
- Push notification had been added.
- Admin can manage categories. Sample UI had been added.
- Multilingual support.

## [0.2.12] - ReminderEdit widget controller

- Controller had added to `ReminderEdit` widget.

## [0.2.11] - Reminder

- Reminder functionality had been added.

## [0.2.10] - Adding firestore security rules

- Add firestore security rules for chat.

## [0.2.9] - UserPresence

- update on `UserPresence`.

## [0.2.8] - Inform

- `Inform` feature had added.

## [0.2.7] - User profile, chat, friend map

- User profile saving and displaying.
- 1:1 chat functionality has been added. see README.md for details.
- Friend map functionality has been added. see README.md for details.

## [0.2.6] - Phone sign-in code submit progress

- Display progress bar on sms code submit.
- Container builder for phone sign-in ui.

## [0.2.5] - Phone sign in

- Phone sign in functionality had been added.
  - `PhoneService` class had been added to help sign in with mobile phone.
  - There are two UI widgets that makes easy to UI work.


## [0.2.4] - Presence onError

- `onError` handler had been addeded to `Presence.instance.ativate()` to handle any error.

## [0.2.3] - Documentation

- No code changes but the document had been updated.
## [0.2.2] - Documentation

- No code changes but the document had been updated.
## [0.2.1] - Documentation

- No code changes but the document had been updated.

## [0.2.0] - Big change

- The concept of the project remains, but all of the code were removed to support latest version of Dart SDK and Flutter SDK from very old version of them and to adopt the latest Firebase Flutter packages.

- Add example code of sigin-in with Firebase Flutter UI.

- Add `User Presence` feature.

## [0.0.48] - Document update only

- Add documentation on location.

## [0.0.47] - Chat functions

- Document update on chat functions.

## [0.0.46] - Big break on user data events

This is going to be a big break.

- `userDataChange` and `userPublicDataChange` had been diverged from the previous version of `userChange`.
- And `userChange` is now used as an alias of `FirebaseAuth.instance.userChanges()` which will be fired on all user change events.
- Resets userPublicData property when user logs in or register.

## [0.0.45] - Revert fetch timeout

- Revert code related with `fetched` adn `fetchTimeout`. So, when it can't fetch posts, it would stuck there foerver.

## [0.0.44] - Fetch timeout

- `getPublicData()` has been deprecatd. Use `getUserPublicData()`.
- `fetched` becomes true if the app had fetched the first batch of posts from Firestore. Mostly the UI shows a spinner(loader) that the fetching is in progress. And if there is no document to fetch, it would ever become true that causes the UI show spinner and wait forever. So, it will turn into true after the [fetchTimeout] when there is no documents to fetch. This does not mean any documents are actually fetched.

## [0.0.43] - Variable name changes and minor changes.

- `email` and `password` of `loginOrRegister` are now optional.
- `userPublicData` has been renamed to `getUserPublicData`.
- `publicData` has been renamed to `userPublicData`.
- When user logs out, `userPublicData` become an empty Map.

## [0.0.42] - Storage related code update

- Storage security rules are updated and user's uid is attached to the file metadata.
  - User can delete their own files.
  - Admin can delete any files on storage via admin site.

## [0.0.42] - fix on global chat room listening

- fix on global chat room listening which causes permission error.
- Dependencies update in pubspec.yaml
- remove global property if it is null on getting its data

## [0.0.41] - Document update

- Document update.

## [0.0.40] - userChange event data

- `userChange` event delivers user information change type and Firebase.auth.User data if available.
- Preventing counting new messages when the user got a message for the room that he is currently in.
- Remove `_overwrite()` from chat room list.
- Chat related codes refacotring.
- Admin site development with Vue.js without Ionic. Ionic was dropped since it does not support vue class component at this time.

## [0.0.39] - Admin sites

- Sending chat push notification is now encapsulated inside ChatRoom.
- Removing deprecated and unused variables.
- Change push notification screen from `/forumView` to `postView`.
- Admin site development with Vuejs + Ionic

## [0.0.38] - Dependency update

- Some of packages have failed due to rxdart dependency issue.

## [0.0.37] - Updates and fixes

- User search based on GEO location has updated.
- Algolia index exception on comment.
- When post and comment are created/updated, author(login user)'s displayName and photoURL are saved in the post/comment documents.
- And other small fixes.

## [0.0.36] - Rewriting chat functionality and updates on push notifications and user location

- Complete rewriting on chat functionality. Unit testing codes also rewritten.
- Chat has push noitification by each room.
- User location search based on GEO location now works better.
- Minor updates and fixes on many parts of the code.

## [0.0.35] - appSetting() returns null by default

- `appSettings()` now return null instead of an empty string. This is a breaking change.
- `login()` can now update user's display name and photo url while login.

## [0.0.34] - Add user's public document data variable and minors.

- Some of error codes have been renamed.
- `_voteChange()` has been removed.
- Adding `ff.publicData` to hold user's public document data.
- `editPost()` now returns post document id.
- `CATEGORY_EMPTY` exception will be thrown when you are going to create/update a post.
- Algolia related property names are set as constant.
- Fixed on unexpected exception thrown when Algolia settings are not set.
- Changes of parameters in `loginorRegister`.

## [0.0.33] - Phone authentication

Users can now sign in with their phone numbers. Or user can also link their phone authentication to existing account. It's now optional.

## [0.0.31] - Remove Cloud Functions

Cloud Functions has been removed from the project and security rules has been changed. Voting(like and dislike) works better now.

- Algolia search works without functions.
- Post voteing(like and dislike) works without functions.

## [0.0.30] - chat

- sort options for room list.
- remove newMessage properties on room info.

## [0.0.29] - chat functionality

- basic chat functionality has been added. It's already good enough to build a chat app.
- fix on typo.

## [0.0.27] - meta path update

- bug fix. meta path upate.

## [0.0.26] - firestore structure change

- breaking change. user public and token collection has been changed.

## [0.0.25] - updateUserPublic

- `updateUserPublic` method is added to update user public data.

## [0.0.24] - createdAt, updatedAt on user document

- When user registers, `createdAt` and `updatedAt` will be added to user document.
- Whenever user updates profile, `updatedAt` will be updated and `userChange` event fires.

- document update.
- algolia search settings.

## [0.0.22] - push notification setting change. user language setting.

- change. push notification settings has been changed.
- language settings has been simplified by adding `userLanguage` getter.

## [0.0.21] - cancellation on user data

- fix on listening on user data. It produced error on user logout due to improper way of canncellation the subscription.

## [0.0.20] - Phone auth

- fix bug on phone auth

## [0.0.19] - Push notification update

- fix on push notification

## [0.0.18] - userChange event on photoURL

- userChange event fires on photoURL change

## [0.0.17] - deprecation of data

- data variable is now deprecated. Use `userData` instead.

## [0.0.16] - commentEdit

- Breaking change. The parameters of commentEdit method has been changed.
- Minor fixes.

## [0.0.15] - non-blocking initialze

- Fireflutter now introduces a non-blocking initialization. It's not a breaking change.

## [0.0.14] - Minor fix

- Minor fix

## [0.0.14] - ForumStatus has been added

- Breaking change
  - noPostsYet, noMorePosts has been replaced with `ForumData.staus`.

## [0.0.12] - minor fixes

- Minor code fixes.

## [0.0.11] - default settings

- should work without any settings.
- document update.

## [0.0.10] - Updating documents and minor fixes

- Updating documents and minor fixes

## [0.0.9] - document.

- Updating documents
- Minor bug fixes.

## [0.0.8] - Refactoring, minor bug fixes, document update.

- Refactoring codes on push notification, removing unused packages.
- Bug fixes.
- Document updates.

## [0.0.7] - App settings, localizations.

- App settings and localizations are updated in real time.
- Document update.

## [0.0.6] - typo.

- fix typo warning

## [0.0.5] - voting.

- voting for posts and comments.
- minor bug fixes.

## [0.0.4] - Forum CRUD, Push Notifications, User CRUD, Social Login.

- User CRUD.
- Forum CRUD is in progress.
- Push notification is in progress.
- Social Login is in progress.

## [0.0.3] - User registration, login, update, logout.

- Registration and more works on User crud.

## [0.0.2] - Adding user functions.

- Registration

## [0.0.1] - initial release.

- initial release.
