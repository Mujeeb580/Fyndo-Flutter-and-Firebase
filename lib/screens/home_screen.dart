import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_screen.dart';
import '../services/database_service.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../main.dart'; // Access themeNotifier
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
  final TextEditingController _searchController = TextEditingController();

  // Initialize the stream to fetch data from Firestore
  final Stream<List<Product>> _productStream = DatabaseService().getProducts();

  // Safely toggle theme without build crashes
  void _safeThemeToggle(bool isDark) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
      }
    });
  }

  // Confirmation Dialog for Deleting
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
        content: Text("Are you sure you want to remove '$productName'?"),
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

    // Responsive grid columns
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
              // 1. BRANDING & PROFILE BAR
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

              // 2. SEARCH BAR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) =>
                          setState(() => searchQuery = v.toLowerCase()),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Search smart products...",
                        hintStyle: TextStyle(color: Colors.white60),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. CATEGORY SELECTOR
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 10),
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
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
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

              // 4. THE PRODUCT GRID
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

                  final items = (snapshot.data ?? []).where((p) {
                    final matchesCat =
                        selectedCategory == "All" ||
                        p.category == selectedCategory;
                    final matchesSearch = p.name.toLowerCase().contains(
                      searchQuery,
                    );
                    return matchesCat && matchesSearch;
                  }).toList();

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio:
                            0.75, // Adjust this if cards look squashed
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

  // THE FIXED PRODUCT CARD
  Widget _buildProductCard(Product p, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // LAYER 1: CONTENT (Image and Name)
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

          // LAYER 2: THE DELETE BUTTON (Guaranteed top-most layer)
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
