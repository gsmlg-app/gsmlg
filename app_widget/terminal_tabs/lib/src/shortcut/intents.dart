import 'package:flutter/widgets.dart';

class NewWindowIntent extends Intent {
  const NewWindowIntent();
}

class ToggleFullscreenIntent extends Intent {
  const ToggleFullscreenIntent();
}

class NewTabIntent extends Intent {
  const NewTabIntent();
}

class NextTabIntent extends Intent {
  const NextTabIntent();
}

class PreviousTabIntent extends Intent {
  const PreviousTabIntent();
}

class GoToTabIntent extends Intent {
  final int tabIndex;
  const GoToTabIntent(this.tabIndex);
}

class ShowTabSwitcherIntent extends Intent {
  const ShowTabSwitcherIntent();
}
