part of 'bloc.dart';

@immutable
final class NavigationState extends Equatable {
  const NavigationState({this.navigationVisible = true, this.isExtended});

  final bool navigationVisible;

  /// Null follows the active breakpoint until the user changes rail expansion.
  final bool? isExtended;

  NavigationState copyWith({bool? navigationVisible, bool? isExtended}) {
    return NavigationState(
      navigationVisible: navigationVisible ?? this.navigationVisible,
      isExtended: isExtended ?? this.isExtended,
    );
  }

  @override
  List<Object?> get props => [navigationVisible, isExtended];
}
