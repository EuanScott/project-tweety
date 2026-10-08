# Security Policy

## Supported versions

This is a playground project with no releases. Only the latest commit on `main` gets security fixes.

## Reporting a vulnerability

Do not open a public issue for a vulnerability.

Report it privately through GitHub:

1. Go to the [Security tab](https://github.com/EuanScott/project-tweety/security) of this repository.
2. Select **Report a vulnerability**.
3. Describe the problem, the affected files or dependency, and the steps to reproduce it.

Only the maintainer can read the report. You can discuss the fix with the maintainer in the same private advisory.

## What to expect

This project has a single maintainer, who works on it in spare time. I aim to reply within 7 days. I will tell you if
the report is accepted, and credit you in the advisory unless you ask me not to.

## Scope

In scope: the code in this repository, its dependencies, and its GitHub Actions workflows.

Out of scope: the Firebase client configuration in `android/app/google-services.json` and
`ios/Runner/GoogleService-Info.plist`. Firebase client keys are public by design. Report them only if you can show
that a key is usable outside this app.
