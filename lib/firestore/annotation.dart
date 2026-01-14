import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:path/path.dart' as p;

class _DocumentClass {
  final String _name;
  SimpleIdentifier? _type;
  final Map<String, _DocumentClass> _subCollections =
      <String, _DocumentClass>{};

  _DocumentClass(this._name);

  void _setType(SimpleIdentifier type) {
    _type = type;
  }

  void addSubCollection(_DocumentClass doc) {
    _subCollections[doc._name] = doc;
  }

  _DocumentClass? getSubCollection(String name) {
    return _subCollections[name];
  }

  void generateClassCode(StringBuffer buffer, String outputPath) {
    if (_type == null) {
      buffer.writeln("class $_name extends \$FirestoreDb {");
    } else {
      buffer.writeln(
        "class \$${_name}Doc extends \$Document<${_type.toString()}> {",
      );
      buffer.writeln("  \$${_name}Doc(super.id, super.collection);");
    }

    buffer.writeln();

    for (var sub in _subCollections.entries) {
      buffer.writeln("  // ignore: non_constant_identifier_names");
      buffer.write(
        "  late final ${sub.key} = \$Collection<\$${sub.key}Doc, ${sub.value._type}>('${sub.key}', \$${sub.key}Doc.new, ",
      );
      buffer.write(_type == null ? "this, null" : "null, this");
      buffer.writeln(");");

      buffer.writeln();
    }
    buffer.writeln("}");
  }
}

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
    final Map<String, _DocumentClass> docClass = <String, _DocumentClass>{};

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

    final path = p.dirname(buildStep.inputId.path);

    var className = "${element.name?.replaceFirst("Schema", "")}Store";
    className = className[0].toUpperCase() + className.substring(1);

    // Start recursive processing of the initializer
    docClass[className] = _DocumentClass(className);
    _parseExpression(astNode.initializer!, docClass, className);

    for (var doc in docClass.entries) {
      doc.value.generateClassCode(buffer, path);
      buffer.writeln();
    }
    return buffer.toString();
  }

  void _parseExpression(
    Expression expr,
    Map<String, _DocumentClass> docClass,
    String className,
  ) {
    // Handle the Top-Level Map and subCollections Map
    if (expr is SetOrMapLiteral && expr.isMap) {
      var doc = docClass[className]!;
      for (var element in expr.elements) {
        if (element is MapLiteralEntry) {
          final key = element.key
              .toString()
              .replaceAll("'", "")
              .replaceAll('"', "");
          var subCol = docClass[key];
          if (subCol == null) {
            subCol = _DocumentClass(key);
            docClass[key] = subCol;
          }

          doc.addSubCollection(subCol);
          _parseExpression(element.value, docClass, key);
        } else {
          throw Exception("Invalid Schema.");
        }
      }
    }
    // Handle the Records: (type: UserProfile, subCollections: {...})
    else if (expr is RecordLiteral) {
      for (var field in expr.fields) {
        var doc = docClass[className]!;
        if (field is NamedExpression) {
          final name = field.name.label.name;
          final value = field.expression;

          if (name == 'type') {
            doc._setType(value as SimpleIdentifier);
          } else if (name == 'subCollections') {
            _parseExpression(value, docClass, className);
          } else {
            throw Exception("Invalid Schema.");
          }
        } else {
          throw Exception("Invalid Schema.");
        }
      }
    } else {
      throw Exception("Invalid Schema.");
    }
  }
}
