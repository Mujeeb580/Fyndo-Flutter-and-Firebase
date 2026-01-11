import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_screen.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'add_product_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  String sortBy = "Newest"; // Default sorting state
  final TextEditingController _searchController = TextEditingController();

  final Stream<List<Product>> _productStream = DatabaseService().getProducts();

  void _safeThemeToggle(bool isDark) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
      }
    });
  }

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
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Product deleted"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // 1. BRANDING BAR
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
                          _buildProfileMenu(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. SEARCH BAR & SORTING FILTER (REWRITTEN)
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
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) =>
                                setState(() => searchQuery = v.toLowerCase()),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Search products...",
                              hintStyle: TextStyle(color: Colors.white60),
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
                      // THE SORTING BUTTON
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.sort, color: Colors.white),
                          offset: const Offset(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          onSelected: (value) => setState(() => sortBy = value),
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

              // 3. CATEGORY SELECTOR
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children:
                        [
                              "All",
                              "Smart Gadgets",
                              "Electronics",
                              "Fashion",
                              "Home",
                            ]
                            .map(
                              (cat) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: selectedCategory == cat,
                                  selectedColor: Colors.white,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.1,
                                  ),
                                  labelStyle: TextStyle(
                                    color: selectedCategory == cat
                                        ? const Color(0xFF6366F1)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => selectedCategory = cat),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),

              // 4. PRODUCT GRID WITH SORTING LOGIC
              StreamBuilder<List<Product>>(
                stream: _productStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  // Filtering logic
                  List<Product> items = (snapshot.data ?? []).where((p) {
                    final matchesCat =
                        selectedCategory == "All" ||
                        p.category == selectedCategory;
                    final matchesSearch = p.name.toLowerCase().contains(
                      searchQuery,
                    );
                    return matchesCat && matchesSearch;
                  }).toList();

                  // Sorting Logic applied here
                  if (sortBy == "Low") {
                    items.sort((a, b) => a.price.compareTo(b.price));
                  } else if (sortBy == "High") {
                    items.sort((a, b) => b.price.compareTo(a.price));
                  } else {
                    // Default / Newest (Firestore usually returns in order created)
                    items = items.reversed.toList();
                  }

                  if (items.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text(
                            "No items found",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildProductCard(items[index], isDark),
                        childCount: items.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        label: const Text(
          "SELL",
          style: TextStyle(
            color: Color(0xFF6366F1),
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
      ),
    );
  }

  Widget _buildProductCard(Product p, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${p.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _confirmDelete(p.id, p.name),
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        backgroundColor: Colors.white24,
        child: Icon(Icons.person, color: Colors.white),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (v) {
        if (v == 'settings')
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        if (v == 'logout') AuthService().signOut();
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'settings', child: Text("Settings")),
        const PopupMenuItem(
          value: 'logout',
          child: Text("Sign Out", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
