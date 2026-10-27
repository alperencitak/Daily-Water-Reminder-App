import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

class NavItem {
  const NavItem(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Floating pill navigation bar. Tabs have equal width; a single gradient
/// capsule glides behind the selected one.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  static const _height = 66.0;
  static const _pad = 6.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: _height,
      padding: const EdgeInsets.all(_pad),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(_height / 2),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final slot = box.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                left: slot * index,
                top: 0,
                bottom: 0,
                width: slot,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: c.accentGradient,
                    borderRadius: BorderRadius.circular(
                      (_height - _pad * 2) / 2,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: items[i],
                        selected: i == index,
                        onTap: () {
                          if (i == index) return;
                          HapticFeedback.selectionClick();
                          onChanged(i);
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? Colors.white : c.muted;
    return Pressable(
      onTap: onTap,
      scale: 0.92,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: selected ? 1.12 : 1,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            child: Icon(
              selected ? item.activeIcon : item.icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: nunito(12, selected ? 900 : 700, color: color),
            child: Text(item.label, maxLines: 1, overflow: TextOverflow.fade),
          ),
        ],
      ),
    );
  }
}
