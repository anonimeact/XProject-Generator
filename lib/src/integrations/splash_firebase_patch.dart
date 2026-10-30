import '../../core/configs/project_config.dart';
import '../templates/bloc/bloc_feature_template.dart';
import '../templates/getx/getx_feature_template.dart';
import '../templates/provider/provider_feature_template.dart';
import '../templates/riverpod/riverpod_feature_template.dart';
import 'setup_change_report.dart';

/// Wires `FirebaseService.init` into the generated splash entry.
///
/// Unmodified splash files (still equal to the create-time template) are
/// replaced with the Firebase variant of that same template, so setup and
/// create stay byte-for-byte aligned.
///
/// If the splash file was edited, the plain `Future.delayed` startup is
/// replaced in place and the Firebase imports are inserted. Files that
/// already call `FirebaseService.init` are returned unchanged.
String enableFirebaseInSplash({
  required String source,
  required StateManagement stateManagement,
  required ProjectConfig config,
}) {
  if (source.contains('FirebaseService.init')) {
    return source;
  }

  final plain = _normalize(_splashSource(stateManagement, config, false));
  final firebase = _splashSource(stateManagement, config, true);
  if (_normalize(source) == plain) {
    if (source.endsWith('\n') && !firebase.endsWith('\n')) {
      return '$firebase\n';
    }
    return firebase;
  }

  return _patchCustomSplash(source, stateManagement);
}

String _splashSource(
  StateManagement stateManagement,
  ProjectConfig config,
  bool useFirebase,
) {
  final resolved = config.copyWith(useFirebase: useFirebase);
  switch (stateManagement) {
    case StateManagement.getx:
      return GetxFeatureTemplate.splashController(resolved);
    case StateManagement.riverpod:
      return RiverpodFeatureTemplate.splashProvider(resolved);
    case StateManagement.bloc:
      return BlocFeatureTemplate.splashBloc(resolved);
    case StateManagement.provider:
      return ProviderFeatureTemplate.splashNotifier(resolved);
  }
}

/// Relative import of `firebase_service.dart` from the splash file.
String splashFirebaseImport(StateManagement stateManagement) {
  switch (stateManagement) {
    case StateManagement.getx:
      return '../../../core/services/firebase/firebase_service.dart';
    case StateManagement.riverpod:
    case StateManagement.bloc:
    case StateManagement.provider:
      return '../../../../core/services/firebase/firebase_service.dart';
  }
}

/// Path of the splash file that starts Firebase, relative to the project root.
String splashFirebaseRelativePath(StateManagement stateManagement) {
  switch (stateManagement) {
    case StateManagement.getx:
      return 'lib/features/splash/controllers/splash_controller.dart';
    case StateManagement.riverpod:
      return 'lib/features/splash/presentation/providers/splash_provider.dart';
    case StateManagement.bloc:
      return 'lib/features/splash/presentation/bloc/splash_bloc.dart';
    case StateManagement.provider:
      return 'lib/features/splash/presentation/notifiers/splash_notifier.dart';
  }
}

String _patchCustomSplash(String source, StateManagement stateManagement) {
  var updated = source;
  updated = _ensureImport(updated, 'package:flutter/material.dart');
  updated = _ensureImport(
    updated,
    splashFirebaseImport(stateManagement),
  );

  const plainDelay = 'await Future.delayed(Duration(seconds: 3));';
  const blocDelay = 'await Future.delayed(const Duration(seconds: 3));';
  if (updated.contains(plainDelay)) {
    return updated.replaceFirst(plainDelay, _firebaseInitBody);
  }
  if (updated.contains(blocDelay)) {
    return updated.replaceFirst(blocDelay, _firebaseInitBody);
  }

  if (stateManagement == StateManagement.riverpod) {
    const marker = 'Future<void> _start() async {';
    final markerIndex = updated.indexOf(marker);
    if (markerIndex == -1) {
      throw SetupException(
        'Splash was customized and has no _start() method. '
        'Call FirebaseService.init() during splash, then run setup again.',
      );
    }
    final insertAt = markerIndex + marker.length;
    return updated.replaceRange(
      insertAt,
      insertAt,
      '\n${_indentedInit('    ')}',
    );
  }

  final anchor = switch (stateManagement) {
    StateManagement.getx => 'Get.offAllNamed',
    StateManagement.bloc => 'emit(state.copyWith(isFinished: true))',
    StateManagement.provider => '_isFinished = true',
    StateManagement.riverpod => 'emit(state.copyWith(isFinished: true))',
  };
  final anchorIndex = updated.indexOf(anchor);
  if (anchorIndex == -1) {
    throw SetupException(
      'Splash was customized and has no Firebase startup hook. '
      'Add FirebaseService.init() before navigation, then run setup again.',
    );
  }

  final lineStart = updated.lastIndexOf('\n', anchorIndex) + 1;
  final indent = _leadingWhitespace(updated.substring(lineStart, anchorIndex));
  final block = _indentedInit(indent.isEmpty ? '    ' : indent);
  return updated.replaceRange(anchorIndex, anchorIndex, '$block\n$indent');
}

const String _firebaseInitBody = '''final stopwatch = Stopwatch()..start();
    try {
      await FirebaseService.init(
        onToken: (token) {
          debugPrint('FCM TOKEN: \$token');
        },
      );
    } catch (e) {
      debugPrint('Error during Firebase initialization: \$e');
    }
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 3000) {
      await Future.delayed(Duration(milliseconds: 3000 - elapsed));
    }''';

String _indentedInit(String indent) {
  final lines = _firebaseInitBody.split('\n');
  return lines
      .map((line) {
        if (line.trim().isEmpty) {
          return '';
        }
        final trimmed = line.trimLeft();
        final extra = line.length - trimmed.length;
        final base = extra >= 4 ? extra - 4 : 0;
        return '$indent${' ' * base}$trimmed';
      })
      .join('\n');
}

String _ensureImport(String source, String uri) {
  final line = "import '$uri';";
  if (source.contains(line)) {
    return source;
  }
  final firstImport = RegExp(
    r"^import '[^']+';\n",
    multiLine: true,
  ).firstMatch(source);
  if (firstImport == null) {
    return '$line\n$source';
  }
  return source.replaceRange(firstImport.end, firstImport.end, '$line\n');
}

String _leadingWhitespace(String value) {
  final match = RegExp(r'^[ \t]*').firstMatch(value);
  return match?.group(0) ?? '';
}

String _normalize(String value) => value.replaceAll('\r\n', '\n').trimRight();
