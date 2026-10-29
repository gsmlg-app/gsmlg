# Embedded conversation titles

GSMLG uses a separate MiniCPM5-1B CPU engine for title generation. The selected
chat provider, model selector, tools, MCP configuration and chat model are not
used by this transformer. No summarization, memory or Agent Loop behavior is added.

## Model provenance and preparation

- Official repository: https://huggingface.co/openbmb/MiniCPM5-1B-GGUF
- Revision: `3d55fac80935ae6456986ad2384b5cbcc4d6c948`
- Artifact: `MiniCPM5-1B-Q4_K_M.gguf`, Q4_K_M, 688,065,920 bytes (656.19 MiB).
- SHA-256: `81b64d05a23b17b34c475f42b3e72fbde62d4b92cc34541f7a8031d0752deafa`
- License: Apache-2.0. Bundled LICENSE and NOTICE accompany the weights.

Run before building or root Flutter tests:

```sh
python3 tools/conversation_title/prepare.py --download
python3 tools/conversation_title/prepare.py
```

The manifest is `tools/conversation_title/model.json`; weights are generated into
`assets/models/conversation_title/` and ignored by Git. Do not commit the binary.
Only the build-time Python downloader contacts Hugging Face. Every download uses
an immutable revision, verifies size and SHA-256, and renames a temporary file
only after verification. Runtime code has no download or inference HTTP client.

Flutter's asset declaration rejects a missing model. Android Gradle, Xcode build
phases, and desktop CMake also verify its checksum. CI and release/deployment
workflows prepare the pinned model before Flutter packaging. Never bypass these
gates to produce a smaller application without titles.

## Ownership and lifecycle

`ConversationTitleGenerator` is injected into ChatBloc by MainProvider.
`ConversationTitlePolicy` prepares only user and successful assistant **text**;
it excludes system messages, tools, attachments and assistant reasoning. Input
contains at most the first and three recent exchanges, with at most 160 UTF-8
bytes per message. JSON separates the untrusted conversation from task
instructions; role delimiter strings and common bearer/API-key shapes are
redacted. This does not guarantee arbitrary free-text secrets can be recognized.

The GGUF contains the official tokenizer and Jinja template. Inference uses
`lib_llama_cpp` / `lib_llama_cpp_server` 0.7.5, `enable_thinking=false` both directly
and in template kwargs, temperature zero, seed 42, and a 64-token output cap.
The context is limited to 2,048 tokens; oversized inputs fail safely. Invalid,
multiline, reasoning-only or excessive output leaves the fallback unchanged.
Task instructions follow the conversation language and explicitly preserve both
technical names and the concrete task; conversation data remains untrusted JSON.
A generated title is a probabilistic text transformation; title quality is not
guaranteed for every conversation or adversarial input.

Title work starts only after successful response persistence and completion.
The immediate first-user-message fallback remains visible and persisted.
Scheduling considers successful exchange counts 1, 4, 7, etc. Refinement asks the
model to return KEEP unless the topic materially changes or the existing title
is inadequate; identical titles and KEEP produce no title write. Attempts for
the same persisted content revision are deduplicated during the app session.
Failures are optional: they do not change the chat result or settings.

A serial title queue shares `LocalModelAccess` with foreground local inference.
New foreground sends, edits and regenerations cancel title inference before
waiting for the lease. Title engines never load through the mobile chat-model
singleton, replace a chat model, or start a foreground service. App backgrounding
cancels current work; native resources are destroyed in the worker before its
result is delivered. The engine is unloaded immediately after each request to
minimize resident memory; there is deliberately no warm resident title model.
Native initialization, streaming SHA-256 checks, polling and teardown happen in
a worker isolate, not the Flutter UI isolate. CPU inference uses four threads,
128-token batches and 64-token micro-batches. Execution has a 45-second native
loop deadline and a 60-second service timeout. Cancellation is cooperative;
a synchronous native model load must return before the worker can process it.
Cancelled candidates are requeued and checked against fresh persisted content
after foreground work or background suspension ends. Ordinary failures are not
retried in a loop. Diagnostics record failure types without conversation text.

Android skips on low-RAM devices or when less than 2 GiB memory is available.
iOS requires at least 6 GiB physical RAM and 2 GiB currently available to the
process. These are conservative admission checks, not an OOM guarantee. Other
apps can consume memory after the check; devices still need hardware qualification.

## Persistence and UI

Schema 18 adds title source, title revision, content revision, and persisted
assistant completion status. Existing titles become manual, and existing
unclassified assistant messages are not counted as successful exchanges.
Ambiguous custom legacy titles are never automatically replaced.

