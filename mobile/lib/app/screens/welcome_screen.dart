part of '../../main.dart';

extension _WelcomeScreenContent on _MoodPageState {
  List<Widget> buildWelcomeScreen() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          brand(),
          IconButton(
            onPressed: s.toggleTheme,
            icon: Icon(
              dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: dark ? 'Modo claro' : 'Modo oscuro',
          ),
        ],
      ),
      gap(22),
      SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 30,
              bottom: 20,
              child: Container(
                width: 135,
                height: 145,
                decoration: BoxDecoration(
                  color: tone('peach'),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: tone('lavender'),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 245,
                height: 175,
                decoration: BoxDecoration(
                  color: tone('mint'),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              left: 25,
              bottom: 20,
              child: CircleAvatar(
                backgroundColor: surface,
                child: const Icon(
                  Icons.favorite_border,
                  color: Color(0xffba5054),
                  size: 21,
                ),
              ),
            ),
            Positioned(
              right: 28,
              top: 18,
              child: CircleAvatar(
                backgroundColor: surface,
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: Color(0xffc88948),
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
      gap(14),
      Text(
        'Tu bienestar\nacadémico, a tu ritmo',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      gap(10),
      text(
        'Registra cómo te sientes, mejora tus hábitos y recibe recomendaciones útiles para estudiar con equilibrio.',
        align: TextAlign.center,
        color: muted,
      ),
      gap(12),
      note(
        'Mood no sustituye orientación médica o psicológica profesional.',
        icon: Icons.shield_outlined,
      ),
      button('Comenzar', () => go('signup'), icon: Icons.arrow_forward),
      link('¿Ya tienes cuenta?  Inicia sesión', () => go('login')),
    ];
  }
}
