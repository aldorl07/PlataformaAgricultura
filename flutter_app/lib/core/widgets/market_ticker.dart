import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MarketTickerItem {
  final String cropName;
  final double wholesalePrice;
  final double platformPrice;
  final double savingPercent;

  const MarketTickerItem({
    required this.cropName,
    required this.wholesalePrice,
    required this.platformPrice,
    required this.savingPercent,
  });
}

class MarketTicker extends StatefulWidget {
  final List<MarketTickerItem> items;

  const MarketTicker({
    super.key,
    required this.items,
  });

  @override
  State<MarketTicker> createState() => _MarketTickerState();
}

class _MarketTickerState extends State<MarketTicker> {
  late final ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!mounted || widget.items.isEmpty) return;
    
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted || !_scrollController.hasClients) return;
      
      final maxExtent = _scrollController.position.maxScrollExtent;
      final currentPosition = _scrollController.offset;
      
      if (currentPosition >= maxExtent) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(currentPosition + 0.5);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (widget.items.isEmpty) return const SizedBox();

    // Duplicate list items to create a seamless infinite scrolling effect
    final displayItems = [...widget.items, ...widget.items, ...widget.items];

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E281F) : const Color(0xFFE8F5E9),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : AppColors.primaryDark.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: displayItems.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = displayItems[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Row(
              children: [
                const Icon(
                  Icons.eco_outlined,
                  size: 14,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 8),
                Text(
                  item.cropName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.neutralDark,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'MIDAGRI: S/. ${item.wholesalePrice.toStringAsFixed(2)}/kg',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.swap_horiz,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Chupaca Directo: S/. ${item.platformPrice.toStringAsFixed(2)}/kg',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_downward,
                        size: 10,
                        color: Colors.white,
                      ),
                      Text(
                        '${item.savingPercent.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
