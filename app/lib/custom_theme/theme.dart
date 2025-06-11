import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryRed = Color(0xFFE53935); // Colors.red[600]
  static const Color primaryRedLight = Color(0xFFEF5350); // Colors.red[400]
  static const Color primaryRedDark = Color(0xFFD32F2F); // Colors.red[700]

  // Background Colors
  static const Color backgroundColor = Color(0xFFFAFAFA); // Colors.grey[50]
  static const Color cardBackground = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5); // Colors.grey[100]

  // Text Colors
  static const Color primaryTextColor = Color(0xFF424242); // Colors.grey[800]
  static const Color secondaryTextColor = Color(0xFF757575); // Colors.grey[600]
  static const Color lightTextColor = Colors.white;

  // Accent Colors
  static const Color redAccent = Color(0xFFFFEBEE); // Colors.red[50]
  static const Color borderColor = Color(0xFFE0E0E0); // Colors.grey[300]

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, primaryRedLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primaryRed.withOpacity(0.3),
      spreadRadius: 2,
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  // Border Radius
  static const double cardRadius = 16.0;
  static const double buttonRadius = 16.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 20.0;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Padding
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
  static const EdgeInsets screenPadding = EdgeInsets.all(20.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets mediumPadding = EdgeInsets.all(16.0);

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: secondaryTextColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: secondaryTextColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: lightTextColor,
  );

  static const TextStyle whiteHeading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: lightTextColor,
  );

  static const TextStyle whiteSubheading = TextStyle(
    fontSize: 16,
    color: lightTextColor,
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryRed,
    foregroundColor: lightTextColor,
    elevation: 3,
    shadowColor: primaryRed.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  );

  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryRed,
    side: const BorderSide(color: primaryRed, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: primaryRed,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Input Decoration
  static InputDecoration getInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(smallRadius),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(smallRadius),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(smallRadius),
      borderSide: const BorderSide(color: primaryRed, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: cardShadow,
  );

  static BoxDecoration get primaryCardDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(largeRadius),
    boxShadow: primaryShadow,
  );

  // Dropdown Decoration
  static BoxDecoration get dropdownDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(smallRadius),
    border: Border.all(color: borderColor),
  );

  // App Bar Theme
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: primaryRed,
    foregroundColor: lightTextColor,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: lightTextColor,
    ),
  );

  // Complete Theme Data
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.red,
    primaryColor: primaryRed,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: appBarTheme,


    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: outlinedButtonStyle,
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: textButtonStyle,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallRadius),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallRadius),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallRadius),
        borderSide: const BorderSide(color: primaryRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: headingLarge,
      headlineMedium: headingMedium,
      headlineSmall: headingSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
    ),

    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryRed,
      brightness: Brightness.light,
      primary: primaryRed,
      secondary: primaryRedLight,
      surface: cardBackground,
      background: backgroundColor,
      error: Colors.red[800]!,
    ),
  );
}

// Extension for easy access to theme components
extension AppThemeExtension on BuildContext {
  AppTheme get theme => AppTheme();

  // Quick access methods
  Color get primaryColor => AppTheme.primaryRed;
  Color get backgroundColor => AppTheme.backgroundColor;
  Color get cardColor => AppTheme.cardBackground;

  TextStyle get headingLarge => AppTheme.headingLarge;
  TextStyle get headingMedium => AppTheme.headingMedium;
  TextStyle get bodyLarge => AppTheme.bodyLarge;
  TextStyle get bodyMedium => AppTheme.bodyMedium;

  EdgeInsets get screenPadding => AppTheme.screenPadding;
  EdgeInsets get cardPadding => AppTheme.cardPadding;

  double get cardRadius => AppTheme.cardRadius;
  double get largeSpacing => AppTheme.largeSpacing;
  double get mediumSpacing => AppTheme.mediumSpacing;
}