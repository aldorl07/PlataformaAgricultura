import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF4A4A4A) : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Factory for a product card skeleton
  static Widget productCard({required BuildContext context}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: SkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 140, height: 16),
                SizedBox(height: 4),
                SkeletonLoader(width: 100, height: 12),
                SizedBox(height: 4),
                SkeletonLoader(width: 80, height: 20),
                SizedBox(height: 4),
                SkeletonLoader(width: 120, height: 14),
                SizedBox(height: 10),
                SkeletonLoader(
                    width: double.infinity,
                    height: 36,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Factory for a list item skeleton
  static Widget listItem() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          SkeletonLoader(
              width: 60,
              height: 60,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 16),
                SizedBox(height: 8),
                SkeletonLoader(width: 150, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Factory for a detailed KPI card skeleton
  static Widget kpiCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(width: 100, height: 14),
                SkeletonLoader(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
              ],
            ),
            SizedBox(height: 12),
            SkeletonLoader(width: 120, height: 28),
            SizedBox(height: 12),
            SkeletonLoader(width: 80, height: 12),
          ],
        ),
      ),
    );
  }
}
