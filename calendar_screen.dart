// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Importação simulada do provider, necessário para o funcionamento da lógica
import 'package:flutter/scheduler.dart';
import '../providers/task_provider.dart';
import '../utils/theme_config.dart';
import 'tasks_screen.dart';

// Mock de Provider para uso no Canvas
class MockProvider {
  static T of<T extends ChangeNotifier>(BuildContext context, {bool listen = true}) {
    // Retorna uma instância mockada, no Flutter real seria obtida via Provider.of
    if (T == TaskProvider) {
      // Cria e mantém uma única instância do TaskProvider para a simulação
      if (!_instances.containsKey(T)) {
        _instances[T] = TaskProvider() as dynamic;
      }
      return _instances[T] as T;
    }
    throw Exception('MockProvider não suporta o tipo $T');
  }
  static final Map<Type, dynamic> _instances = {};
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    // Inicializa o provider com a data atual
    SchedulerBinding.instance.addPostFrameCallback((_) {
      MockProvider.of<TaskProvider>(context, listen: false)
          .setSelectedDate(DateTime.now());
    });
  }

  // Navega para a tela de tarefas para o dia selecionado
  void _goToTasksScreen(BuildContext context, DateTime selectedDate) {
    // Atualiza o provider com a data selecionada antes de navegar
    MockProvider.of<TaskProvider>(context, listen: false)
        .setSelectedDate(selectedDate);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TasksScreen(date: selectedDate),
      ),
    );
  }

  // Widget simples para simular o calendário
  Widget _buildSimpleCalendar(BuildContext context) {
    // Usando as bibliotecas nativas de data (DateFormat)
    final now = DateTime.now();
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final daysInMonth = endOfMonth.day;
    final firstWeekday = startOfMonth.weekday % 7; // 0=Dom, 6=Sáb

    final List<String> weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final int totalCells = daysInMonth + firstWeekday;
    final int rows = (totalCells / 7).ceil();

    List<Widget> calendarDays = [];

    // Células vazias antes do dia 1
    for (int i = 0; i < firstWeekday; i++) {
      calendarDays.add(const SizedBox());
    }

    // Células dos dias do mês
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(_focusedDay.year, _focusedDay.month, i);
      final isSelected = _selectedDay != null &&
          day.year == _selectedDay!.year &&
          day.month == _selectedDay!.month &&
          day.day == _selectedDay!.day;
      final isToday = day.year == now.year && day.month == now.month && day.day == now.day;

      calendarDays.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentColor : (isToday ? AppTheme.accentColor.withOpacity(0.3) : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$i',
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Cabeçalho (Mês e Ano)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy', 'pt_BR').format(_focusedDay),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                  });
                },
              ),
            ],
          ),
        ),
        // Dias da Semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) => Expanded(
            child: Center(
              child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        // Grade dos Dias
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: rows * 7,
          itemBuilder: (context, index) {
            if (index < firstWeekday || index >= totalCells) {
              return const SizedBox();
            }
            return calendarDays[index];
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Configura o locale para português para formatação de data
    Intl.defaultLocale = 'pt_BR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Calendário de Tarefas'),
        automaticallyImplyLeading: false, // Remove a seta de voltar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Selecione um dia para visualizar ou adicionar tarefas:',
                style: TextStyle(fontSize: 18, color: AppTheme.textColor, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            CustomContainer(
              child: _buildSimpleCalendar(context),
            ),
            const SizedBox(height: 30),
            if (_selectedDay != null)
              CustomContainer(
                color: AppTheme.accentColor.withOpacity(0.9),
                child: Column(
                  children: [
                    Text(
                      'Dia Selecionado:',
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                    ),
                    Text(
                      DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(_selectedDay!),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _goToTasksScreen(context, _selectedDay!),
                      icon: const Icon(Icons.list_alt, color: AppTheme.accentColor),
                      label: const Text('SELECIONAR O DIA', style: TextStyle(color: AppTheme.accentColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
