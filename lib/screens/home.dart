import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathtools/challenge/daily_challenge_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Paleta de colores Math Tools
    final Color primaryColor = const Color(0xFF0924AA);
    final Color secondaryColor = const Color(0xFF0380FB);
    final Color skyBlue = const Color(0xFFA8EFFA);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);
    final Color cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final Color sectionBackground = isDarkMode 
        ? const Color(0xFF0F172A) 
        : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: sectionBackground,
      body: CustomScrollView(
        slivers: [
SliverAppBar(
  automaticallyImplyLeading: false,
  floating: true,
  snap: true,
  expandedHeight: 250.0,
  stretch: true,
  elevation: 0,
  backgroundColor: Colors.transparent,
  flexibleSpace: FlexibleSpaceBar(
    collapseMode: CollapseMode.pin,
    stretchModes: const [StretchMode.zoomBackground],
    background: isDesktop
        ? _buildDesktopHeader(primaryColor, secondaryColor, skyBlue)
        : _buildMobileHeader(primaryColor, secondaryColor, skyBlue),
  ),
),
  
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40.0 : 16.0,
              vertical: 24.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isDesktop)
                  _buildDesktopLayout(
                    isDesktop,
                    context,
                    primaryColor,
                    secondaryColor,
                    textColor,
                    cardColor,
                  )
                else
                  _buildMobileLayout(                    isDesktop,
                    context,
                    primaryColor,
                    secondaryColor,
                    textColor,
                    cardColor), 
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
         bool isDesktop,  BuildContext context, Color primaryColor, Color secondaryColor, Color textColor, Color cardColor) {
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de herramientas principales
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Herramientas Principales',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 3 : 2,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildToolCard(
                      context: context,
                      icon: FontAwesomeIcons.calculator,
                      title: 'Calculadora',
                      color: primaryColor,
                      route: '/calculadora',
                      description: 'Calculadora científica avanzada',
                    ),
                    _buildToolCard(
                      context: context,
                      icon: FontAwesomeIcons.chartLine,
                      title: 'Gráficas',
                      color: secondaryColor,
                      route: '/graficadora',
                      description: 'Visualiza funciones en 2D/3D',
                    ),
                    _buildToolCard(
                      context: context,
                      icon: FontAwesomeIcons.squareRootVariable,
                      title: 'Ejercicios',
                      color: const Color(0xFF9C27B0),
                      route: '/ejercicios',
                      description: 'Biblioteca de ejercicios para mejorar tus matemáticas',
                    ),
                    _buildToolCard(
                      context: context,
                      icon: FontAwesomeIcons.ruler,
                      title: 'Conversor',
                      color: const Color(0xFF4CAF50),
                      route: '/conversor',
                      description: 'Conversión de unidades',
                    ),
                    if (isDesktop)
                      _buildToolCard(
                        context: context,
                        icon: FontAwesomeIcons.book,
                        title: 'Teoría',
                        color: const Color(0xFFFF9800),
                        route: '/theory',
                        description: 'Conceptos teóricos',
                      ),
                    if (isDesktop)
                      _buildToolCard(
                        context: context,
                        icon: FontAwesomeIcons.flask,
                        title: 'Formularios',
                        color: const Color(0xFF00BCD4),
                        route: '/formulas',
                        description: 'Menos teoría, más acción',
                      ),
                  ],
                ),


                ]
                ,
              ),
            ),
            const SizedBox(width: 24),
            // Sección del reto diario
            Expanded(
              flex: 1,
              child: DailyChallengeContainer()
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Sección de cursos
        Text(
          'Explorar por Materias',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildDesktopCourseSection(context, cardColor, textColor),
      ],
    );
  }

