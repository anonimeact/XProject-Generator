import '../../../core/configs/guide_language.dart';
import '../../../core/configs/project_config.dart';

/// Picks guide prose for [config.guideLanguage] (English or Indonesian).
String guideText(
  ProjectConfig config, {
  required String en,
  required String id,
}) {
  switch (config.guideLanguage) {
    case GuideLanguage.id:
      return id;
    default:
      return en;
  }
}

String guideYesNo(ProjectConfig config, bool value) {
  if (value) {
    return guideText(config, en: 'Yes', id: 'Ya');
  }
  return guideText(config, en: 'No', id: 'Tidak');
}
