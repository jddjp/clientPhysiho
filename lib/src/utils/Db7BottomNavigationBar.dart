import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum Db7BottomNavigationBarType {
  fixed,
  shifting,
}

class Db7BottomNavigationBar extends StatelessWidget {
  const Db7BottomNavigationBar({
    super.key,
    required this.items,
    required this.onTap,
    this.currentIndex = 0,
    this.elevation = 8.0,
    this.type = Db7BottomNavigationBarType.fixed,
    this.backgroundColor,
    this.iconSize = 24.0,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedIconTheme = const IconThemeData(),
    this.unselectedIconTheme = const IconThemeData(),
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
  }) : assert(items.length >= 2),
       assert(0 <= currentIndex && currentIndex < items.length),
       assert(iconSize >= 0.0),
       assert(selectedFontSize >= 0.0),
       assert(unselectedFontSize >= 0.0);

  final List<Db7BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;
  final int currentIndex;
  final double elevation;
  final Db7BottomNavigationBarType type;
  final Color? backgroundColor;
  final double iconSize;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final IconThemeData selectedIconTheme;
  final IconThemeData unselectedIconTheme;
  final double selectedFontSize;
  final double unselectedFontSize;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = selectedItemColor ?? theme.primaryColor;
    final unselectedColor = unselectedItemColor ??
        theme.textTheme.bodySmall?.color ?? Colors.grey;
    final barColor = backgroundColor ?? Colors.white;

    return Material(
      elevation: elevation,
      color: barColor,
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;
          final effectiveColor = isSelected ? selectedColor : unselectedColor;
          final iconToUse = isSelected && item.activeIcon.isNotEmpty
              ? item.activeIcon
              : item.icon;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      iconToUse,
                      width: iconSize,
                      height: iconSize,
                      color: effectiveColor,
                    ),
                    if ((isSelected && showSelectedLabels) ||
                        (!isSelected && showUnselectedLabels))
                      DefaultTextStyle(
                        style: (isSelected ? selectedLabelStyle : unselectedLabelStyle) ??
                            TextStyle(
                              color: effectiveColor,
                              fontSize: isSelected ? selectedFontSize : unselectedFontSize,
                            ),
                        child: item.title,
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Db7BottomNavigationBarItem {
  const Db7BottomNavigationBarItem({
    required this.icon,
    required this.title,
    this.activeIcon = '',
    this.backgroundColor = Colors.transparent,
  });

  final String icon;
  final Widget title;
  final String activeIcon;
  final Color backgroundColor;
}