Widget _buildDesktopHeader(Color primaryColor, Color secondaryColor, Color skyBlue) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withOpacity(0.95),
          secondaryColor.withOpacity(0.95),
        ],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: -50,
          bottom: -50,
          child: Opacity(
            opacity: 0.05,
            child: SvgPicture.asset(
              'assets/icon.svg',
              width: 250,
              height: 250,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 56.0, 40.0, 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: skyBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: skyBlue.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/icon.svg',
                      width: 50,
                      height: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Math Tools',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Desde álgebra hasta cálculo: MathTools te ofrece teoría detallada, práctica guiada, herramientas de conversión, graficadora y retos diarios para que aprendas de verdad.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildMobileHeader(Color primaryColor, Color secondaryColor, Color skyBlue) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor.withOpacity(0.95),
          secondaryColor.withOpacity(0.95),
        ],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: -50,
          bottom: -50,
          child: Opacity(
            opacity: 0.05,
            child: SvgPicture.asset(
              'assets/icon.svg',
              width: 250,
              height: 250,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 56.0, 24.0, 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: skyBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: skyBlue.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/icon.svg',
                      width: 50,
                      height: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Math Tools',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Desde álgebra hasta cálculo: MathTools te ofrece teoría detallada, práctica guiada, herramientas de conversión, graficadora y retos diarios para que aprendas de verdad.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _buildMobileLayout(
  bool isDesktop, 
  BuildContext context, 
  Color primaryColor, 
  Color secondaryColor, 
  Color textColor, 
  Color cardColor
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Sección de herramientas principales
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Herramientas Principales',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5, // Ajustado para mejor proporción en móvil
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildMobileToolCard(
              context: context,
              icon: FontAwesomeIcons.calculator,
              title: 'Calculadora',
              color: primaryColor,
              route: '/calculadora',
              description: 'Calculadora científica',
            ),
            _buildMobileToolCard(
              context: context,
              icon: FontAwesomeIcons.chartLine,
              title: 'Gráficas',
              color: secondaryColor,
              route: '/graficadora',
              description: 'Visualiza funciones',
            ),
            _buildMobileToolCard(
              context: context,
              icon: FontAwesomeIcons.squareRootVariable,
              title: 'Ejercicios',
              color: const Color(0xFF9C27B0),
                      route: '/ejercicios',
                      description: 'Biblioteca de ejercicios',
            ),
            _buildMobileToolCard(
              context: context,
              icon: FontAwesomeIcons.ruler,
              title: 'Conversor',
              color: const Color(0xFF4CAF50),
              route: '/conversor',
              description: 'Conversión de unidades',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      // Sección del reto diario
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DailyChallengeContainer()

      ),
      const SizedBox(height: 24),
      // Sección de cursos
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Explorar por Materias',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildMobileCourseSection(context, cardColor, textColor),
      ),
    ],
  );
}

Widget _buildMobileToolCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required Color color,
  required String route,
  required String description,
}) {
  return Card(
    elevation: 0,
    margin: EdgeInsets.zero, // Elimina márgenes por defecto
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12), // Reducido para móvil
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8), // Reducido para móvil
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    icon,
                    size: 16, // Reducido para móvil
                    color: color,
                  ),
                ),
                const SizedBox(width: 8), // Reducido para móvil
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14, // Reducido para móvil
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6), // Reducido para móvil
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 11, // Reducido para móvil
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4), // Reducido para móvil
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward,
                size: 14, // Reducido para móvil
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  Widget _buildToolCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required String route,
    required String description,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      icon,
                      size: 18,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  Widget _buildDesktopCourseSection(
      BuildContext context, Color cardColor, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: _buildCourseCard(
            context,
            'Matemáticas',
            ['Álgebra', 'Cálculo', 'Geometría', 'Estadística'],
            FontAwesomeIcons.squareRootVariable,
            cardColor,
            textColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCourseCard(
            context,
            'Física',
            ['Cinemática', 'Dinámica', 'Termodinámica', 'Electromagnetismo'],
            FontAwesomeIcons.atom,
            cardColor,
            textColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCourseCard(
            context,
            'Programación',
            ['Algoritmos', 'Estructuras', 'Flutter', 'Python'],
            FontAwesomeIcons.code,
            cardColor,
            textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCourseSection(
      BuildContext context, Color cardColor, Color textColor) {
    return Column(
      children: [
        _buildCourseCard(
          context,
          'Matemáticas',
          ['Álgebra', 'Cálculo', 'Geometría', 'Estadística'],
          FontAwesomeIcons.squareRootVariable,
          cardColor,
          textColor,
        ),
        const SizedBox(height: 16),
        _buildCourseCard(
          context,
          'Física',
          ['Cinemática', 'Dinámica', 'Termodinámica', 'Electromagnetismo'],
          FontAwesomeIcons.atom,
          cardColor,
          textColor,
        ),
        const SizedBox(height: 16),
        _buildCourseCard(
          context,
          'Programación',
          ['Algoritmos', 'Estructuras', 'Flutter', 'Python'],
          FontAwesomeIcons.code,
          cardColor,
          textColor,
        ),
      ],
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    String title,
    List<String> topics,
    IconData icon,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0924AA).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    icon,
                    size: 18,
                    color: const Color(0xFF0924AA),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...topics.map((topic) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                minLeadingWidth: 0,
                leading: Icon(
                  Icons.circle,
                  size: 6,
                  color: textColor.withOpacity(0.4),
                ),
                title: Text(
                  topic,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: textColor.withOpacity(0.4),
                ),
                onTap: () {},
              )),
        ],
      ),
    );
  }
