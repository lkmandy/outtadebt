import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outtadebt/core/ui/constants/border_radius.dart';
import 'package:outtadebt/core/ui/constants/breakpoints.dart';
import 'package:outtadebt/core/ui/constants/durations.dart';
import 'package:outtadebt/core/ui/constants/kit_colors.dart';
import 'package:outtadebt/core/ui/constants/shadows.dart';
import 'package:outtadebt/core/ui/constants/spacing.dart';
import 'package:outtadebt/core/ui/constants/text_styles.dart';

class AppTheme {
  static ThemeData buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textStyles = CustomTextStyles();
    final borderRadius = CustomBorderRadius();
    final breakpoints = CustomBreakpoints();
    final shadows = CustomShadows();
    final kitColors = KitColorsExtension();

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        // Slate 50 as page bg; cards stay white via surface
        surface: isDark ? kitColors.neutral900 : Colors.white,
        // Navy 950 as the primary / button colour
        primary: isDark ? kitColors.neutral50 : KitColors.navy950,
        onPrimary: Colors.white,
        secondary: isDark ? kitColors.neutral50 : KitColors.navy950,
        onSecondary: Colors.white,
        error: Colors.red.shade400,
        onError: kitColors.neutral50,
        onSurface: isDark ? kitColors.neutral50 : kitColors.neutral950,
        surfaceTint: isDark ? kitColors.neutral900 : Colors.white,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      // Slate 50 page background so cards (white surface) pop off it
      scaffoldBackgroundColor: isDark ? kitColors.neutral900 : KitColors.slate50,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? kitColors.neutral50 : kitColors.neutral950,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? kitColors.neutral800 : kitColors.neutral200,
      ),
      textTheme: TextTheme(
        bodyLarge: textStyles.lg.copyWith(
          color: isDark ? kitColors.neutral50 : kitColors.neutral950,
        ),
        bodyMedium: textStyles.standard.copyWith(
          color: isDark ? kitColors.neutral50 : kitColors.neutral950,
        ),
        titleMedium: textStyles.standard.copyWith(
          color: isDark ? kitColors.neutral50 : kitColors.neutral950,
        ),
        headlineLarge: textStyles.xxl.copyWith(
          color: kitColors.neutral950,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: IconThemeData(
        color: isDark ? kitColors.neutral50 : kitColors.neutral950,
      ),
      extensions: [textStyles, borderRadius, breakpoints, shadows, kitColors],
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.white.withValues(alpha: .1),
      // Inputs: Slate 100 fill, 12 px radius (rounded-xl in design)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? kitColors.neutral800 : KitColors.slate100,
        hintStyle: TextStyle(color: isDark ? kitColors.neutral500 : kitColors.neutral400),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? kitColors.neutral700 : kitColors.neutral200),
          borderRadius: borderRadius.xxl, // 12 px
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: isDark ? kitColors.neutral700 : kitColors.neutral200),
          borderRadius: borderRadius.xxl, // 12 px
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kitColors.green600, width: 2),
          borderRadius: borderRadius.xxl, // 12 px
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: CustomSpacing.instance.md,
          vertical: CustomSpacing.instance.md,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          color: isDark ? kitColors.neutral50 : kitColors.neutral950,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            isDark ? kitColors.neutral900 : Colors.white,
          ),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? kitColors.neutral900 : Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? kitColors.neutral800 : kitColors.neutral200,
            ),
            borderRadius: borderRadius.xxl,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? kitColors.neutral800 : kitColors.neutral200,
            ),
            borderRadius: borderRadius.xxl,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? kitColors.neutral800 : kitColors.neutral200,
            ),
            borderRadius: borderRadius.xxl,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: CustomSpacing.instance.md,
            vertical: CustomSpacing.instance.sm,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? kitColors.neutral900 : Colors.white,
        textStyle: TextStyle(
          color: isDark ? kitColors.neutral50 : kitColors.neutral950,
        ),
      ),
      // FilledButton: Navy 950, 16 px radius (rounded-2xl)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KitColors.navy950,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kitColors.neutral300,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius.xxxl, // 16 px
          ),
        ),
      ),
      // ElevatedButton: Navy 950, 16 px radius
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KitColors.navy950,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kitColors.neutral300,
          shape: RoundedRectangleBorder(borderRadius: borderRadius.xxxl),
          elevation: 0,
        ),
      ),
      // OutlinedButton: Slate border, 12 px radius (secondary style)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? kitColors.neutral50 : kitColors.neutral950,
          shape: RoundedRectangleBorder(borderRadius: borderRadius.xxl),
          side: BorderSide(
            color: isDark ? kitColors.neutral700 : kitColors.neutral200,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KitColors.navy950,
          shape: RoundedRectangleBorder(borderRadius: borderRadius.xxl),
        ),
      ),
    );
  }
}

extension ThemeDataX on BuildContext {
  ThemeData get theme => Theme.of(this);

  CustomTextStyles get textStyles =>
      Theme.of(this).extension<CustomTextStyles>()!;

  KitColorsExtension get kitColors =>
      Theme.of(this).extension<KitColorsExtension>()!;

  CustomBorderRadius get borderRadius =>
      Theme.of(this).extension<CustomBorderRadius>()!;

  CustomBreakpoints get breakpoints =>
      Theme.of(this).extension<CustomBreakpoints>()!;

  CustomDurations get durations => CustomDurations.instance;

  CustomSpacing get spacing => CustomSpacing.instance;

  CustomShadows get shadows => Theme.of(this).extension<CustomShadows>()!;
}
