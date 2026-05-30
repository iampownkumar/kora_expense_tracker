import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive dimension helper — call once per build, pass around as a value.
class AppDimensions {
  final double padding;       // default content padding
  final double paddingSmall;  // tight gaps
  final double paddingLarge;  // section gaps
  final double iconSize;      // standard icon size
  final double iconSizeSmall; // compact icon size
  final double cardRadius;
  final double fontScaleFactor;

  const AppDimensions._({
    required this.padding,
    required this.paddingSmall,
    required this.paddingLarge,
    required this.iconSize,
    required this.iconSizeSmall,
    required this.cardRadius,
    required this.fontScaleFactor,
  });

  /// Create dimensions scaled to the device's screen height.
  factory AppDimensions.of(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final scale = sh < 600 ? 0.65 : sh < 700 ? 0.80 : 1.0;
    return AppDimensions._(
      padding:       12.0 * scale,
      paddingSmall:   6.0 * scale,
      paddingLarge:  16.0 * scale,
      iconSize:      20.0 * scale,
      iconSizeSmall: 14.0 * scale,
      cardRadius:    12.0,
      fontScaleFactor: scale,
    );
  }
}

/// App-wide Material 3 theme configuration.
class AppTheme {
  static ThemeData light() => _buildTheme(Brightness.light);
  static ThemeData dark()  => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: brightness,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }
}
