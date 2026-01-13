import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta_meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as p;

@Target({TargetKind.classType})
class Model extends JsonSerializable {
  const Model() : super(anyMap: true, explicitToJson: true);
}

class ModelGenerator extends GeneratorForAnnotation<Model> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final name = element.name;
    // Get the import path relative to the lib/ folder
    final path = buildStep.inputId.path.startsWith('lib/')
        ? buildStep.inputId.uri.toString()
        : buildStep.inputId.path;

    return """
//IMPORT: $path
//==BaseModel.register<$name>(
//==  toJson: ${name}ToJson,
//==  fromJson: ${name}FromJson,
//==);

// ignore: constant_identifier_names
const ${name}FromJson = _\$${name}FromJson;

// ignore: constant_identifier_names
const ${name}ToJson = _\$${name}ToJson;
""";
  }
}

class RegistrationBuilder implements Builder {
  final String inputPattern;
  final String outputPath;

  RegistrationBuilder(BuilderOptions options)
    : inputPattern =
          options.config['input_pattern'] ?? 'lib/**/*.model_builder.g.part',
      outputPath =
          options.config['output_path'] ?? 'lib/generated/models.g.dart';

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
        if (line.startsWith('//IMPORT: ')) {
          var path = line.replaceFirst('//IMPORT: ', '');

          // If it's a raw file path (outside lib), make it relative to the output file
          if (!path.startsWith('package:')) {
            // Calculate relative path from output directory to the model file
            final outDir = p.dirname(outputPath);
            path = p.relative(path, from: outDir);
          }
          imports.add(path);
        } else if (line.startsWith('//==')) {
          registrations.add(line.trim().substring(4));
        }
      }
    }

    // Write file header
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY');
    buffer.writeln(
      'import "package:typesafe_firebase/typesafe_firebase.dart";',
    );

    // Write all model imports
    for (final path in imports) {
      buffer.writeln('import "$path";');
    }

    buffer.writeln('\nvoid registerAllModels() {');
    for (final reg in registrations) {
      buffer.writeln('  $reg');
    }
    buffer.writeln('}');

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, outputPath),
      buffer.toString(),
    );
  }
}

// class UserProfileExtension {
//   // ignore: unused_field
//   static final _converter = () {
//     BaseModel.register<UserProfile>(
//       toJson: _$UserProfileToJson,
//       fromJson: _$UserProfileFromJson,
//     );
//   }();
// }
