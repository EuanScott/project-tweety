# Security Policy

## Supported versions

This is a playground project with no releases. Only the latest commit on `main` gets security fixes.

## Reporting a vulnerability

Do not open a public issue for a vulnerability.

Report it privately through GitHub:

1. Go to the [Security tab](https://github.com/EuanScott/project-tweety/security) of this repository.
2. Select **Report a vulnerability**.
3. Describe the problem, the affected files or dependency, and the steps to reproduce it.

Only the maintainer can read the report. You and the maintainer can discuss the fix in the same private advisory.

## What to expect

This project has one maintainer, who works on it in spare time. The maintainer aims to reply within 7 days. The reply
says whether the report is accepted. The advisory credits you, unless you ask for no credit.

## Scope

In scope: the code in this repository, its dependencies and its GitHub Actions workflows.

Out of scope: the Firebase API keys in these files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/core/firebase/firebase_options.constants.dart`

Firebase client keys are not secrets. Each key is restricted to this app's identity, as
[ADR-0013](docs/decisions/0013-firebase-config-committed-with-restricted-keys.md) records. Report a key only if you can
use it from outside this app.
