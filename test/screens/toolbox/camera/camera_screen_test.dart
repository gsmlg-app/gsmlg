import 'package:app_locale/app_locale.dart';
import 'package:camera/camera.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/toolbox/camera/camera_screen.dart';

const _frontCamera = CameraDescription(
  name: 'front',
  lensDirection: CameraLensDirection.front,
  sensorOrientation: 0,
);
const _backCamera = CameraDescription(
  name: 'back',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 0,
);
const _cameras = [_frontCamera, _backCamera];

void main() {
  testWidgets(
    'leaving camera screen releases its camera without an exception',
    (tester) async {
      final bloc = _ScreenCameraBloc();
      try {
        bloc.publish(const CameraLoaded(cameras: _cameras));

        await tester.pumpWidget(_cameraApp(bloc));
        await tester.pumpAndSettle();
        expect(bloc.events, contains(isA<CameraInitCameras>()));

        await tester.pumpWidget(const SizedBox.shrink());

        expect(tester.takeException(), isNull);
        expect(bloc.events, contains(isA<CameraStop>()));
      } finally {
        final closing = bloc.close();
        await tester.pump();
        await closing;
      }
    },
  );

  testWidgets(
    'camera switch removes the old preview and shows the replacement',
    (tester) async {
      final bloc = _ScreenCameraBloc();
      final oldController = _initializedController(_frontCamera);
      final newController = _initializedController(_backCamera);
      addTearDown(oldController.dispose);
      addTearDown(newController.dispose);
      try {
        bloc.publish(
          CameraLoaded(cameras: _cameras, controller: oldController),
        );

        await tester.pumpWidget(_cameraApp(bloc));
        await tester.pumpAndSettle();
        expect(
          tester.widget<CameraPreview>(find.byType(CameraPreview)).controller,
          same(oldController),
        );

        await tester.tap(find.text('Back'));
        expect(
          bloc.events.whereType<CameraSwitched>().single.camera,
          _backCamera,
        );
        bloc.publish(const CameraLoaded(cameras: _cameras));
        await oldController.dispose();
        await tester.pump();

        expect(find.byType(CameraPreview), findsNothing);
        expect(tester.takeException(), isNull);

        bloc.publish(
          CameraLoaded(cameras: _cameras, controller: newController),
        );
        await tester.pump();
        expect(
          tester.widget<CameraPreview>(find.byType(CameraPreview)).controller,
          same(newController),
        );
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      } finally {
        final closing = bloc.close();
        await tester.pump();
        await closing;
      }
    },
  );
}

Widget _cameraApp(CameraBloc bloc) {
  return BlocProvider<CameraBloc>.value(
    value: bloc,
    child: MaterialApp(
      localizationsDelegates: AppLocale.localizationsDelegates,
      supportedLocales: AppLocale.supportedLocales,
      home: const CameraScreen(),
    ),
  );
}

CameraController _initializedController(CameraDescription camera) {
  return CameraController(camera, ResolutionPreset.max, enableAudio: false)
    ..value = CameraValue.uninitialized(
      camera,
    ).copyWith(isInitialized: true, previewSize: const Size(640, 480));
}

// Screen tests control the published states; native lifecycle coverage lives in
// camera_bloc_test.dart and uses the real CameraBloc.
class _ScreenCameraBloc extends Bloc<CameraEvent, CameraState>
    implements CameraBloc {
  _ScreenCameraBloc() : super(const CameraInitial());

  final events = <CameraEvent>[];

  @override
  void add(CameraEvent event) {
    events.add(event);
  }

  void publish(CameraState state) => emit(state);
}
