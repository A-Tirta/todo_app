import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final stats = provider.getCategoryStats();

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // All Tasks Filter
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('All (${provider.pendingTasks.length})'),
                  selected: provider.selectedCategory == null,
                  onSelected: (selected) {
                    provider.setSelectedCategory(null);
                  },
                ),
              ),

              // Category Filters
              ...TaskCategory.values.map((category) {
                final count = stats[category] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      category.icon,
                      size: 16,
                      color: provider.selectedCategory == category
                          ? Colors.white
                          : category.color,
                    ),
                    label: Text('${category.displayName} ($count)'),
                    selected: provider.selectedCategory == category,
                    selectedColor: category.color,
                    onSelected: (selected) {
                      provider.setSelectedCategory(
                        selected ? category : null,
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}