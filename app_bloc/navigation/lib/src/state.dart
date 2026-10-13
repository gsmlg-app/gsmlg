part of 'bloc.dart';

@immutable
final class NavigationState extends Equatable {
  const NavigationState({
    this.navigationVisible = true,
    this.isExtended,
    this.isDuoConnected = false,
  });

  final bool navigationVisible;

  /// Null follows the active breakpoint until the user changes rail expansion.
  final bool? isExtended;

  /// Whether a companion secondary display is connected in dual screen mode.
  final bool isDuoConnected;

  NavigationState copyWith({
    bool? navigationVisible,
    bool? isExtended,
    bool? isDuoConnected,
  }) {
    return NavigationState(
      navigationVisible: navigationVisible ?? this.navigationVisible,
      isExtended: isExtended ?? this.isExtended,
      isDuoConnected: isDuoConnected ?? this.isDuoConnected,
    );
  }

  @override
  List<Object?> get props => [navigationVisible, isExtended, isDuoConnected];
}
