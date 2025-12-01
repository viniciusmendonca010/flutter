// lib/providers/task_provider.dart

import 'package:flutter/material.dart';
import '../models/task_model.dart';

// Este é um mock para o pacote 'provider', que é uma convenção moderna do Flutter
// O código abaixo simula o comportamento de um ChangeNotifier, essencial para o Provider.
class TaskProvider with ChangeNotifier {
  // Mapa que armazena as tarefas por data: { DateTime: List<Task> }
  final Map<DateTime, List<Task>> _tasks = {};
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  // Retorna a lista de tarefas para a data selecionada, com a ordenação exigida.
  List<Task> getTasksForSelectedDate() {
    // Normaliza a data para apenas ano, mês e dia para a chave do mapa
    final normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    // Retorna uma lista vazia se não houver tarefas para a data
    final tasks = _tasks[normalizedDate] ?? [];

    // Implementa a ordenação requerida:
    // 1. Pendentes primeiro (isCompleted = false)
    // 2. Concluídas em segundo (isCompleted = true)
    // 3. Dentro de cada grupo, em ordem alfabética (case insensitive)
    tasks.sort((a, b) {
      // 1. Comparação de status: Pendente (false) vem antes de Concluída (true)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1; // Se a for true (concluída) e b for false (pendente), b vem primeiro (-1)
      }

      // 2. Se o status for o mesmo, ordena alfabeticamente
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return tasks;
  }

  /// Adiciona uma nova tarefa à lista da data selecionada.
  void addTask(String title) {
    if (title.trim().isEmpty) return;

    final normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      date: normalizedDate,
      isCompleted: false, // Por padrão, não concluída
    );

    _tasks.putIfAbsent(normalizedDate, () => []);
    _tasks[normalizedDate]!.add(newTask);

    notifyListeners();
  }

  /// Remove uma tarefa.
  void removeTask(String taskId) {
    final normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    _tasks[normalizedDate]?.removeWhere((task) => task.id == taskId);

    notifyListeners();
  }

  /// Alterna o status de conclusão de uma tarefa.
  void toggleTaskCompletion(String taskId) {
    final normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final taskIndex = _tasks[normalizedDate]?.indexWhere((task) => task.id == taskId);

    if (taskIndex != null && taskIndex != -1) {
      final task = _tasks[normalizedDate]![taskIndex];
      // Cria uma nova instância com o status invertido
      _tasks[normalizedDate]![taskIndex] = task.copyWith(
        isCompleted: !task.isCompleted,
      );
      notifyListeners();
    }
  }

  /// Define a data atualmente selecionada.
  void setSelectedDate(DateTime date) {
    // Normaliza a data para garantir que a comparação seja apenas por dia.
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }
}
