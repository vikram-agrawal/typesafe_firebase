import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:typesafe_firebase_core/annotations.dart';

/// A generator that produces registration snippets and serialization aliases
/// for classes annotated with [Model].
///
/// This generator produces `.g.part` files containing metadata that the
/// [RegistrationBuilder] later collects to build the final registration file.
class ModelGenerator extends GeneratorForAnnotation<Model> {
  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final name = element.name;
    // Get the import path relative to the lib/ folder
    final path = buildStep.inputId.path.startsWith('lib/') ? buildStep.inputId.uri.toString() : buildStep.inputId.path;

    return """
// IMPORT: $path

// ignore: non_constant_identifier_names
void \$register_\$${name}_type() {
  BaseModel.register<$name>(
    toJson: _\$${name}ToJson,
    fromJson: _\$${name}FromJson,
  );
}
""";
  }
}

/// A builder that aggregates all generated model snippets into a single
/// registration file.
///
/// It scans for files matching [inputPattern], extracts import paths and
/// registration statements, and generates a unified `registerAllModels()`
/// function at [outputPath].
class RegistrationBuilder implements Builder {
  final String inputPattern;
  final String outputPath;

  RegistrationBuilder(BuilderOptions options)
    : inputPattern = options.config['input_pattern'] ?? 'lib/**.model_builder.g.part',
      outputPath = options.config['output_path'] ?? 'lib/models.g.dart';

  @override
  late final buildExtensions = {
    r'$package$': [outputPath],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final buffer = StringBuffer();
    final imports = <String>{};
    final registrations = <String>[];

    final parts = buildStep.findAssets(Glob(inputPattern));

    await for (final asset in parts) {
      final content = await buildStep.readAsString(asset);
      final lines = content.split('\n');

      for (final line in lines) {
        if (line.startsWith('// IMPORT: ')) {
          var path = line.replaceFirst('// IMPORT: ', '');

          // If it's a raw file path (outside lib), make it relative to the output file
          if (!path.startsWith('package:')) {
            // Calculate relative path from output directory to the model file
            final outDir = p.dirname(outputPath);
            path = p.relative(path, from: outDir);
          }
          imports.add(path);
        } else if (line.startsWith('void \$register_\$')) {
          registrations.add(line.trim().substring(5).replaceAll(" {", ";"));
        }
      }
    }

    // Write file header
    buffer.writeln('// ****************************************');
    buffer.writeln('// *    GENERATED CODE - DO NOT MODIFY    *');
    buffer.writeln('// ****************************************');
    buffer.writeln();
    buffer.writeln('import "package:typesafe_firebase_core/models.dart";');

    // Write all model imports
    for (final path in imports) {
      buffer.writeln('import "$path";');
    }

    buffer.writeln('\nvoid registerAllModels() {');
    buffer.writeln("  registerCommonModels();");
    buffer.writeln();
    for (final reg in registrations) {
      buffer.writeln('  $reg');
    }
    buffer.writeln('}');

    await buildStep.writeAsString(AssetId(buildStep.inputId.package, outputPath), buffer.toString());
  }
}