SQLite message triggers advance the content revision on insert, delete or actual
text/completion changes. Automatic title persistence is an UPDATE with conversation
ID, content revision, title revision and automatic-source predicates. It never
inserts or recreates a deleted conversation. General conversation saves preserve
existing generated/manual titles, so an old chat snapshot cannot undo a rename.
Only revision-zero fallbacks can be updated by a general save.
Title-only writes preserve `updatedAt` and history ordering.

ChatBloc emits title changes to both the cached session and history. Existing
chat-screen and history builders display them without navigation. The history
rename action marks a title manual even while generation is running. Edits,
regeneration, clear, deletion and background transitions invalidate delayed results.

## Packaging and verification

Apple and desktop builds place weights in Flutter assets and use their native
installed file path directly. They do not copy the model into application data or
load it with `rootBundle.load()`. Android's path-based GGUF engine cannot map a
compressed APK asset by file offset, so a native buffered copy installs the model
in `noBackupFilesDir/conversation_title/<sha256>/`. It verifies SHA-256 before an
atomic rename and does not allocate a model-sized Dart/JVM buffer. This necessary
Android private copy adds another 656.19 MiB after first use; all other platforms
map the installed model. Android GGUF entries are stored without compression.

Standalone APKs include the model in base Flutter assets. Android App Bundles
instead exclude that base copy and include the `conversation_title` install-time
asset pack. Its model and notices are available through AssetManager immediately
after installation. There is no fast-follow/on-demand request or Play Core runtime
download. Audit both formats; store size limits and Play delivery still require
qualification with a signed bundle. Fastlane verifies the resulting AAB before
upload and the iOS application before signing/export.

Audit every built application or archive before distribution:

```sh
python3 tools/conversation_title/verify_package.py /path/to/application-or-archive
```

The audit requires exactly one model with the pinned hash, both legal notices,
and the native llama.cpp library (or exported static iOS engine). Its success
proves contents, not native execution, signing, store acceptance or device support.

Run deterministic checks using the package working directories:

```sh
(cd app_lib/chat && flutter test --no-pub)
flutter test --no-pub app_bloc/chat/test app_lib/database/test test/screens/chat/conversation_titles_test.dart
flutter analyze --no-pub app_lib/chat app_bloc/chat app_lib/database app_lib/provider
python3 -m unittest discover -s tools/conversation_title -p 'test_*.py'
```

`gemma_repository_isolate_registration_test.dart` reads package-relative source;
running the entire chat package from the repository root gives a working-directory
failure. It passes when invoked from `app_lib/chat`.

The opt-in actual-engine test accepts `TITLE_MODEL_PATH` and `TITLE_LIBRARY_PATH`
and runs `app_lib/chat/test/minicpm_title_native_smoke_test.dart`. An installed-app
smoke test is `integration_test/conversation_title_offline_test.dart`; run it with
a disposable test installation on a device without user data. Do not run this
fixture over a populated `org.gsmlg.app` installation.
It resolves packaged assets and native libraries and disables Dart networking.
This is not proof that OS-level networking was disabled.
The equivalent driver is `test_driver/conversation_title.dart`; it also supports
`flutter drive --keep-app-running --use-application-binary=<APK> -d <device>
--driver=test_driver/conversation_title.dart
--target=integration_test/conversation_title_offline_test.dart` for a prebuilt
debug APK. Flutter drive otherwise uninstalls the application on completion,
including its private data. `--keep-app-running` only avoids that completion
cleanup; it is not a backup or protection against installation fallback. Use
disposable test installations and record networking state separately.

## Qualification record

Qualification host: MacBookPro18,4, Apple M1 Max, 32 GiB RAM, 2026-10-29.

