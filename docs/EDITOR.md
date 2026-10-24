# Editor

Open **Toolbox → Editor** to create or edit a text/code file. The page uses
DuskMoon's `DmCodeEditor`, including line numbers, syntax highlighting and
undo/redo. Save with Ctrl/Cmd+S; use Ctrl/Cmd+Shift+S for Save As. New, Open,
navigation and application exit ask how to handle unsaved changes. Cancelling
a picker or a failed operation keeps the current document.

Files must be valid UTF-8, at most 16 MiB, and contain no NUL bytes. Saving
preserves the UTF-8 BOM and source newline style. Save As of an unchanged file
preserves its original bytes, including mixed line endings. A read-only source
uses Save As. Unsaved buffers live in memory; forced process termination does
not restore them.

## Platform integration

Android, iOS and macOS declare text/source document types in their app manifests.
The installed app appears as an optional editor; the operating system controls
its Open With UI. Android writes through the original document-provider URI.
iOS and macOS retain the original file URL and use security-scoped, coordinated
access. Desktop filesystem saves retain file permissions and follow symlinks
to the target. Files received during startup or an unsaved-change confirmation
remain queued until the Editor can handle them.

The `app_editor` workspace package owns file access, encoding and the incoming
queue. `editor_bloc` owns the current buffer and saved snapshot. `MainProvider`
provides both; `App` routes system-open events and the Editor drains the queue.
The DuskMoon focused-input workaround is tracked in
[flutter-duskmoon-ui#26](https://github.com/duskmoon-dev/flutter-duskmoon-ui/issues/26).
Remove it after upgrading to a release that correctly detaches input when
`readOnly` changes, and rerun the focused-save regression.

## Optional user-level file associations

GSMLG can appear in the system's **Open With** menu for text and source files.
Registration is optional and does not change default applications. Keep the whole
Flutter release bundle together: the executable needs its adjacent libraries and
assets. Register again after moving the bundle.

### Windows

The Windows release bundle includes `register-editor.ps1` beside `gsmlg.exe`.
From the bundle, run in PowerShell:

```powershell
.\register-editor.ps1
```

To use the repository helper with an existing bundle, supply its executable:

```powershell
.\windows\register-editor.ps1 -ExecutablePath 'C:\Apps\GSMLG\gsmlg.exe'
```

The helper writes only to the current user's
`HKCU\Software\Classes` and adds `GSMLG.Editor` to supported extensions' Open With
choices. It leaves existing defaults and `UserChoice` values alone. Administrator
access is unnecessary. Remove this registration with:

```powershell
.\register-editor.ps1 -Unregister
```

### Linux

The Linux build bundle includes `install-editor.sh` and
`org.gsmlg.app.editor.desktop`. From the bundle, run:

```sh
./install-editor.sh
```

The helper resolves the adjacent `gsmlg` executable and installs a desktop entry
under `${XDG_DATA_HOME:-$HOME/.local/share}/applications`. It quotes paths containing
spaces and shell characters and refreshes the desktop MIME cache when
`update-desktop-database` is available. The system text-editor theme icon is used;
no extra icon installation is needed.

To use the repository helper with an existing bundle, supply its executable:

```sh
./linux/install-editor.sh --executable '/opt/GSMLG bundle/gsmlg'
```

Remove only the GSMLG Editor entry with:

```sh
./install-editor.sh --uninstall
```

The helper does not run `xdg-mime default` or modify `mimeapps.list`. If the desktop
database tool is unavailable, installation still succeeds; desktop menu refresh
behavior depends on the desktop environment. Windows and Linux may launch a new
GSMLG window for each system open request.

## Verification

Run the document, state, UI and startup checks together from the workspace root:

```sh
flutter test --no-pub app_lib/editor/test app_bloc/editor/test \
  test/screens/toolbox/editor/editor_screen_test.dart \
  test/screens/toolbox/toolbox_screen_test.dart \
  test/screens/app/editor_startup_test.dart \
  test/screens/app/splash_screen_test.dart
```

These cover UTF-8/BOM/newline preservation, cancellation and failed writes,
read-only Save As, system-open queuing, unsaved-change guards, programmatic IME edits,
undo/redo, shortcuts, narrow light/dark layouts and splash navigation. Widget
tests use simulated file access; they do not establish native provider behavior.

Native verification for this change includes macOS Debug, Android Debug APK and
iOS Simulator Debug builds, plus document declarations in their built bundles.
On macOS, system-open startup, syntax rendering and the native Save As panel were
observed. The UI automation tool could not focus the editor and later timed out
reading the save panel, so interactive editing/saving remains unverified there.
Android/iOS document-provider roundtrips and Windows/Linux application runtime
still require checks on those platforms.

### Mobile touch editing blocker

On 2026-10-23, testing the installed Release build from `98ad462` on the physical
Pixel Fold (Android 17 / API 37) reproduced a mobile input failure: tapping the
Editor body moves the cursor but does not show the software keyboard. The native
Save As filename input shows the keyboard normally. No document was modified or
saved during this diagnostic check.

An isolated widget reproduction passes for a normal `TextField` and fails for
`DmCodeEditor`: the editor connects its input client but sends only
`TextInput.setClient` and `TextInput.setEditingState`, without `TextInput.show`.
In `duskmoon_code_engine` 2.2.3, `InputHandler.attach()` attaches and synchronizes
the input connection without requesting the keyboard; editor taps do not request
it either. The reproduction and evidence are recorded in
[flutter-duskmoon-ui#28](https://github.com/duskmoon-dev/flutter-duskmoon-ui/issues/28).

This blocks mobile touch editing. The previous device build, installation and
standalone launch checks did not verify this workflow. No local workaround is
applied under the upstream blocker policy. Resume after a published upstream fix
is adopted, then verify initial tap, dismiss and retap, multiline input, saving
and reopening on the Pixel Fold. Android and iOS document-provider roundtrips
remain unverified.

`duskmoon_highlight` 2.2.3 can print `File modified during build. Build must be
rerun.` and recompile its native grammars on unchanged builds. Generated C sources
are recorded as inputs by its build hook. This nonfatal cache issue is tracked in
[flutter-duskmoon-ui#27](https://github.com/duskmoon-dev/flutter-duskmoon-ui/issues/27);
the app uses the published dependency without a local patch.
<!-- TODO(upstream): duskmoon-dev/flutter-duskmoon-ui#27; verify native build cache
reuse after upgrading to a fixed release. -->
