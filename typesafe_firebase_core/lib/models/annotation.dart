import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta_meta.dart';

/// An annotation used to mark a class for automated [BaseModel] registration
/// and JSON serialization.
///
/// Classes annotated with [@Model] will have serialization logic generated
/// and will be included in the aggregate `registerAllModels()` function.
@Target({TargetKind.classType})
class Model extends JsonSerializable {
  const Model() : super(anyMap: true, explicitToJson: true);
}
