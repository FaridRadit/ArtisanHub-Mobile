import 'package:flutter/material.dart';
import '../model/productModel.dart';
import '../services/productService.dart';
import '../theme/theme.dart';

class AddEditProductScreen extends StatefulWidget {
  final int artisanId;
  final product? productToEdit; // Nullable for adding, not null for editing

  const AddEditProductScreen({
    super.key,
    required this.artisanId,
    this.productToEdit,
  });

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final ProductService _productService = ProductService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _mainImageUrlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  bool _isAvailable = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      // Populate fields if in edit mode
      _nameController.text = widget.productToEdit!.name ?? '';
      _descriptionController.text = widget.productToEdit!.description ?? '';
      _priceController.text = widget.productToEdit!.price?.toString() ?? '';
      _currencyController.text = widget.productToEdit!.currency ?? '';
      _mainImageUrlController.text = widget.productToEdit!.main_image_url ?? '';
      _categoryController.text = widget.productToEdit!.category ?? '';
      _stockQuantityController.text = widget.productToEdit!.stock_quantity?.toString() ?? '';
      _isAvailable = widget.productToEdit!.is_available ?? true;
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        Map<String, dynamic> result;
        final name = _nameController.text;
        final description = _descriptionController.text;
        final price = double.tryParse(_priceController.text);
        final currency = _currencyController.text;
        final mainImageUrl = _mainImageUrlController.text;
        final category = _categoryController.text;
        final stockQuantity = int.tryParse(_stockQuantityController.text);

        if (widget.productToEdit == null) {
          // Add new product
          result = await _productService.createProduct(
            widget.artisanId,
            name: name,
            description: description,
            price: price,
            currency: currency,
            mainImageUrl: mainImageUrl,
            category: category,
            stockQuantity: stockQuantity,
            isAvailable: _isAvailable,
          );
        } else {
          // Update existing product
          result = await _productService.updateProduct(
            widget.productToEdit!.id!,
            name: name,
            description: description,
            price: price,
            currency: currency,
            mainImageUrl: mainImageUrl,
            category: category,
            stockQuantity: stockQuantity,
            isAvailable: _isAvailable,
          );
        }

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to save product.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.productToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Produk' : 'Tambah Produk Baru',
          style: const TextStyle(
            color: Colors.black,
            fontFamily: "jakarta-sans",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
                style: const TextStyle(fontFamily: "jakarta-sans"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                style: const TextStyle(fontFamily: "jakarta-sans"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga*'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan harga yang valid';
                  }
                  return null;
                },
                style: const TextStyle(fontFamily: "jakarta-sans"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currencyController,
                decoration: const InputDecoration(labelText: 'Mata Uang (contoh: IDR, USD)*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mata uang tidak boleh kosong';
                  }
                  return null;
                },
                style: const TextStyle(fontFamily: "jakarta-sans"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mainImageUrlController,
                decoration: const InputDecoration(labelText: 'URL Gambar Utama'),
                keyboardType: TextInputType.url,
                style: const TextStyle(fontFamily: "jakarta-sans"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                style: const TextStyle(fontFamily: "jakarta-sans"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(labelText: 'Jumlah Stok*'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah stok tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan jumlah stok yang valid';
                  }
                  return null;
                },
                style: const TextStyle(fontFamily: "jakarta-sans"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Tersedia:', style: TextStyle(fontSize: 16, fontFamily: "jakarta-sans")),
                  Switch(
                    value: _isAvailable,
                    onChanged: (bool value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontFamily: "jakarta-sans"),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
                          style: const TextStyle(fontSize: 16, fontFamily: "jakarta-sans"),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _mainImageUrlController.dispose();
    _categoryController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }
}
