import 'package:flutter/material.dart';
import '../model/productModel.dart';
import '../services/productService.dart';
import '../services/auth_manager.dart';
import '../theme/theme.dart';
import 'add_edit_product_screen.dart'; // Import the new screen

class ProductManagementScreen extends StatefulWidget {
  final int artisanId;

  const ProductManagementScreen({super.key, required this.artisanId});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductService _productService = ProductService();
  List<product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _productService.getAllProducts(artisanId: widget.artisanId);
      if (result['success']) {
        setState(() {
          _products = result['data'];
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load products.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while loading products: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(int productId) async {
    // Show a confirmation dialog
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User canceled
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // User confirmed
              },
            ),
          ],
        );
      },
    ) ?? false; // Default to false if dialog is dismissed

    if (!confirmDelete) {
      return; // Do nothing if user canceled
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _productService.deleteProduct(productId);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _fetchProducts(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to delete product')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Produk',
          style: TextStyle(
            color: Colors.black,
            fontFamily: "jakarta-sans",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF4300FF)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditProductScreen(
                    artisanId: widget.artisanId,
                  ),
                ),
              );
              if (result == true) {
                _fetchProducts(); // Refresh if a product was added/edited
              }
            },
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
                      style: const TextStyle(color: Colors.red, fontSize: 16, fontFamily: "jakarta-sans"),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _products.isEmpty
                  ? const Center(child: Text('Belum ada produk yang ditambahkan.', style: TextStyle(fontFamily: "jakarta-sans"),))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final productItem = _products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Product Image (placeholder for now)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    image: productItem.main_image_url != null && productItem.main_image_url!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(productItem.main_image_url!),
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) {
                                              // Handle image loading errors, show a placeholder
                                              print('Error loading image: $exception');
                                            },
                                          )
                                        : null,
                                  ),
                                  child: (productItem.main_image_url == null || productItem.main_image_url!.isEmpty)
                                      ? const Icon(Icons.image, size: 40, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productItem.name ?? 'Nama Produk Tidak Diketahui',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          fontFamily: "jakarta-sans",
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${productItem.currency ?? ''} ${productItem.price?.toStringAsFixed(2) ?? 'N/A'}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "jakarta-sans",
                                        ),
                                      ),
                                      Text(
                                        'Stok: ${productItem.stock_quantity ?? 'N/A'}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontFamily: "jakarta-sans",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddEditProductScreen(
                                              artisanId: widget.artisanId,
                                              productToEdit: productItem,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _fetchProducts(); // Refresh after edit
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteProduct(productItem.id!),
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
}
