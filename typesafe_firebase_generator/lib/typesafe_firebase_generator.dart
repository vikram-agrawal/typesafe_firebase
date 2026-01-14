import 'package:build/build.dart';
import 'package:json_serializable/json_serializable.dart';
import 'package:source_gen/source_gen.dart';
// import 'package:typesafe_firebase_generator/firestore/generator.dart';
import 'package:typesafe_firebase_generator/models/generator.dart';

Builder modelBuilder(BuilderOptions options) =>
    SharedPartBuilder([ModelGenerator(), JsonSerializableGenerator()], 'model_builder');

Builder registrationBuilder(BuilderOptions options) => RegistrationBuilder(options);

// Builder schemaBuilder(BuilderOptions options) => SharedPartBuilder([SchemaGenerator()], 'schema_builder');
