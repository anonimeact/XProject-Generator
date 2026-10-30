import '../../../core/configs/project_config.dart';

String stateManagementLabel(ProjectConfig config) {
  switch (config.stateManagement) {
    case StateManagement.getx:
      return 'GetX';
    case StateManagement.bloc:
      final arch = config.blocArchitecture == StateManagementArchitecture.clean
          ? 'Clean Code'
          : 'Simple';
      return 'Bloc ($arch)';
    case StateManagement.riverpod:
      final arch =
          config.riverpodArchitecture == StateManagementArchitecture.clean
          ? 'Clean Code'
          : 'Simple';
      return 'Riverpod ($arch)';
    case StateManagement.provider:
      return 'Provider';
  }
}
