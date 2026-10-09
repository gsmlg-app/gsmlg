import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_bloc/navigation_bloc.dart';

void main() {
  test('initial state shows navigation and uses breakpoint rail expansion', () {
    final bloc = NavigationBloc();
    addTearDown(bloc.close);

    expect(bloc.state, const NavigationState());
    expect(bloc.state.navigationVisible, isTrue);
    expect(bloc.state.isExtended, isNull);
  });

  blocTest<NavigationBloc, NavigationState>(
    'hiding navigation preserves the automatic expansion preference',
    build: NavigationBloc.new,
    act: (bloc) => bloc.add(const NavigationVisibilityChanged(false)),
    expect: () => [const NavigationState(navigationVisible: false)],
  );

  blocTest<NavigationBloc, NavigationState>(
    'visibility changes preserve a manually collapsed rail',
    build: NavigationBloc.new,
    seed: () => const NavigationState(isExtended: false),
    act: (bloc) => bloc.add(const NavigationVisibilityChanged(false)),
    expect: () => [
      const NavigationState(navigationVisible: false, isExtended: false),
    ],
  );

  blocTest<NavigationBloc, NavigationState>(
    'expansion changes preserve hidden navigation',
    build: NavigationBloc.new,
    seed: () => const NavigationState(navigationVisible: false),
    act: (bloc) => bloc.add(const NavigationRailExtendedChanged(true)),
    expect: () => [
      const NavigationState(navigationVisible: false, isExtended: true),
    ],
  );

  blocTest<NavigationBloc, NavigationState>(
    'restoring navigation keeps the manually expanded rail',
    build: NavigationBloc.new,
    seed: () =>
        const NavigationState(navigationVisible: false, isExtended: true),
    act: (bloc) => bloc.add(const NavigationVisibilityChanged(true)),
    expect: () => [const NavigationState(isExtended: true)],
  );

  blocTest<NavigationBloc, NavigationState>(
    'collapse and expand preserve visibility while replacing the preference',
    build: NavigationBloc.new,
    act: (bloc) => bloc
      ..add(const NavigationRailExtendedChanged(false))
      ..add(const NavigationRailExtendedChanged(true)),
    expect: () => [
      const NavigationState(isExtended: false),
      const NavigationState(isExtended: true),
    ],
  );

  blocTest<NavigationBloc, NavigationState>(
    'repeated visibility changes do not emit duplicate states',
    build: NavigationBloc.new,
    act: (bloc) => bloc
      ..add(const NavigationVisibilityChanged(false))
      ..add(const NavigationVisibilityChanged(false)),
    expect: () => [const NavigationState(navigationVisible: false)],
  );
}
