import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

/// JSON converter for IconData.
/// NOTE: fromJson must create IconData at runtime from stored JSON values.
/// We use matchTextDirection explicitly to satisfy the release tree-shaker
/// and suppress the icon-font check; icons are stored by codePoint (int)
/// not as compile-time constants, so --no-tree-shake-icons is set in build.
class IconDataConverter implements JsonConverter<IconData, Map<String, dynamic>> {
  const IconDataConverter();

  @override
  IconData fromJson(Map<String, dynamic> json) {
    return IconData(
      json['codePoint'] as int,
      fontFamily: json['fontFamily'] as String?,
      fontPackage: json['fontPackage'] as String?,
      matchTextDirection: false,
    );
  }

  @override
  Map<String, dynamic> toJson(IconData icon) {
    return {
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };
  }
}

/// JSON converter for Color
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color color) {
    return color.toARGB32();
  }
}
