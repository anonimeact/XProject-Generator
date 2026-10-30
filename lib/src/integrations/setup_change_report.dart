/// Result of applying one setup integration to an existing project.
///
/// [written] lists files or steps that changed. [skipped] lists targets that
/// were left alone because they already existed (real Firebase config files,
/// a customized service, and so on). [notes] are follow-up instructions that
/// the CLI prints after the file changes.
class SetupChangeReport {
  SetupChangeReport({
    List<String>? written,
    List<String>? skipped,
    List<String>? notes,
    this.guideUpdatedFor,
  }) : written = written ?? <String>[],
       skipped = skipped ?? <String>[],
       notes = notes ?? <String>[];

  final List<String> written;
  final List<String> skipped;
  final List<String> notes;

  /// When set, [GuideRefresher] rewrote `GUIDE.md` for this integration label.
  String? guideUpdatedFor;

  bool get changed => written.isNotEmpty;
}

/// User-facing failure for `xproject setup`.
///
/// [toString] is the message only, so the CLI can print `Error: ...` without
/// a redundant exception type name.
class SetupException implements Exception {
  SetupException(this.message);

  final String message;

  @override
  String toString() => message;
}
