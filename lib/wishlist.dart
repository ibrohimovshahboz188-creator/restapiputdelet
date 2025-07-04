import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ingredientl.dart'; 

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wishlist"),
        backgroundColor: Colors.green,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('wishlistBox').listenable(),
        builder: (context, box, widget) {
          final items = box.values.toList();
          if (items.isEmpty) {
            return Center(child: Text("Wishlist bo'sh"));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Ingredientl(
                      title: item['title'] ?? 'No Title',
                      imageUrl: item['imageUrl'] ?? '',
                      readyInMinutes: item['readyInMinutes'] ?? 0,
                      servings: item['servings'] ?? 0,
                      ingredients: item['ingredients'] ?? [],
                      recipeId: item['recipeId'] ?? 0,
                      instructions: [], 
                    ),
                  ));
                },
                child: ListTile(
                  leading: item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                      ? Image.network(
                          item['imageUrl'],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported),
                        )
                      : Icon(Icons.image_not_supported),
                  title: Text(item['title'] ?? 'No Title', style: TextStyle(color: Colors.green)),
                  subtitle: Text(
                      "${item['readyInMinutes'] ?? 0} min | ${item['servings'] ?? 0} servings",
                      style: TextStyle(color: Colors.green)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      box.deleteAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "O'chirildi", textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.red,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}