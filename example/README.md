# Fireflutter Example

## Getting Started


- Install fireflutter and necessary setup stated in fireflutter README.md.



## example-profile branch

- Example profile does `Phone Sign-in` for users to sign-in.

- To make this happen,
  - for Android, SHA1 must be registered on debug mode.
  - for iOS,
    - push notification must be enabledand (URL scheme must be set on Xcode.
      - `Open Xcode by dobule clicking on example/ios/Runner/Runner.xcworkspace`.
      - `Add Push Notifications` under Signing & Capabilities.
      - `Add App ID into URL Scheme` under Info. Use `app-....` format.
    - APNs auth key should configured with FCM seeting in Firebase.




