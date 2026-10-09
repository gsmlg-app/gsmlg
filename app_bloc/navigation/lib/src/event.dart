part of 'bloc.dart';

@immutable
sealed class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

final class NavigationVisibilityChanged extends NavigationEvent {
  const NavigationVisibilityChanged(this.visible);

  final bool visible;

  @override
  List<Object?> get props => [visible];
}

final class NavigationRailExtendedChanged extends NavigationEvent {
  const NavigationRailExtendedChanged(this.extended);

  final bool extended;

  @override
  List<Object?> get props => [extended];
}
