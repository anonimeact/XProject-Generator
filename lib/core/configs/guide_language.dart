/// Language for generated [GUIDE.md] (not app UI l10n).
enum GuideLanguage {
  en('English'),
  id('Indonesia');

  const GuideLanguage(this.label);

  final String label;

  static const List<GuideLanguage> supported = [en, id];

  static GuideLanguage fromCode(String? code) {
    if (code == null || code.isEmpty) return GuideLanguage.en;
    for (final lang in supported) {
      if (lang.name == code) return lang;
    }
    return GuideLanguage.en;
  }
}
