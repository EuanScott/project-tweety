# ADR-0013: Firebase config is committed, and its API keys are restricted to the app's identity

Status: accepted
Date: 2026-10-03
Decision maker: Euan Scott

## Context

The app now starts Firebase in `lib/dart_init.dart`. Startup reads three
generated config files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/core/firebase/firebase_options.constants.dart`

Each file holds the Firebase project identifiers and one API key for its
platform. This repository is public. A committed key is therefore visible to
everyone.

Firebase states that these keys are not secrets. A Firebase client key
identifies the project. It does not authorise access to data. Security Rules
and App Check control access to data. A client app must ship its key inside the
binary, so anyone can extract the key from a released build anyway.

An unrestricted key still has a cost. Another app can use it to call the
enabled Google APIs, and those calls count against this project's quota.

This question came from the planning for Firebase Auth and Firestore sync for
Cards.

## Decision

**We will commit the Firebase config files, and we will restrict each API key to
this app's identity in Google Cloud Console.**

The restrictions are:

| Key                                    | Application restriction                                                                                                  | API restriction                         |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------|-----------------------------------------|
| Android key (auto created by Firebase) | Android apps: package `dev.euanscott.projecttweety`, SHA-1 `22:09:DF:56:49:4B:5B:28:CA:46:4E:9E:C9:CC:0E:09:9A:E1:0D:01` | The Firebase API list that Firebase set |
| iOS key (auto created by Firebase)     | iOS apps: bundle ID `dev.euanscott.projecttweety`                                                                        | The Firebase API list that Firebase set |

The SHA-1 is the fingerprint of the debug keystore on the decision maker's Mac,
`~/.android/debug.keystore`. `android/app/build.gradle` signs release builds
with the debug config too, so this one fingerprint covers every build made
today.

The project uses one Firebase project. Build flavours are not a prerequisite for
Firebase.

## Alternatives

- **Ignore the config files in git.** Rejected. It hides nothing, because the
  keys ship in every build. It also makes a fresh clone fail at startup until
  someone copies the files in by hand. That needs a secret store or a manual
  step, and this playground has neither.
- **Commit the files without key restrictions.** Rejected. It lets any app use
  this project's quota. The restriction costs one console change per key.
- **A separate Firebase project per build flavour.** Deferred. The app has no
  flavours yet, and it has no production users to protect from development data.

## Consequences

- A fresh clone builds and starts without extra setup.
- Unit and widget tests do not call `dartInit`, so `flutter test` and the
  continuous integration job in `.github/workflows/ci.yml` need no Firebase
  config. Only `integration_test/` starts Firebase, and it runs on a device.
- **Each new signing identity or package name must be added to the key
  restriction.** Until it is added, Firebase rejects that build's requests.
  The log shows `API_KEY_ANDROID_APP_BLOCKED`, `API_KEY_IOS_APP_BLOCKED`, or
  "Requests from this ... client application are blocked". These changes need a
  new entry:
    - a build on a different computer, because it has a different debug keystore
    - a continuous integration job that builds a signed app
    - a release keystore
    - Google Play App Signing, which re-signs the app with Google's key
    - a build flavour with a different package name or bundle ID, which also must
      be registered as an app in Firebase
- The restriction checks request headers that the Firebase SDKs send. Someone
  who extracts the key can forge those headers. The restriction stops casual
  reuse of the key. It does not protect data. When the app stores data in
  Firestore or Cloud Storage, Security Rules must protect that data, and App
  Check should be considered.
- Re-evaluate when the app gets a production release, a second Firebase project,
  or build flavours.

## Confirmation

Google Cloud Console → APIs & Services → Credentials, for project
`project-tweety`, must show "Android apps" and "iOS apps" in the Restrictions
column for the two keys. No key may show "None".

Before a change in the list under Consequences, add the new SHA-1, package name,
or bundle ID to the matching key. To get the SHA-1 of a keystore, run:

```sh
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore \
  -storepass android -keypass android | grep SHA1
```

After the change, run the app on that build. The log must show none of the
blocked-key messages above.
