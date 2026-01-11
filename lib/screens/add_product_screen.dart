import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';

import '../models/product_model.dart';

import '../services/database_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  XFile? _pickedFile;

  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;

  // Form Fields

  String _name = '';

  String _description = '';

  double _price = 0;

  double _originalPrice = 0;

  int _stock = 1;

  String _category = 'Smart Gadgets';

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() => _pickedFile = image);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedFile == null) return null;

    try {
      String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.png';

      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      final uploadTask = storageRef.putData(await _pickedFile!.readAsBytes());

      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate() && _pickedFile != null) {
      setState(() => _isUploading = true);

      _formKey.currentState!.save();

      String? imageUrl = await _uploadImage();

      if (imageUrl != null) {
        Product newProduct = Product(
          id: '',

          name: _name,

          price: _price,

          imageUrl: imageUrl,

          category: _category,
        );

        await DatabaseService().addProduct(newProduct);

        if (mounted) Navigator.pop(context);
      } else {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          "New Listing",

          style: TextStyle(
            color: Colors.white,

            fontWeight: FontWeight.bold,

            letterSpacing: 1.2,
          ),
        ),

        backgroundColor: Colors.transparent,

        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Container(
        height: MediaQuery.of(context).size.height,

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildSectionLabel("PRODUCT MEDIA"),

                  _buildOpaqueImageCard(),

                  const SizedBox(height: 25),

                  _buildSectionLabel("GENERAL DETAILS"),

                  _buildOpaqueCard([
                    _buildOpaqueTextField(
                      "Product Name",

                      (v) => _name = v!,

                      hint: "Enter title",
                    ),

                    const SizedBox(height: 15),

                    _buildOpaqueTextField(
                      "Description",

                      (v) => _description = v!,

                      hint: "Describe the item...",

                      maxLines: 3,
                    ),
                  ]),

                  const SizedBox(height: 25),

                  _buildSectionLabel("PRICING & STOCK"),

                  _buildOpaqueCard([
                    Row(
                      children: [
                        Expanded(
                          child: _buildOpaqueTextField(
                            "Price (\$)",

                            (v) => _price = double.parse(v!),

                            isNumber: true,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildOpaqueTextField(
                            "Stock",

                            (v) => _stock = int.parse(v!),

                            isNumber: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildOpaqueDropdown(),
                  ]),

                  const SizedBox(height: 40),

                  _buildGlassButton(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS (OPAQUE STYLE) ---

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),

      child: Text(
        text,

        style: TextStyle(
          color: Colors.white.withOpacity(0.6),

          fontSize: 12,

          fontWeight: FontWeight.bold,

          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildOpaqueCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),

        borderRadius: BorderRadius.circular(28),

        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),

      child: Column(children: children),
    );
  }

  Widget _buildOpaqueImageCard() {
    return GestureDetector(
      onTap: _pickImage,

      child: Container(
        height: 180,

        width: double.infinity,

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),

          borderRadius: BorderRadius.circular(28),

          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        ),

        child: _pickedFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.add_a_photo_outlined,

                    color: Colors.white.withOpacity(0.8),

                    size: 40,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "UPLOAD IMAGE",

                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),

                      fontWeight: FontWeight.bold,

                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(28),

                child: Image.network(_pickedFile!.path, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildOpaqueTextField(
    String label,

    Function(String?) onSave, {

    String? hint,

    bool isNumber = false,

    int maxLines = 1,
  }) {
    return TextFormField(
      maxLines: maxLines,

      keyboardType: isNumber ? TextInputType.number : TextInputType.text,

      style: const TextStyle(color: Colors.white, fontSize: 15),

      decoration: InputDecoration(
        labelText: label,

        hintText: hint,

        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),

        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),

        filled: true,

        fillColor: Colors.black.withOpacity(0.1),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,

          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),

          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),

          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      ),

      onSaved: onSave,

      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildOpaqueDropdown() {
    return DropdownButtonFormField(
      value: _category,

      dropdownColor: const Color(0xFF1E1B4B),

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        labelText: "Category",

        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),

        filled: true,

        fillColor: Colors.black.withOpacity(0.1),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),

          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),

          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      ),

      items: ['Electronics', 'Fashion', 'Home', 'Smart Gadgets']
          .map(
            (c) => DropdownMenuItem(
              value: c,

              child: Text(c, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),

      onChanged: (v) => setState(() => _category = v.toString()),
    );
  }

  Widget _buildGlassButton() {
    return Container(
      width: double.infinity,

      height: 65,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        gradient: const LinearGradient(
          colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),

            blurRadius: 15,

            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,

          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),

        onPressed: _isUploading ? null : _saveProduct,

        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "PUBLISH PRODUCT",

                style: TextStyle(
                  color: Colors.white,

                  fontWeight: FontWeight.bold,

                  fontSize: 16,

                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }
}
