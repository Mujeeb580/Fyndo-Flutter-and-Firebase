import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_screen.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../main.dart'; // Access themeNotifier
import 'add_product_screen.dart';
import 'settings_screen.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  String sortBy = "Newest";
  final TextEditingController _searchController = TextEditingController();

  final Stream<List<Product>> _productStream = DatabaseService().getProducts();

  // FIX 1: Defined _safeThemeToggle
  void _safeThemeToggle(bool isDark) {
    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  // FIX 2: Defined _confirmDelete
  void _confirmDelete(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Item?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to remove '$productName'?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await DatabaseService().deleteProduct(productId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAIAssistant(List<Product> currentItems) {
    final TextEditingController aiController = TextEditingController();
    String aiResponse = "Ask me to find the best deal or a specific gift!";
    bool isTyping = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1B4B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "✨ FYNDO AI Assistant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  aiResponse,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: aiController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "e.g. What's the cheapest gadget?",
                  hintStyle: const TextStyle(color: Colors.white38),
                  suffixIcon: isTyping
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF6366F1),
                          ),
                          onPressed: () async {
                            setModalState(() => isTyping = true);
                            final resp = await AIService()
                                .getProductRecommendation(
                                  currentItems,
                                  aiController.text,
                                );
                            setModalState(() {
                              aiResponse = resp;
                              isTyping = false;
                            });
                          },
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1200 ? 5 : (width > 800 ? 3 : 2);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                : [const Color(0xFF6366F1), const Color(0xFFA5B4FC)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Product>>(
            stream: _productStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final allProducts = snapshot.data ?? [];

              // Filtering & Sorting Logic
              List<Product> filteredItems = allProducts.where((p) {
                final matchesCat =
                    selectedCategory == "All" || p.category == selectedCategory;
                final matchesSearch = p.name.toLowerCase().contains(
                  searchQuery,
                );
                return matchesCat && matchesSearch;
              }).toList();

              if (sortBy == "Low") {
                filteredItems.sort((a, b) => a.price.compareTo(b.price));
              } else if (sortBy == "High") {
                filteredItems.sort((a, b) => b.price.compareTo(a.price));
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "FYNDO",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isDark ? Icons.light_mode : Icons.dark_mode,
                                  color: Colors.white,
                                ),
                                onPressed: () => _safeThemeToggle(isDark),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.amberAccent,
                                ),
                                onPressed: () => _showAIAssistant(allProducts),
                              ),
                              _buildProfileMenu(context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (v) => setState(
                                  () => searchQuery = v.toLowerCase(),
                                ),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Search products...",
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.sort, color: Colors.white),
                              onSelected: (value) =>
                                  setState(() => sortBy = value),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: "Newest",
                                  child: Text("Newest first"),
                                ),
                                const PopupMenuItem(
                                  value: "Low",
                                  child: Text("Price: Low to High"),
                                ),
                                const PopupMenuItem(
                                  value: "High",
                                  child: Text("Price: High to Low"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // FIX 3: Added Category chips and Grid display inside the StreamBuilder
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children:
                            [
                              "All",
                              "Smart Gadgets",
                              "Electronics",
                              "Fashion",
                              "Home",
                            ].map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: selectedCategory == cat,
                                  onSelected: (selected) =>
                                      setState(() => selectedCategory = cat),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildProductCard(filteredItems[index], isDark),
                        childCount: filteredItems.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(Product p, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: p),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      p.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  p.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmDelete(p.id, p.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return IconButton(
      icon: const CircleAvatar(radius: 15, child: Icon(Icons.person, size: 20)),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
    );
  }
}
