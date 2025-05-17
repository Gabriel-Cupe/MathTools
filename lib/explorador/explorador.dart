import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'explorador_model.dart';

class Explorador extends StatefulWidget {
  const Explorador({super.key});

  @override
  State<Explorador> createState() => _ExploradorState();
}

class _ExploradorState extends State<Explorador> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  final List<ExploradorOption> _options = [
    ExploradorOption(
      title: 'Calculadora',
      icon: Iconsax.calculator,
      description: 'Realiza operaciones matemáticas avanzadas',
      routeName: '/calculadora',
      iconColor: Colors.blueAccent,
    ),
    ExploradorOption(
      title: 'Graficadora',
      icon: Iconsax.chart_2,
      description: 'Visualiza funciones en 2D y 3D',
      routeName: '/graficadora',
      iconColor: Colors.purpleAccent,
    ),
    ExploradorOption(
      title: 'Conversor',
      icon: Iconsax.convert,
      description: 'Convierte entre diferentes unidades',
      routeName: '/conversor',
      iconColor: Colors.tealAccent,
    ),
    ExploradorOption(
      title: 'Problema del Día',
      icon: Iconsax.lamp_on,
      description: 'Desafío matemático diario',
      routeName: '/problema',
      iconColor: Colors.redAccent,
    ),    
    ExploradorOption(
      title: 'Pronto màs herramientas :3',
      icon: Iconsax.math,
      description: 'Estate atento a nuevas herramientas',
      routeName: '/formulas',
      iconColor: Colors.orangeAccent,
    ),
  ];

  List<ExploradorOption> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = _options;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredOptions = _options.where((option) {
        return option.title.toLowerCase().contains(query) ||
               option.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateTo(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

return Scaffold(
  backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50], //93
  body: CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverAppBar(
        expandedHeight: 75.0,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            'MathTools',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.blue[900],
                ),
          ),
          centerTitle: true,
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
            ? [Colors.indigo[900]!, Colors.blueGrey[900]!]
            : [Colors.blue[100]!, Colors.lightBlue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildSearchField(context),
        ),
      ),
      // ESTA ES LA PARTE CRÍTICA QUE DEBES CAMBIAR:
      if (_filteredOptions.isEmpty)
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.search_normal_1,
                      size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron resultados',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: index == _filteredOptions.length - 1 ? 120.0 : 0, // Espacio solo al último
          left: 16,
          right: 16,
          top: 8,
        ),
        child: _buildAnimatedOptionItem(context, _filteredOptions[index], index),
      );
    },
            childCount: _filteredOptions.length,
          ),
        ),
    ],
  ),
);
  }

  Widget _buildSearchField(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Buscar herramienta...',
        hintStyle: GoogleFonts.poppins(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(Iconsax.search_normal_1,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        suffixIcon: _isSearching
            ? IconButton(
                icon: Icon(Iconsax.close_circle,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                onPressed: () {
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                },
              )
            : null,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      style: GoogleFonts.poppins(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildAnimatedOptionItem(
      BuildContext context, ExploradorOption option, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200 + (index * 100)),
        curve: Curves.easeOutQuad,
        transform: Matrix4.translationValues(
            0, _isSearching ? 0 : (index * 20.0), 0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).cardColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateTo(option.routeName),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: option.iconColor?.withOpacity(0.2) ??
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      option.icon,
                      size: 24,
                      color: option.iconColor ?? Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.description,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 20,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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