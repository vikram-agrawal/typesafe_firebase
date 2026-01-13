import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:typesafe_firebase/functions/annotation.dart';

Builder modelBuilder(BuilderOptions options) =>
    SharedPartBuilder([ModelGenerator()], 'model_builder');

Builder registrationBuilder(BuilderOptions options) =>
    RegistrationBuilder(options);
