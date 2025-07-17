import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/tool_card.dart';
import 'tool_detail_page.dart';
import 'add_tool_page.dart';

class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        maxLines: 1,
        title: 'Ensiklopedia Alat',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddToolPage()),
              );
            },
            tooltip: 'Tambah Alat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari alat teknik...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<AppProvider>().clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    context.read<AppProvider>().searchTools(value);
                    setState(() {});
                  },
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                // Category filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ['Semua', ...AppConstants.toolCategories].length,
                    itemBuilder: (context, index) {
                      final categories = [
                        'Semua',
                        ...AppConstants.toolCategories,
                      ];
                      final category = categories[index];
                      final isSelected = _selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(
                          right: AppConstants.paddingSmall,
                        ),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: AppConstants.primaryColor.withOpacity(
                            0.2,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppConstants.primaryColor
                                : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tools list
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, provider, child) {
                var tools = provider.filteredTools;

                // Filter by category
                if (_selectedCategory != 'Semua') {
                  tools = tools
                      .where((tool) => tool.category == _selectedCategory)
                      .toList();
                }

                if (tools.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          provider.searchQuery.isNotEmpty
                              ? 'Tidak ada alat yang ditemukan'
                              : 'Belum ada alat tersedia',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (provider.searchQuery.isNotEmpty) ...[
                          const SizedBox(height: AppConstants.paddingSmall),
                          const Text(
                            'Coba kata kunci lain',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.paddingMedium,
                      ),
                      child: ToolCard(
                        tool: tool,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ToolDetailPage(toolId: tool.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
