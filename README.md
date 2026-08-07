# Project Tweety

Not really much going on here. This is just a playground to try out some ideas and some new things
that I find cool or interesting.

The only real Pathway/Guideline that I am following
is [this Flutter Roadmap](https://roadmap.sh/flutter).

Ideas to work on, are logged as [Issues](https://github.com/EuanScott/project-tweety/issues) in the GitHub repo.

_Why a Flutter project_, you may ask? Well that's because at the time of writing this doc, I just
came off a Flutter project and thought it would be cool to explore some things that I wasn't able to
do on that project.

## Development Style

Historically, I've always used the [Git FLow](https://www.gitkraken.com/learn/git/git-flow) approach
to software development, in particular Mobile App development. I have however, of late come
across [Trunk Based Development](https://trunkbaseddevelopment.com/) and I think I may just be
giving that a try. After all, this project isn't being worked on in a big corporate environment.

## Setup & Usage

Nothing fancy here, I'm just following the "Get started" guide on
the [Official Flutter Docs](https://docs.flutter.dev/get-started/install)

This project requires Flutter `3.44.8` (Dart `3.12.2`). After installing
dependencies, use the following validation loop:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze --no-fatal-infos
dart run tool/agent_context/validate.dart
flutter test
```

Run one test file with:

```sh
flutter test test/path_test.dart
```

This is the same command CI runs, so a green local loop means a green build.
Native Android and iOS coverage remains an explicit device/simulator check:

```sh
flutter test integration_test/cards_sqlite_smoke_test.dart -d <device-id>
```

See [the testing guide](docs/testing/README.md) for what belongs in `test/`,
`integration_test/`, and `test_driver/`.

## Project Docs

Broader project guides live under [`docs/`](docs/). Current guides include:

- [Navigation, deep links, and route guards](docs/testing/navigation.md)
- [Cards SQLite persistence and native smoke testing](docs/architecture/cards_sqlite_foundation.md)
- [Architecture Decision Records](docs/decisions/README.md)

## API Documentation

This project uses Dart doc comments for generated API documentation.

To generate the docs locally:

```sh
dart doc --output doc/api
```

Then open the generated docs:

```sh
open doc/api/index.html
```

The generated `doc/api/` output is ignored by git.
