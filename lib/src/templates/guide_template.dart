import '../../core/configs/guide_language.dart';
import '../../core/configs/project_config.dart';
import 'guide/guide_beginner_sections.dart';

/// Generates English-only [GUIDE.md] for a scaffolded Flutter project.
class GuideTemplate {
  static String content(ProjectConfig config) {
    final localized = config.copyWith(guideLanguage: GuideLanguage.en);

    var section = 0;
    String heading(String title) {
      section++;
      return '## $section. $title';
    }

    final buffer = StringBuffer();

    buffer.writeln('# Setup guide: ${config.displayName}');
    buffer.writeln();
    buffer.writeln(
      'This project was created with **XProject Generator**. '
      'This document is a **step-by-step** guide to finish configuration and run the app.',
    );
    buffer.writeln();

    GuideBeginnerSections.tableOfContents(buffer, localized);
    GuideBeginnerSections.partOneHeader(buffer, localized);
    GuideBeginnerSections.prerequisites(buffer, localized, heading);
    GuideBeginnerSections.projectSummary(buffer, localized, heading);
    GuideBeginnerSections.folderTour(buffer, localized, heading);
    GuideBeginnerSections.partTwoHeader(buffer, localized);
    GuideBeginnerSections.configurationChecklists(buffer, localized);
    GuideBeginnerSections.troubleshooting(buffer, localized);
    GuideBeginnerSections.learnMore(buffer, localized);
    GuideBeginnerSections.glossary(buffer, localized);

    return buffer.toString();
  }
}
