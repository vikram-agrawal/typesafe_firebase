import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

class FirestoreService {
  const FirestoreService();
}

class SchemaGenerator extends GeneratorForAnnotation<FirestoreService> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! TopLevelVariableElement) return '';

    // Get the AST node for the variable declaration
    final astNode = await buildStep.resolver.astNodeFor(
      element.firstFragment,
      resolve: true,
    );
    if (astNode is! VariableDeclaration || astNode.initializer == null) {
      return '';
    }

    final buffer = StringBuffer();
    buffer.writeln('class ${element.name?.replaceFirst("Schema", "")}Store {');

    // Start recursive processing of the initializer
    _parseExpression(astNode.initializer!, buffer, indent: '  ');

    buffer.writeln('}');
    return buffer.toString();
  }

  void _parseExpression(
    Expression expr,
    StringBuffer buffer, {
    String indent = '',
  }) {
    // Handle the Top-Level Map and subCollections Map
    if (expr is SetOrMapLiteral && expr.isMap) {
      for (var element in expr.elements) {
        if (element is MapLiteralEntry) {
          final key = element.key
              .toString()
              .replaceAll("'", "")
              .replaceAll('"', "");
          buffer.writeln(
            '${indent}final $key = \$Collection<\$${key}Doc>(\$${key}Doc.new);',
          );
          _parseExpression(element.value, buffer, indent: '$indent  ');
        }
      }
    }
    // Handle the Records: (type: UserProfile, subCollections: {...})
    else if (expr is RecordLiteral) {
      for (var field in expr.fields) {
        if (field is NamedExpression) {
          final name = field.name.label.name;
          final value = field.expression;

          if (name == 'type') {
            buffer.writeln('// ${indent}Type: ${value.toString()}');
          } else if (name == 'subCollections') {
            buffer.writeln('// ${indent}SubCollections:');
            _parseExpression(value, buffer, indent: '$indent  ');
          }
        }
      }
    }
  }
}
