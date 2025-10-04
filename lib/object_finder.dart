/// A typedef for a function that converts a dynamic value into a specific type [T].
/// Returns `null` if the conversion is not possible.
typedef ObjectBuilder<T> = T? Function(dynamic value);

/// Extension on [Object?] providing safe type checks, conversions, and nested object access.
///
/// This extension allows you to:
/// - Verify the validity of an object (`isValid`, `verified`).
/// - Check its type (`isMap`, `isList`, `isListOfMap`).
/// - Safely compare equality with another object (`equals`).
/// - Convert dynamic values to a specific type, including `List` of primitives (`_v`, `_vs`).
/// - Safely access nested map data with default values (`find`, `findOrNull`, `finds`, `findsOrNull`, `get`, `getOrNull`).
///
/// Supports optional custom conversion via [ObjectBuilder].
extension ObjectFinder on Object? {
  /// Returns `this` if the object is valid (non-null), otherwise returns `null`.
  Object? get verified => isValid ? this : null;

  /// Returns `true` if the object is non-null.
  bool get isValid => this != null;

  /// Returns `true` if the object is null.
  bool get isNotValid => !isValid;

  /// Returns `true` if the object is a `Map`.
  bool get isMap => this is Map;

  /// Returns `true` if the object is an `Iterable` of `Map`s.
  bool get isListOfMap {
    Object? x = this;
    if (x is! Iterable) return false;
    return x.every((e) => e is Map);
  }

  /// Returns `true` if the object is a `List`.
  bool get isList => this is List;

  /// Checks equality of `this` with [compare], including type.
  bool equals(dynamic compare) {
    return this != null &&
        this == compare &&
        runtimeType == compare.runtimeType;
  }

