// lib/models/task_model.dart

/// Define o modelo de dados para uma tarefa.
class Task {
  final String id;
  String title;
  bool isCompleted;
  final DateTime date; // Data à qual a tarefa pertence

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.date,
  });

  // Método para criar uma cópia da tarefa com alterações
  Task copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: this.date,
    );
  }
}
