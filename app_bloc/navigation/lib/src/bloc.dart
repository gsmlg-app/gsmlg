import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'event.dart';
part 'state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationVisibilityChanged>(_onVisibilityChanged);
    on<NavigationRailExtendedChanged>(_onRailExtendedChanged);
  }

  void _onVisibilityChanged(
    NavigationVisibilityChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(navigationVisible: event.visible));
  }

  void _onRailExtendedChanged(
    NavigationRailExtendedChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(isExtended: event.extended));
  }
}
