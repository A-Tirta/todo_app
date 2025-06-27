import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TaskCategory {
  work('Work', Icons.work, Color(0xFF2196F3)),
  personal('Personal', Icons.person, Color(0xFF4CAF50)),
  shopping('Shopping', Icons.shopping_cart, Color(0xFFFF9800)),
  health('Health', Icons.fitness_center, Color(0xFFE91E63)),
  education('Education', Icons.school, Color(0xFF9C27B0)),
  other('Other', Icons.category, Color(0xFF607D8B));

  const TaskCategory(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

enum TaskPriority {
  low('Low', Color(0xFF4CAF50)),
  medium('Medium', Color(0xFFFF9800)),
  high('High', Color(0xFFFF5722));

  const TaskPriority(this.displayName, this.color);
  final String displayName;
  final Color color;
}

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  TaskCategory category;
  TaskPriority priority;
  DateTime createdAt;
  DateTime? dueDate;
  DateTime? completedAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.category = TaskCategory.other,
    this.priority = TaskPriority.medium,
    DateTime? createdAt,
    this.dueDate,
    this.completedAt,
  }) : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category.name,
      'priority': priority.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] == 1,
      category: TaskCategory.values.firstWhere(
            (cat) => cat.name == map['category'],
        orElse: () => TaskCategory.other,
      ),
      priority: TaskPriority.values.firstWhere(
            (pri) => pri.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
    );
  }

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && now.month == due.month && now.day == due.day;
  }
}