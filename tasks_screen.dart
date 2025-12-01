// lib/screens/tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Importação simulada do provider, necessário para o funcionamento da lógica
import '../providers/task_provider.dart';
import '../utils/theme_config.dart';
import '../models/task_model.dart';
import 'calendar_screen.dart'; // Reutiliza MockProvider

class TasksScreen extends StatelessWidget {
  final DateTime date;
  const TasksScreen({super.key, required this.date});

  // Mostra um diálogo customizado para adicionar uma nova tarefa
  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final provider = MockProvider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nova Tarefa', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Para o dia ${DateFormat('dd/MM/yyyy').format(date)}'),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome da Tarefa',
                hintText: 'Ex: Estudar Flutter',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('CANCELAR', style: TextStyle(color: AppTheme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.addTask(controller.text);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ADICIONAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Mostra um diálogo de confirmação para remover a tarefa
  void _showDeleteConfirmation(BuildContext context, Task task) {
    final provider = MockProvider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remover Tarefa', style: TextStyle(color: Colors.red)),
        content: Text('Tem certeza que deseja remover a tarefa "${task.title}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('NÃO', style: TextStyle(color: AppTheme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeTask(task.id);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('SIM', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Constrói um item da lista de tarefas com design criativo
  Widget _buildTaskItem(BuildContext context, Task task) {
    final provider = MockProvider.of<TaskProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      elevation: 3,
      color: task.isCompleted ? AppTheme.completedColor.withOpacity(0.1) : AppTheme.backgroundColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: GestureDetector(
          onTap: () => provider.toggleTaskCompletion(task.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: task.isCompleted ? AppTheme.completedColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? AppTheme.completedColor : AppTheme.pendingColor,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 20, color: Colors.white)
                : const Icon(Icons.circle_outlined, size: 20, color: AppTheme.pendingColor),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontStyle: task.isCompleted ? FontStyle.italic : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
          onPressed: () => _showDeleteConfirmation(context, task),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usando MockProvider.of com listen: true para reconstruir o widget quando o estado muda
    final taskProvider = MockProvider.of<TaskProvider>(context);
    final tasks = taskProvider.getTasksForSelectedDate();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas do Dia ${DateFormat('dd/MM/yyyy').format(date)}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              tasks.isEmpty ? 'Nenhuma tarefa para este dia.' : 'Lista de Tarefas:',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ),
          Expanded(
            child: CustomContainer(
              padding: 10,
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'Clique no "+" para adicionar sua primeira tarefa.',
                        style: TextStyle(fontSize: 16, color: AppTheme.textColor.withOpacity(0.6)),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (ctx, i) => _buildTaskItem(ctx, tasks[i]),
                    ),
            ),
          ),
          const SizedBox(height: 100), // Espaço para o FAB
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        label: const Text('Adicionar Tarefa'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.accentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
