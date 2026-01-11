import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers to handle text input and pre-filling
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _urlController;

  // Category management
  String _category = 'Smart Gadgets';
  final List<String> _categories = [
    'Smart Gadgets',
    'Electronics',
    'Fashion',
    'Home',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing data if editing
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '1',
    );
    _urlController = TextEditingController(
      text: widget.product?.imageUrl ?? '',
    );

    if (widget.product != null) {
      _category = _categories.contains(widget.product!.category)
          ? widget.product!.category
          : 'Other';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _handleSave(bool isUpdate) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      Product p = Product(
        id: widget.product?.id ?? '', // Reuse existing ID for updates
        name: _nameController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        imageUrl: _urlController.text,
        category: _category,
        stock: int.parse(_stockController.text),
      );

      try {
        if (isUpdate) {
          await DatabaseService().updateProduct(
            p,
          ); // Call specific update logic
        } else {
          await DatabaseService().addProduct(p);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Manage Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4338CA), Color(0xFF1E1B4B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildUrlImagePreview(),
                  const SizedBox(height: 20),

                  _buildOpaqueTextField("Product Name", _nameController),
                  const SizedBox(height: 15),
                  _buildOpaqueTextField(
                    "Image URL",
                    _urlController,
                    hint: "Paste link here...",
                  ),
                  const SizedBox(height: 15),
                  _buildOpaqueTextField(
                    "Description",
                    _descController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 15),

                  // CATEGORY SELECTION
                  _buildOpaqueDropdown(),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _buildOpaqueTextField(
                          "Price (\$)",
                          _priceController,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildOpaqueTextField(
                          "Stock",
                          _stockController,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // DIRECT BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          "PUBLISH",
                          Colors.green,
                          () => _handleSave(false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          "UPDATE",
                          Colors.orange,
                          () => _handleSave(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildUrlImagePreview() {
    return ValueListenableBuilder(
      valueListenable: _urlController,
      builder: (context, value, child) {
        return Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: _urlController.text.isEmpty
              ? const Icon(
                  Icons.image_outlined,
                  color: Colors.white54,
                  size: 50,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    _urlController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Center(
                      child: Text(
                        "Invalid URL",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildOpaqueTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildOpaqueDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      dropdownColor: const Color(0xFF1E1B4B),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Category",
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      items: _categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  Widget _buildActionButton(String title, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _isSaving ? null : onPressed,
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
