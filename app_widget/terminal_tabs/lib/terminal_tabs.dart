/// Terminal tab UI components.
///
/// This package provides tab UI components for the terminal application,
/// including plugin tabs, code editor tabs, devtools tabs, and more.
library;

// Tabs
export 'src/plugin_tab.dart';
export 'src/code_editor_tab.dart';
export 'src/add_host_tab.dart';
export 'src/playground.dart';

// Shared components
export 'src/shared/macos_titlebar.dart';
export 'src/shared/fluent_form.dart';
export 'src/shared/app_menu_card.dart';
export 'src/shared/fluent_navigator.dart';
export 'src/shared/fluent_back_button.dart';

// Shortcuts
export 'src/shortcut/global_shortcuts.dart';
export 'src/shortcut/intents.dart';
export 'src/shortcut/global_actions.dart';

// Menu components
export 'src/platform_menu.dart';
export 'src/context_menu.dart';
export 'src/ssh_host_key_dialog.dart';
export 'src/shortcuts.dart';

// Utilities
export 'src/target_platform.dart';

// Pages
export 'src/pages/host_edit_page.dart';
