import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      icon: Icons.auto_awesome,
      title: '¡Bienvenido a Mistborn Dominance!',
      description: 'Tu compañero digital para gestionar el Dominance Track en Mistborn: Deckbuilding Game.',
    ),
    OnboardingStep(
      icon: Icons.trending_up,
      title: 'Gestiona el Dominance Track',
      description: 'Presiona "Dominance Up" para avanzar en el track y activar eventos automáticamente.',
    ),
    OnboardingStep(
      icon: Icons.warning_amber,
      title: 'Eventos Dinámicos',
      description: 'Los eventos se generan automáticamente basados en tu posición y las configuraciones activas.',
    ),
    OnboardingStep(
      icon: Icons.settings,
      title: 'Configuraciones Personalizables',
      description: 'Importa y exporta archivos de configuración para personalizar completamente los eventos del juego.',
    ),
    OnboardingStep(
      icon: Icons.play_arrow,
      title: '¡Comencemos!',
      description: 'Todo está listo. ¡Que disfrutes tu partida de Mistborn: Deckbuilding Game!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de progreso
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(
                  _steps.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? const Color(0xFFFFB300)
                            : const Color(0xFF616161),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Contenido
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícono
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB71C1C).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFB300),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            step.icon,
                            size: 60,
                            color: const Color(0xFFFFB300),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Título
                        Text(
                          step.title,
                          style: const TextStyle(
                            color: Color(0xFFFFB300),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Descripción
                        Text(
                          step.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Botones de navegación
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Skip/Anterior
                  TextButton(
                    onPressed: _currentPage == 0
                        ? _finishOnboarding
                        : () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    child: Text(
                      _currentPage == 0 ? 'Omitir' : 'Anterior',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Botón Siguiente/Comenzar
                  ElevatedButton(
                    onPressed: _currentPage == _steps.length - 1
                        ? _finishOnboarding
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                      _currentPage == _steps.length - 1 ? 'Comenzar' : 'Siguiente',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep {
  final IconData icon;
  final String title;
  final String description;

  OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}