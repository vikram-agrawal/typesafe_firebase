import 'dart:collection';
import 'dart:core';

typedef ToJson<T> = Map<String, dynamic> Function(T);
typedef FromJson<T> = T Function(Map<String, dynamic>);
typedef Converter<T> = ({ToJson<T> toJson, FromJson<T> fromJson});

/// An abstract base class that provides a global registry for model serialization.
///
/// [BaseModel] allows for the registration and retrieval of [Converter]s, enabling
/// dynamic JSON serialization and deserialization of types that extend [BaseModel].
/// This is particularly useful for generic data handling and automated API mapping.
abstract class BaseModel {
  BaseModel();

  static final HashMap<Type, Converter<dynamic>> _converter =
      HashMap<Type, Converter<dynamic>>();

  /// Registers a [toJson] and [fromJson] function for a specific type [T].
  ///
  /// This must be called for every [BaseModel] subclass that needs to be
  /// serialized or deserialized dynamically via [getConverter].
  ///
  /// Example:
  /// ```dart
  /// BaseModel.register<User>(
  ///   toJson: (user) => user.toJson(),
  ///   fromJson: (json) => User.fromJson(json),
  /// );
  /// ```
  static void register<T extends BaseModel>({
    required ToJson<T> toJson,
    required FromJson<T> fromJson,
  }) {
    _converter[T] = (
      toJson: (dynamic item) => toJson(item as T),
      fromJson: (Map<String, dynamic> json) => fromJson(json),
    );
  }

  /// Retrieves the [Converter] associated with the type [T].
  ///
  /// This method looks up the serialization/deserialization logic previously
  /// stored via [register].
  ///
  /// Returns a [Converter] record containing `toJson` and `fromJson` functions
  /// specifically typed for [T].
  ///
  /// Throws an [Exception] if the type [T] has not been registered with [BaseModel].
  static Converter<T>? getConverter<T>() {
    final c = _converter[T];

    return c == null
        ? throw Exception("${T.toString()} is not registered with BaseModel.")
        : (
            toJson: (T item) => c.toJson(item),
            fromJson: (Map<String, dynamic> json) => c.fromJson(json) as T,
          );
  }
}
