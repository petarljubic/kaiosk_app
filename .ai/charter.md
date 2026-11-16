# kAIosk

Offline-first campsite app (first client: Camp Enigma) that replaces the paper book: check-in, pricing, camp map, reports and exports, with optional Firebase backup.

Primary users: A small group of people in a private company: the campsite owner and staff, on a tablet, laptop or phone.

## Behavior

- Tag board of 60 numbered tags: tap a free tag, pick a country, step people, pick a vehicle, set nights, and see a price breakdown in under a minute while offline
- Price a stay per person per night plus vehicle, electricity and stay tax from an editable rate list
- Check out: reprice against nights actually taken, apply a 3/5/10 percent or typed discount, mark paid, and free the tag
- Camp map: named parking places in their real positions showing the tag currently on each; places are never named after numbers
- Reports by month or year: guests by country, totals, revenue for any period, and a searchable history of stays
- Print any screen, export Excel for the accountant and PDF for the owner
- After optional sign-up, records back up and sync to Firebase and are readable from any device

## Out of scope

- none stated

## Constraints

- Fully usable with no network connection; never block on the network
- drift (local SQLite) is the source of truth; Firebase is backup and sync only
- Usable without authentication; sign-up is required only to sync with Firebase
- Web only (Flutter web, installable PWA)
- No secrets in the repository

## Delivery

- Git remote: `https://github.com/petarljubic/kaiosk_app`
- Default branch: `main`
- CI: `github-actions`
- Language: `generic`
- Build tool: `none`
- Package root: `kaiosk`
- Frameworks: flutter, material_ui
- Libraries: flutter_bloc, get_it, go_router, go_router_builder, drift, firebase_core, firebase_auth, cloud_firestore, mocktail
- Testing: flutter_test unit tests for domain and data; cubits tested with plain flutter_test and mocktail (no bloc_test); widget tests for views; Dart architecture tests in test/architecture/; approved Gherkin scenarios from the specifier skill
- Module map: Feature-first onion: lib/features/<feature>/{domain,data,view}; lib/core/ holds get_it DI, go_router, drift database and Firebase setup and is the composition root together with lib/main.dart. domain is pure Dart; data -> domain, core; view -> domain, core; features never import another feature's data or view. Enforced by the Dart tests in test/architecture/.

Toolchain versions in `.ai/decisions.json` are the versions used at setup. Refresh them before the first native CI run if a newer stable release is current.

## Commands

- Lint: `python tools/policy/check_all.py`
- Test: `python tools/policy/check_all.py`
- Architecture: `python tools/policy/check_all.py`
- Build: `python tools/write_build_info.py`
- Start: `flutter run -d web-server --web-port 3000`
- State check: `GET http://127.0.0.1:3000`
