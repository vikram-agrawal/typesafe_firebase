import 'dart:collection';
import 'dart:core';

typedef ToJson<T> = Map<String, dynamic> Function(T);
typedef FromJson<T> = T Function(Map<String, dynamic>);
typedef Converter<T> = ({ToJson<T> toJson, FromJson<T> fromJson});

abstract class BaseModel {
  BaseModel();

  static final HashMap<Type, Converter<dynamic>> _converter =
      HashMap<Type, Converter<dynamic>>();

  static void register<T extends BaseModel>({
    required ToJson<T> toJson,
    required FromJson<T> fromJson,
  }) {
    _converter[T] = (
      toJson: (dynamic item) => toJson(item as T),
      fromJson: (Map<String, dynamic> json) => fromJson(json),
    );
  }

  static Converter<T>? getConverter<T>() {
    final c = _converter[T];

    // Cast back to the specific Converter<T> type
    return c == null
        ? null
        : (
            toJson: (T item) => c.toJson(item),
            fromJson: (Map<String, dynamic> json) => c.fromJson(json) as T,
          );
  }
}
