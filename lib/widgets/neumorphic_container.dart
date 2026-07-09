// widgets/neumorphic_container.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/theme.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 50.w,
      height: height ?? 50.w,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: borderRadius ?? BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(-3, -3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
