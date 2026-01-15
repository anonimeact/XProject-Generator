import 'package:xproject_generator/xfeature_generator.dart';
import 'package:xproject_generator/xproject_generator.dart';

/// Example usage of `xproject_generator` library.
///
/// This file demonstrates simple, programmatic access to the public generator
/// APIs. It's illustrative — some generator methods are interactive by default
/// and may prompt for input when called.

Future<void> main() async {
  // Create a new project (interactive prompts will appear)
  final projectGen = ProjectGenerator();
  await projectGen.create();

  // Add a feature to the current Flutter project programmatically
  final featureGen = FeatureGenerator();
  await featureGen.add('authentication');
}
