import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Use http://10.0.2.2:5000 if testing on Android Emulator, or http://127.0.0.1:5000 for Desktop/Web
  final String baseUrl = 'http://127.0.0.1:5000';
  
  Set<int> likedProductIds = {};
  bool isLoading = true;

  final List<Map<String, dynamic>> products = [
    {'id': 1, 'name': 'Laptop', 'price': '\$999'},
    {'id': 2, 'name': 'Smartphone', 'price': '\$699'},
    {'id': 3, 'name': 'Headphones', 'price': '\$199'},
  ];

  @override
  void initState() {
    super.initState();
    fetchLikes();
  }

  Future<void> fetchLikes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/likes'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> likedList = data['liked_products'];
        setState(() {
          likedProductIds = likedList.map((e) => e as int).toSet();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching likes: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleLike(int productId) async {
    final isLiked = likedProductIds.contains(productId);

    setState(() {
      if (isLiked) {
        likedProductIds.remove(productId);
      } else {
        likedProductIds.add(productId);
      }
    });

    try {
      if (isLiked) {
        await http.delete(Uri.parse('$baseUrl/likes/$productId'));
      } else {
        await http.post(
          Uri.parse('$baseUrl/likes'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'product_id': productId}),
        );
      }
    } catch (e) {
      print('Error updating like state: $e');
      setState(() {
        if (isLiked) {
          likedProductIds.add(productId);
        } else {
          likedProductIds.remove(productId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce Products'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final int id = product['id'];
                final bool isLiked = likedProductIds.contains(id);

                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text(product['price']),
                  trailing: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : null,
                    ),
                    onPressed: () => toggleLike(id),
                  ),
                );
              },
            ),
    );
  }
}