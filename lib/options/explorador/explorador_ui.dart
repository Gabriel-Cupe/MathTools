import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'explorador_model.dart';

class ExploradorUI extends StatelessWidget {
  final TextEditingController searchController;
  final List<ExploradorOption> options;
  final Function(String) onOptionTap;
  final bool isSearching;

  const ExploradorUI({
    super.key,
    required this.searchController,
    required this.options,
    required this.onOptionTap,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Math Tools',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.blueGrey[800]!, Colors.grey[900]!]
                        : [Colors.blue[100]!, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: _buildSearchField(context),
            ),
          ),
          options.isEmpty
              ? SliverFillRemaining(
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
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildOptionItem(context, options[index], index);
                    },
                    childCount: options.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Hero(
      tag: 'search-field',
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Buscar herramienta...',
            hintStyle: GoogleFonts.poppins(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            prefixIcon: Icon(Iconsax.search_normal_1,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            suffixIcon: isSearching
                ? IconButton(
                    icon: Icon(Iconsax.close_circle,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    onPressed: () {
                      searchController.clear();
                      FocusScope.of(context).unfocus();
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
        ),
      ),
    );
  }

  Widget _buildOptionItem(
      BuildContext context, ExploradorOption option, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200 + (index * 50)),
        opacity: 1.0,
        child: AnimatedPadding(
          duration: Duration(milliseconds: 200 + (index * 50)),
          padding: EdgeInsets.only(top: isSearching ? 0 : (index * 5.0)),
          child: Card(
            elevation: isSearching ? 1 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Theme.of(context).cardColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onOptionTap(option.routeName),
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
      ),
    );
  }
}