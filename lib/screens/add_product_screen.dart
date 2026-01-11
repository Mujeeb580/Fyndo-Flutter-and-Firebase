import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();

  String _name = '';
  double _price = 0;
  String _description = '';
  int _stock = 1;
  String _category = 'Smart Gadgets';

  @override
  void initState() {
    super.initState();
    _imageUrlController.text =
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop';
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Product newProduct = Product(
        name: _name,
        price: _price,
        imageUrl: _imageUrlController.text,
        category: _category,
        // Ensure your Product model has these fields, or add them now
        // description: _description,
        // stock: _stock,
      );

      await DatabaseService().addProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully added to FYNDO!"),
            backgroundColor: Color(0xFF6366F1),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Create Listing",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4338CA), Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- PREMIUM IMAGE PREVIEW ---
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(_imageUrlController.text),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(12),
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.white,
                        onPressed: _showImageUrlDialog,
                        child: const Icon(Icons.edit, color: Color(0xFF6366F1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- INPUT FIELDS CARD ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Primary Information",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E1B4B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: _buildInputDecoration(
                            "Product Title",
                            Icons.title,
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Title required" : null,
                          onSaved: (v) => _name = v!,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: _buildInputDecoration(
                                  "Price",
                                  Icons.payments,
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (v) => _price = double.parse(v!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: _buildInputDecoration(
                                  "Stock",
                                  Icons.inventory_2,
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (v) => _stock = int.parse(v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField(
                          value: _category,
                          decoration: _buildInputDecoration(
                            "Category",
                            Icons.grid_view,
                          ),
                          items:
                              [
                                    'Electronics',
                                    'Fashion',
                                    'Home',
                                    'Smart Gadgets',
                                  ]
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) =>
                              setState(() => _category = v.toString()),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          maxLines: 3,
                          decoration: _buildInputDecoration(
                            "Description",
                            Icons.description,
                          ),
                          onSaved: (v) => _description = v!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- GRADIENT SUBMIT BUTTON ---
                  GestureDetector(
                    onTap: _saveProduct,
                    child: Container(
                      height: 65,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Publish Product",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF6366F1)),
      ),
    );
  }

  void _showImageUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Image Source"),
        content: TextField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            hintText: "Enter Image URL (Unsplash/Imgur)",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Set Image"),
          ),
        ],
      ),
    );
  }
}
