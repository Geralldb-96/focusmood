part of '../../main.dart';

extension _SystemScreenContent on _MoodPageState {
  List<Widget> buildSystemScreen() {
    return [
      heading('Sistema Mood', sub: 'Base visual compacta · v1.0'),
      title('PALETA SERENA'),
      Row(
        children:
            [
                  moodGreen,
                  const Color(0xfff6ac69),
                  const Color(0xff9080b0),
                  const Color(0xff4c8198),
                  const Color(0xff2b805f),
                  const Color(0xffba5054),
                ]
                .map(
                  (color) => Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
      box(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text('Bienestar que acompaña', size: 24, bold: true),
            gap(8),
            small('Jerarquía limpia · lectura móvil accesible.'),
          ],
        ),
        color: 'soft',
      ),
      button('Acción principal', () => go('home'), icon: Icons.arrow_forward),
      button(
        dark ? 'Modo claro' : 'Modo oscuro',
        s.toggleTheme,
        secondary: true,
      ),
    ];
  }
}
