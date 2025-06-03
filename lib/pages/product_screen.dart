// lib/screens/product_screen.dart

import 'package:flutter/material.dart';
import '../services/productService.dart'; // Import ProductService
import '../model/productModel.dart'; // Perbaikan: Menggunakan 'models'
import '../services/auth_manager.dart'; // Untuk mendapatkan user_id dan role

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  List<product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _currentArtisanId; // ID Artisan yang sedang login

  // Controllers untuk formulir tambah/edit produk
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _mainImageUrlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  bool _isAvailable = true; // Default untuk is_available

  @override
  void initState() {
    super.initState();
    _loadArtisanIdAndFetchProducts(); // Memuat ID Artisan dan kemudian mengambil produk
  }

  // Memuat ID Artisan dan kemudian mengambil produk
  Future<void> _loadArtisanIdAndFetchProducts() async {
    _currentArtisanId = await AuthManager.getUserId();
    if (_currentArtisanId == null) {
      setState(() {
        _errorMessage = 'Anda harus login sebagai artisan untuk melihat produk Anda.';
        _isLoading = false;
      });
      return;
    }
    _fetchProducts(); // Lanjutkan dengan mengambil produk setelah ID tersedia
  }

  Future<void> _fetchProducts() async {
    // Pastikan _currentArtisanId sudah tersedia sebelum mengambil produk
    if (_currentArtisanId == null) {
      // Ini seharusnya sudah ditangani oleh _loadArtisanIdAndFetchProducts
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _productService.getAllProducts(artisanId: _currentArtisanId);
      if (result['success']) {
        setState(() {
          _products = result['data'];
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat produk.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat produk: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper untuk reset controllers
  void _resetControllers() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _currencyController.clear();
    _mainImageUrlController.clear();
    _categoryController.clear();
    _stockQuantityController.clear();
    _isAvailable = true;
  }

  // Method untuk menampilkan dialog tambah/edit produk
  Future<void> _showProductFormDialog({product? productToEdit}) async {
    final bool isEditing = productToEdit != null;
    final String dialogTitle = isEditing ? 'Edit Produk' : 'Tambah Produk Baru';
    final String buttonText = isEditing ? 'Simpan Perubahan' : 'Tambah Produk';

    // Isi controllers jika ini operasi edit, reset jika tambah baru
    if (isEditing) {
      _nameController.text = productToEdit!.name ?? '';
      _descriptionController.text = productToEdit.description ?? '';
      _priceController.text = productToEdit.price?.toString() ?? '';
      _currencyController.text = productToEdit.currency ?? '';
      _mainImageUrlController.text = productToEdit.main_image_url ?? '';
      _categoryController.text = productToEdit.category ?? '';
      _stockQuantityController.text = productToEdit.stock_quantity?.toString() ?? '';
      _isAvailable = productToEdit.is_available ?? true;
    } else {
      _resetControllers();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool isLoadingDialog = false;
        String? dialogErrorMessage;

        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(dialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Produk*', prefixIcon: Icon(Icons.shopping_bag)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)', prefixIcon: Icon(Icons.description)),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Harga*', prefixIcon: Icon(Icons.attach_money)),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _currencyController,
                      decoration: const InputDecoration(labelText: 'Mata Uang*', prefixIcon: Icon(Icons.payments)),
                      // Default currency could be 'IDR'
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _mainImageUrlController,
                      decoration: const InputDecoration(labelText: 'URL Gambar Utama (Opsional)', prefixIcon: Icon(Icons.image)),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Kategori (Opsional)', prefixIcon: Icon(Icons.category)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _stockQuantityController,
                      decoration: const InputDecoration(labelText: 'Jumlah Stok (Opsional)', prefixIcon: Icon(Icons.inventory)),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Tersedia:'),
                        Switch(
                          value: _isAvailable,
                          onChanged: (bool value) {
                            setStateInDialog(() {
                              _isAvailable = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (dialogErrorMessage != null)
                      Text(
                        dialogErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    isLoadingDialog
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              setStateInDialog(() {
                                isLoadingDialog = true;
                                dialogErrorMessage = null;
                              });

                              // Validasi input
                              if (_nameController.text.isEmpty ||
                                  _priceController.text.isEmpty ||
                                  _currencyController.text.isEmpty) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'Nama, Harga, dan Mata Uang wajib diisi.';
                                  isLoadingDialog = false;
                                });
                                return;
                              }
                              if (double.tryParse(_priceController.text) == null) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'Harga harus berupa angka valid.';
                                  isLoadingDialog = false;
                                });
                                return;
                              }
                              if (_currentArtisanId == null) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'ID Artisan tidak ditemukan. Mohon login ulang.';
                                  isLoadingDialog = false;
                                });
                                return;
                              }

                              try {
                                Map<String, dynamic> result;
                                if (isEditing) {
                                  if (productToEdit!.id == null) {
                                    throw Exception('Product ID is null for editing.');
                                  }
                                  result = await _productService.updateProduct(
                                    productToEdit.id!,
                                    name: _nameController.text,
                                    description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                                    price: double.parse(_priceController.text),
                                    currency: _currencyController.text,
                                    mainImageUrl: _mainImageUrlController.text.isEmpty ? null : _mainImageUrlController.text,
                                    category: _categoryController.text.isEmpty ? null : _categoryController.text,
                                    stockQuantity: int.tryParse(_stockQuantityController.text),
                                    isAvailable: _isAvailable,
                                  );
                                } else {
                                  result = await _productService.createProduct(
                                    _currentArtisanId!,
                                    name: _nameController.text,
                                    description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                                    price: double.parse(_priceController.text),
                                    currency: _currencyController.text,
                                    mainImageUrl: _mainImageUrlController.text.isEmpty ? null : _mainImageUrlController.text,
                                    category: _categoryController.text.isEmpty ? null : _categoryController.text,
                                    stockQuantity: int.tryParse(_stockQuantityController.text),
                                    isAvailable: _isAvailable,
                                  );
                                }

                                if (result['success']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'])),
                                  );
                                  Navigator.of(dialogContext).pop();
                                  _fetchProducts(); // Refresh daftar produk
                                } else {
                                  setStateInDialog(() {
                                    dialogErrorMessage = result['message'] ?? 'Gagal menyimpan produk.';
                                  });
                                }
                              } catch (e) {
                                setStateInDialog(() {
                                  dialogErrorMessage = 'Error API: $e';
                                });
                              } finally {
                                setStateInDialog(() {
                                  isLoadingDialog = false;
                                });
                              }
                            },
                            child: Text(buttonText),
                          ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Menampilkan dialog konfirmasi penghapusan produk
  Future<void> _showDeleteConfirmationDialog(product productToDelete) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text('Apakah Anda yakin ingin menghapus produk "${productToDelete.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (productToDelete.id != null) {
                  final result = await _productService.deleteProduct(productToDelete.id!);
                  if (result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                    Navigator.of(context).pop(); // Tutup dialog konfirmasi
                    _fetchProducts(); // Refresh daftar produk
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Gagal menghapus produk.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Produk',
            onPressed: () => _showProductFormDialog(), // Panggil dialog tanpa argumen untuk tambah
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Daftar',
            onPressed: _fetchProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _products.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'Anda belum memiliki produk. Ketuk ikon + untuk menambahkannya.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gambar Produk
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: product.main_image_url != null && product.main_image_url!.isNotEmpty
                                        ? Image.network(
                                            product.main_image_url!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                          )
                                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                // Detail Produk
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name ?? 'Nama Produk Tidak Diketahui',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${product.currency ?? ''} ${product.price?.toStringAsFixed(2) ?? '-'}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Stok: ${product.stock_quantity ?? '-'} | Kategori: ${product.category ?? '-'}',
                                        style: TextStyle(color: Colors.grey[700], fontSize: 14.0),
                                      ),
                                      Text(
                                        product.is_available == true ? 'Tersedia' : 'Tidak Tersedia',
                                        style: TextStyle(
                                          color: product.is_available == true ? Colors.green : Colors.red,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tombol Aksi
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        _showProductFormDialog(productToEdit: product); // Panggil dialog dengan produk untuk edit
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(product);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
