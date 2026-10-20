import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.25)),
    ),
    child: Column(
      children: [
        Icon(icon, size: 38, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
