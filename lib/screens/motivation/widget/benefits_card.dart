import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'reusable_list_template.dart';

class BenefitsCard extends StatelessWidget {
  final List<dynamic> items;
  final bool isDark;
  final VoidCallback onAdd;
  final Function(dynamic) onDelete;

  const BenefitsCard({
    super.key,
    required this.items,
    required this.isDark,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableListTemplate(
      title: "Benefits of Recovery",
      items: items,
      isDark: isDark,
      icon: PhosphorIcons.plant(),
      iconColor: const Color(0xFF10B981), // Green
      emptyText: "Add a benefit to remind yourself why...",
      hintText: "Add a benefit...",
      onAdd: onAdd,
      onDelete: onDelete,
    );
  }
}
