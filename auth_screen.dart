// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../utils/theme_config.dart';
import 'calendar_screen.dart';

// Simula a transição entre Login e Cadastro
enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.login;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  // Simula a ação de Login/Cadastro
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // Simulando um delay de autenticação
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      // Navega para a tela principal (Calendário) após login/cadastro bem-sucedido
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: CustomContainer(
            color: AppTheme.backgroundColor,
            padding: 30.0,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _authMode == AuthMode.login ? 'Bem-Vindo de Volta!' : 'Crie sua Conta!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email, color: AppTheme.accentColor),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'E-mail inválido!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock, color: AppTheme.accentColor),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator(color: AppTheme.accentColor)
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(mediaQuery.width * 0.5, 50),
                            backgroundColor: AppTheme.accentColor,
                          ),
                          child: Text(
                            _authMode == AuthMode.login ? 'ENTRAR' : 'CADASTRAR',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      _authMode == AuthMode.login
                          ? 'Não tem conta? Cadastre-se'
                          : 'Já tem conta? Fazer Login',
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
