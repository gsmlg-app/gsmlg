import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:duskmoon_form/duskmoon_form.dart';

import '../bloc/camera_settings_form_bloc.dart';

/// Camera settings form widget for use in dialogs
class CameraSettingsFormWidget extends StatelessWidget {
  const CameraSettingsFormWidget({
    super.key,
    required this.formBloc,
    required this.videoDevices,
    required this.audioDevices,
  });

  final CameraSettingsFormBloc formBloc;
  final List<CameraMacOSDevice> videoDevices;
  final List<CameraMacOSDevice> audioDevices;

  String? _getDeviceName(String? deviceId, List<CameraMacOSDevice> devices) {
    if (deviceId == null) return null;
    final device = devices.where((d) => d.deviceId == deviceId).firstOrNull;
    if (device == null) return deviceId;
    return '${device.localizedName} (${device.manufacturer})';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: formBloc,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CameraSettingsDropdown<CameraMacOSMode>(
              selectFieldBloc: formBloc.cameraMode,
              labelText: 'Camera Mode',
              itemLabel: (value) => value.name,
            ),
            const SizedBox(height: 16),
            _CameraSettingsDropdown<String>(
              selectFieldBloc: formBloc.deviceId,
              labelText: 'Video Device',
              itemLabel: (value) =>
                  _getDeviceName(value, videoDevices) ?? value,
            ),
            const SizedBox(height: 16),
            _CameraSettingsDropdown<String>(
              selectFieldBloc: formBloc.audioDeviceId,
              labelText: 'Audio Device',
              itemLabel: (value) =>
                  _getDeviceName(value, audioDevices) ?? value,
            ),
            const SizedBox(height: 16),
            _CameraSettingsDropdown<CameraOrientation>(
              selectFieldBloc: formBloc.orientation,
              labelText: 'Orientation',
              itemLabel: (value) => value.name,
            ),
            const SizedBox(height: 16),
            _CameraSettingsDropdown<Torch>(
              selectFieldBloc: formBloc.torch,
              labelText: 'Torch',
              itemLabel: (value) => value.name,
            ),
            const SizedBox(height: 16),
            DmSwitchFieldBlocBuilder(
              booleanFieldBloc: formBloc.isVideoMirrored,
              body: Text(
                'Mirror-Flip Video',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WORKAROUND(upstream): duskmoon-dev/flutter-duskmoon-ui#15
class _CameraSettingsDropdown<Value> extends StatelessWidget {
  const _CameraSettingsDropdown({
    required this.selectFieldBloc,
    required this.labelText,
    required this.itemLabel,
  });

  final SelectFieldBloc<Value, dynamic> selectFieldBloc;
  final String labelText;
  final String Function(Value value) itemLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final labelStyle = textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = textTheme.bodyLarge?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    final placeholderStyle = valueStyle?.copyWith(
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
    );

    return BlocBuilder<SelectFieldBloc<Value, dynamic>,
        SelectFieldBlocState<Value, dynamic>>(
      bloc: selectFieldBloc,
      builder: (context, fieldState) {
        final items = fieldState.items;
        final selectedValue =
            items.contains(fieldState.value) ? fieldState.value : null;

        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  labelText,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.86),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 48,
                    child: Material(
                      type: MaterialType.transparency,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Value>(
                          value: selectedValue,
                          isExpanded: true,
                          isDense: true,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          dropdownColor: colorScheme.surfaceContainerHighest,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          hint: Text(
                            items.isEmpty ? 'No options' : 'Select',
                            style: placeholderStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: valueStyle,
                          items: items
                              .map(
                                (value) => DropdownMenuItem<Value>(
                                  value: value,
                                  child: Text(
                                    itemLabel(value),
                                    style: valueStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: items.isEmpty
                              ? null
                              : (value) => selectFieldBloc.changeValue(value),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