  /// Converts [source] to type [T], using optional [builder] for custom conversion.
  ///
  /// Supports `int`, `double`, `String`, `bool`, `num`, and lists of these types.
  T? _v<T extends Object?>(dynamic source, [ObjectBuilder<T>? builder]) {
    if (source == null) return null;
    if (builder != null) return builder(source);
    if (source is T) return source;
    if (source is num) {
      if (T == int) return source.toInt() as T;
      if (T == double) return source.toDouble() as T;
      if (T == String) return source.toString() as T;
    }
    if (source is String) {
      if (T == num || T == int || T == double) {
        final number = num.tryParse(source);
        if (number != null) {
          if (T == int) return number.toInt() as T;
          if (T == double) return number.toDouble() as T;
          return number as T;
        }
      }
      if (T == bool) {
        final boolean = bool.tryParse(source);
        if (boolean != null) return boolean as T;
      }
    }
    if (source is Iterable) {
      final type = T
          .toString()
          .replaceAll("List<", "")
          .replaceAll("Iterable<", '')
          .replaceAll(">", '');
      if (type == "String") {
        final data = source
            .map((e) {
              if (e == null) return null;
              return "$e";
            })
            .whereType<String>()
            .toList();
        return data.isEmpty ? null : data as T;
      }
      if (type == "int") {
        final data = source
            .map((e) {
              if (e is num) return e.toInt();
              if (e is String) return num.tryParse(e)?.toInt();
              return null;
            })
            .whereType<int>()
            .toList();
        return data.isEmpty ? null : data as T;
      }
      if (type == "double") {
        final data = source
            .map((e) {
              if (e is num) return e.toDouble();
              if (e is String) return num.tryParse(e)?.toDouble();
              return null;
            })
            .whereType<double>()
            .toList();
        return data.isEmpty ? null : data as T;
      }
      if (type == "num") {
        final data = source
            .map((e) {
              if (e is num) return e;
              if (e is String) return num.tryParse(e);
              return null;
            })
            .whereType<num>()
            .toList();
        return data.isEmpty ? null : data as T;
      }
      if (type == "bool") {
        final data = source
            .map((e) {
              if (e is bool) return e;
              if (e is String) return bool.tryParse(e);
              return null;
            })
            .whereType<bool>()
            .toList();

        return data.isEmpty ? null : data as T;
      }
      if (type.startsWith("Map<dynamic, dynamic")) {
        final data = source
            .map((e) {
              if (e is Map) return e;
              return null;
            })
            .whereType<Map>()
            .toList();
        if (data.isNotEmpty) return data as T;
        return null;
      }
      if (type.startsWith("Map<String, dynamic")) {
        final data = source
            .map((e) {
              if (e is Map) return e.map((k, v) => MapEntry(k.toString(), v));
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList();
        if (data.isNotEmpty) return data as T;
        return null;
      }
    }
    return null;
  }

  /// Converts an iterable [source] to `Iterable<T>` using optional [builder].
  Iterable<T>? _vs<T>(dynamic source, [ObjectBuilder<T>? builder]) {
    if (source == null || source is! Iterable) return null;
    return source.map((e) => _v(e, builder)).whereType<T>();
  }

  /// Finds a value of type [T] associated with [key], throws if not found.
  T find<T extends Object?>({
    Object? key,
    T? defaultValue,
    ObjectBuilder<T>? builder,
  }) {
    final T? arguments = findOrNull(
      key: key,
      defaultValue: defaultValue,
      builder: builder,
    );
    if (arguments != null) return arguments;
    throw UnimplementedError("$T didn't find from this object");
  }

  /// Finds a value by map key [key], throws if not found.
  T findByKey<T extends Object?>(
    String key, {
    T? defaultValue,
    ObjectBuilder<T>? builder,
  }) {
    return find(key: key, defaultValue: defaultValue, builder: builder);
  }

  /// Finds a value of type [T] associated with [key], returns `null` if not found.
  T? findOrNull<T extends Object?>({
    Object? key,
    T? defaultValue,
    ObjectBuilder<T>? builder,
  }) {
    final root = this;
    final value = key == null
        ? root
        : root is Map
            ? root[key]
            : null;

    return _v(value, builder) ?? defaultValue;
  }

  /// Finds a list of type [T] associated with [key], throws if not found.
  List<T> finds<T extends Object?>({
    Object? key,
    List<T> defaultValue = const [],
    ObjectBuilder<T>? builder,
  }) {
    final List<T>? arguments = findsOrNull(
      key: key,
      defaultValue: defaultValue,
      builder: builder,
    );
    if (arguments != null) return arguments;
    throw UnimplementedError("List<$T> didn't find from this object");
  }

  /// Finds a list of type [T] by map key [key], throws if not found.
  List<T> findsByKey<T extends Object?>(
    String key, {
    List<T> defaultValue = const [],
    ObjectBuilder<T>? builder,
  }) {
    return finds(key: key, defaultValue: defaultValue, builder: builder);
  }

  /// Finds a list of type [T] associated with [key], returns `null` if not found.
  List<T>? findsOrNull<T extends Object?>({
    Object? key,
    List<T>? defaultValue,
    ObjectBuilder<T>? builder,
  }) {
    final root = this;
    final data = key == null
        ? root
        : root is Map
            ? root[key]
            : null;
    final iterable = _vs(data, builder);
    if (iterable == null) return defaultValue;
    return List.from(iterable);
  }

  /// Gets a value of type [T] associated with [key], throws if not found.
  T get<T extends Object?>([
    Object? key,
    T? defaultValue,
    ObjectBuilder<T>? builder,
  ]) {
    final T? arguments = getOrNull(key, defaultValue, builder);
    if (arguments != null) return arguments;
    throw UnimplementedError("$T didn't get from this object");
  }

  /// Gets a value of type [T] associated with [key], returns `null` if not found.
  T? getOrNull<T extends Object?>([
    Object? key,
    T? defaultValue,
    ObjectBuilder<T>? builder,
  ]) {
    return findOrNull(key: key, defaultValue: defaultValue, builder: builder);
  }
}
