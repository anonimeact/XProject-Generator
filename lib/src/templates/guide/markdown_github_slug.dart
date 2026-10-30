// Heading slug rules aligned with VS Code Markdown preview (GitHub slugger).

String markdownPreviewHeadingSlug(String value) {
  if (value.isEmpty) return '';
  var s = value.trim().toLowerCase();
  s = s.replaceAll('`', '');
  // Strip unicode dashes before slugging (legacy documents may still contain them).
  s = s.replaceAll(RegExp(r'[\u2010-\u2015\u2212]'), '');
  // Drop punctuation; keep letters, digits, underscore, spaces.
  s = s.replaceAll(RegExp(r'[^\w\s]'), '');
  s = s.replaceAll(' ', '-');
  return s;
}

class MarkdownPreviewSlugBuilder {
  final _occurrences = <String, int>{};

  String add(String headingText) {
    final originalSlug = markdownPreviewHeadingSlug(headingText);
    var result = originalSlug;

    while (_occurrences.containsKey(result)) {
      _occurrences[originalSlug] = (_occurrences[originalSlug] ?? 0) + 1;
      result = '$originalSlug-${_occurrences[originalSlug]}';
    }

    _occurrences[result] = 0;
    if (!_occurrences.containsKey(originalSlug)) {
      _occurrences[originalSlug] = 0;
    }
    return result;
  }
}
