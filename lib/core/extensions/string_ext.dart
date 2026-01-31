extension StringExt on String {
  /// Mengonversi string ke PascalCase
  /// Contoh: "hello world" -> "HelloWorld"
  String toPascalCase() {
    if (isEmpty) return '';
    return split(RegExp(r'[-_\s]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');
  }

  /// Mengonversi string ke camelCase
  /// Contoh: "hello world" -> "helloWorld"
  String toCamelCase() {
    final pascal = toPascalCase();
    if (pascal.isEmpty) return '';
    return pascal[0].toLowerCase() + pascal.substring(1);
  }
}
