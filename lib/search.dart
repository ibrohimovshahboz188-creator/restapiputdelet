import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ingredientl.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List items = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> searchFromApi(String query) async {
    if (query.isEmpty) {
      setState(() {
        items = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?query=$query&number=10&apiKey=0e18eab3239447daa969ee436fa025ec');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        items = data['results'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails(int recipeId) async {
    final response = await http.get(Uri.parse(
      'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=0e18eab3239447daa969ee436fa025ec&includeNutrition=false',
    ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Recipes"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (value.length > 2) {
                  searchFromApi(value);
                } else {
                  setState(() {
                    items = [];
                  });
                }
              },
              decoration: InputDecoration(
                hintText: "Search for recipes...",
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      items = [];
                    });
                  },
                ),
              ),
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (items.isEmpty && _searchController.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No recipes found"),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item["image"] ?? "",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.fastfood, size: 40),
                        ),
                      ),
                      title: Text(
                        item["title"] ?? "Unknown Recipe",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        try {
                          final details = await fetchRecipeDetails(item["id"]);
                          if (!mounted) return;
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Ingredientl(
                                title: details["title"] ?? "Unknown",
                                imageUrl: details["image"] ?? "",
                                readyInMinutes: details["readyInMinutes"] ?? 0,
                                servings: details["servings"] ?? 0,
                                ingredients: details["extendedIngredients"] ?? [],
                                recipeId: item["id"],
                                instructions: [], 
                              ),
                            ),
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Failed to load recipe details")),
                            );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}