| Platform | Packaging | Native execution |
| --- | --- | --- |
| macOS | Release `.app` and arm64 Debug `.app` content audits passed | arm64 installed-app smoke passed; packaged-engine and two-engine tests also passed |
| Android | Debug APK and AAB audits passed; device-specific install-time pack installed | Pixel Fold (Android 17, GS201) generated a title with no active default network |
| iOS | Signed arm64 Debug app built and packaged-model/native-engine audit passed | Native execution unverified; further iPad testing excluded by user request |
| Linux | App build blocked by existing missing GStreamer development packages | x64 native title and independent-engine preservation tests passed on CI |
| Windows | App build blocked by upstream duskmoon_highlight MSVC failure (#32) | x64 native title and independent-engine preservation tests passed on CI |

Actual native cold title transformation on the Mac host with the final language-aligned
prompt: 19,978 ms (`可复用 Flutter 组件设计`). An earlier prompt took 17,665 ms, including
SHA-256, engine loading, prompt processing, decoding and teardown. Generated
title: `设计可复用 Flutter 组件`. A separate native benchmark using the same model
and CPU configuration with a shorter fixed prompt measured 3.415 s loading,
7.025 s first inference, 0.801 s repeated cached inference, and peak process RSS
1,281,441,792 bytes (1.19 GiB). The cached result is a backend benchmark;
production unloads immediately and therefore has no resident warm-engine path.
Repeating the smoke test against the actual Release app's weights and library
passed with a 27,528 ms cold transformation under concurrent build load. These
Flutter test processes use the x86-64 tester on the Apple Silicon host; this is
native-library qualification under Rosetta, not a launched arm64 application UI
or physical iOS-device measurement.

The macOS Release app is 1,360.1 MB as reported by Flutter (1,328,604 KiB of disk
blocks). The model contributes exactly 688,065,920 uncompressed bytes plus small
notices. There is no measured compressed release delta against a matched baseline.
Package contents do not establish signing, notarization or store acceptance.
Mock tests are not evidence of native compatibility. Unqualified platforms must
not be advertised as verified. No release or store deployment was performed.

Physical Android qualification used Pixel Fold `37011FDH8119SS`. Bundletool 1.18.3
created device-specific APKs from the debug AAB; `pm path` confirmed the
`split_conversation_title.apk` install-time pack. The previous extracted title
weight was removed before launch. Wi-Fi and mobile data were disabled and
`dumpsys connectivity` reported `Active default network: none`. The strict
installed-app smoke test passed with `可复用 Flutter 组件设计` in **13,774 ms**,
including verification/extraction, model initialization, inference and teardown.
Sampled peak process VmHWM was **1,239,672 KiB**, peak VmRSS **1,239,648 KiB**
(24 samples). Network settings were restored. This is debug/arm64 hardware
qualification; it does not prove Play acceptance or release signing. The audited
standalone debug APK was 1,106,602,994 bytes; the earlier audited debug AAB was
850,462,566 bytes. Exact final bundle size can vary with compiled test code.

The separate desktop-engine test confirms a loaded primary engine produces the
same response after title-engine destruction. Deterministic unit tests cover
local-resource serialization; the Android hardware run used the title smoke
fixture, not a concurrently loaded user chat model. iOS adapter type-checking
passed for device arm64; iOS execution and full Linux/Windows application packaging remain unverified;
the later native-runtime qualification is recorded below.
CI includes packaged-model native smoke tests for Linux and Windows.

### CI qualification limits (2026-10-29)

At commit `895e9d3`, CI format and analysis passed. The title checks passed
locally: chat package 90 tests (three opt-in tests skipped), ChatBloc/database/
title lifecycle 82 tests, packaging five tests, and two opt-in actual Mac engine
tests. The final Mac run generated `可复用 Flutter 组件设计` in 22,612 ms and also
passed the two-engine preservation check. The final audited debug AAB is
850,464,014 bytes. A signed arm64 iOS debug app was built and its bundled model
and native framework audited (1,294,476,314 bytes total app-file sizes).

The repository-wide CI failures are distinct from those title checks:

- Linux app packaging stops because the runner lacks `gstreamer-1.0` development
  packages required by the existing audioplayers plugin. This also failed on the
  preceding main commit. Install `libgstreamer1.0-dev` and `libgstreamer-plugins-base1.0-dev` before rerunning the app build and package audit.
- Windows app packaging stops in duskmoon_highlight 2.2.3's Crystal scanner under
  MSVC (`C2466`/`C2133`, variable-length array `word[max_word_size + 4]`).
  TODO(upstream): duskmoon-dev/flutter-duskmoon-ui#32
  (https://github.com/duskmoon-dev/flutter-duskmoon-ui/issues/32). This is a blocker;
  no grammar removal or dependency-cache patch is used. Adopt a published fix
  within authorized scope and repeat the Windows app build, content audit and
  installed runtime verification. Source inspection also finds that declaration
  in 2.2.5 and the latest published 2.2.7 (scanner.c:1307). The 2.2.7 hook still
  selects C11 for Windows; its changelog describes hook API compatibility, not
  an MSVC VLA fix. This is source inspection, not a new Windows build claim.
  Neither version alone is an evidenced unblock.
- The full Melos test job fails because app_system_metrics_linux has a `test/`
  directory without Dart test files, matching the preceding main failure. This
  task does not change that unrelated package or weaken its test command.

CI runs the title package's actual-engine tests independently before the app
builds. Those tests can qualify the native title runtime even when unrelated
application plugins prevent packaging; they do not qualify an installed Linux
or Windows app. The original package audits remain required after a successful
application build.

The physical iPad Air M3 was reachable over local-network debugging, but was
locked. An initial transfer failed with CoreDevice 3002 / IXRemoteErrorDomain 6;
a subsequent Flutter launch stalled waiting for Xcode debugging. iOS model
execution, offline behavior, latency and memory remain unverified. Further iPad testing was stopped at the user's request. The normal `lib/main.dart`
application was reinstalled successfully, preserving app data; no more iPad tests
are authorized by this task.


### Additional native qualification

On CI commit `1eadb7b` ([run 40735593589](https://github.com/gsmlg-app/gsmlg/actions/runs/40735593589)),
the independent title package tests passed on both Linux x64 and Windows x64.
Each ran the actual pinned GGUF and native 0.7.5 library, generated
`可复用 Flutter 组件设计`, and proved a separately loaded primary engine still
responded identically after title-engine teardown. Cold transformation times were
6,676 ms on the Linux CI runner and 11,910 ms on the Windows CI runner. These
are VM runner measurements, not physical-device claims; peak memory was not
recorded there. CI format and analyze passed. The three documented full-app /
repository-wide blockers still failed, and their gates were not weakened.

A separate Debug macOS app was built explicitly for arm64 and passed the package
audit. The installed-app driver resolved the bundled asset path itself, with Dart
networking disabled, and passed with `可复用 Flutter 组件设计` in **23,795 ms**.
The app binary was confirmed `Mach-O 64-bit executable arm64`; this run did not
use the Rosetta Flutter tester. Sampled peak **app RSS was 1,449,424 KiB** (277
samples, 250 ms sampling) under concurrent build load. Flutter initially failed
to foreground the external-volume app, so opening that same built bundle directly
was necessary before the first test frame. The driver exited zero and closed
the test app. OS networking was not disabled on the Mac; the physical Android
run above supplies the OS-offline installation/runtime evidence.

Both Android and iPad test fixtures were replaced with builds using the normal
`lib/main.dart` entry point. No release was published.

**Android data-loss correction (2026-10-29):** the earlier Android APK driver
run omitted `--keep-app-running`. Flutter 3.47.8 calls
`FlutterDriverService.stop()` on completion, which uninstalls the application
when a package was supplied. The successful driver log ended at 00:53 local
time; the device subsequently reported a new first-install time of 01:10:51.
The user later reported missing data. The previous claim of data preservation
was incorrect: later replacement installs cannot restore data deleted by the
driver cleanup. No pre-test application-data backup was recorded. Further
installations and tests were stopped while recovery sources were investigated.

### Release-mode Android package audit

The normal command `flutter build appbundle --release --target-platform=android-arm64
--target=lib/main.dart` completed successfully. The resulting
`build/app/outputs/bundle/release/app-release.aab` is **855,552,337 bytes**.
Its install-time pack contains exactly one model with the pinned SHA-256, both
notices, and the package contains the llama.cpp runtime, `libapp.so`,
`libflutter.so` and Dart AOT symbol metadata. The artifact was signed by the
repository's Android Debug fallback because no release keystore was configured;
it is not a production-signed or Play-qualified distribution and was not uploaded.

After running integration fixtures, use the normal Flutter command with pub
resolution enabled to regenerate release plugin registration. This Flutter
version's `--no-pub` path retains debug-only plugin registration. Qualification
also temporarily redirected generated outputs to an external volume for disk
capacity; after restoring the normal Flutter release intermediate path, its
stale task-created AOT cache was regenerated. A compile-only and JNI-staging
diagnostic then confirmed the AOT library before the final standard build.
No source workaround, SDK patch, disabled stripping check, or modified dependency
was needed for the successful release-mode Android build.

### Desktop qualification follow-up

The later CI run `40907226521` at `091eb8a2415d42eb0dfeb2426f4679cd2fbf53cc`
passed formatting, analysis and the independent Linux/Windows title-engine tests.
Full Linux packaging still failed because `audioplayers_linux` requires
`gstreamer-1.0`, `gstreamer-app-1.0` and `gstreamer-audio-1.0`; CI and Linux
release setup now install their development packages (and libsecret).
Windows packaging still resolved `duskmoon_highlight 2.2.5` and reproduced the
Crystal scanner error. Upstream issue #32 has since closed with commit
`89fb41e74fb14ba9e7ecad5287ebe5003bef9cf8`, replacing the variable-length buffer
with a constant-size buffer while preserving identifier limits. Published
`duskmoon_highlight 2.2.8` is now resolved in the lockfile; the official archive
contains the constant-size buffer and its changelog lists the MSVC fixes. Only
that dependency changed in resolution. Downstream package verification remains
required before reporting Windows packaging as supported.

That run's full Melos test job still failed because
`app_system_metrics_linux/test` contains no Dart `*_test.dart` files. This is
separate from the title runtime checks and remains an unresolved repository test
gate. No physical-device application was installed or tested in this follow-up.
