import '../../core/configs/project_config.dart';
import 'guide_writer.dart';

/// Rewrites guide markdown files from the current [ProjectConfig].
///
/// Setup does this only after it actually changes the project, so a second
/// run that finds everything already in place does not wipe manual edits.
abstract final class GuideRefresher {
  static Future<void> refresh(ProjectConfig config) async {
    await GuideWriter.writeAll(config);
  }
}
