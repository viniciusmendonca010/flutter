// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Necessário para pt_BR
import 'package:intl/date_symbol_data_local.dart'; // Necessário para inicializar pt_BR
import 'screens/auth_screen.dart';
import 'screens/calendar_screen.dart'; // Contém o MockProvider
import 'providers/task_provider.dart';
import 'utils/theme_config.dart';

// --- INÍCIO DO CÓDIGO DO APLICATIVO ---

void main() {
  // Inicializa o suporte a datas em português
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(const TaskManagerApp());
  });
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Para simular o Provider, o TaskProvider é gerenciado
    // globalmente na classe MockProvider, mas para o template
    // final de submissão, mantemos a estrutura de um app
    // real que usaria o ChangeNotiferProvider.

    // A tela inicial é a de Autenticação.
    return MaterialApp(
      title: 'Task Manager Criativo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Configurações de Localização para Português (pt_BR)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Suporte para Português do Brasil
      ],
      // Força o Locale para Português
      locale: const Locale('pt', 'BR'),
      home: const AuthScreen(),
      routes: {
        // Rotas definidas, embora a navegação possa ser feita diretamente via MaterialPageRoute
        '/calendar': (ctx) => const CalendarScreen(),
      },
    );
  }
}