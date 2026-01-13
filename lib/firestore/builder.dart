import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:typesafe_firebase/firestore/annotation.dart';

Builder schemaBuilder(BuilderOptions options) =>
    SharedPartBuilder([SchemaGenerator()], 'schema_builder');
