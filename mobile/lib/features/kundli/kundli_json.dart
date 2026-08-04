/// Shared defensive JSON-parsing helpers for every Vedika response model in
/// this feature — `kundli_data.dart` (kundli), `kundli_dosha_data.dart`
/// (all-doshas) and `kundli_dasha_data.dart` (vimshottari-dasha) all parse
/// the same kind of deeply-nested, contractually-unguaranteed JSON, so one
/// shared implementation lives here instead of three copies quietly
/// drifting apart. See `kundli_data.dart`'s class doc for the underlying
/// policy: **every field is treated as nullable and parsed defensively** —
/// a missing or wrongly-typed value anywhere in the tree degrades to
/// `null`/an empty list rather than throwing, so one bad nested field never
/// takes down an entire parsed response.
library;

/// Parses a nested JSON object with [fromJson], or `null` if [value] isn't
/// a `Map` or [fromJson] itself throws on it.
T? parseObj<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! Map<String, dynamic>) return null;
  try {
    return fromJson(value);
  } catch (_) {
    return null;
  }
}

/// Parses a JSON array of nested objects with [fromJson]. A single
/// malformed entry is skipped rather than losing the whole list.
List<T> parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (value is! List) return const [];
  final result = <T>[];
  for (final entry in value) {
    if (entry is Map<String, dynamic>) {
      try {
        result.add(fromJson(entry));
      } catch (_) {
        // Skip just this one malformed entry, keep the rest of the list.
      }
    }
  }
  return result;
}

/// Parses a JSON array of strings, dropping any non-string entries.
List<String> parseStrings(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final entry in value)
      if (entry is String) entry,
  ];
}

int? parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
