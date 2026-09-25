import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final Color baseColor;
  final Color borderColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;
  final Gradient? customGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 16.0,
    this.opacity = 0.15,
    this.borderOpacity = 0.25,
    this.baseColor = Colors.white,
    this.borderColor = Colors.white,
    this.onTap,
    this.shadows,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: baseColor.withValues(alpha: opacity.clamp(0.0, 1.0)),
              gradient: customGradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      baseColor.withValues(alpha: (opacity + 0.15).clamp(0.0, 1.0)),
                      baseColor.withValues(alpha: opacity.clamp(0.0, 1.0)),
                    ],
                  ),
              border: Border.all(
                color: borderColor.withValues(alpha: borderOpacity.clamp(0.0, 1.0)),
                width: 0.8, // Thinner border like the reference
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: content,
        ),
      );
    }

    return content;
  }
}
