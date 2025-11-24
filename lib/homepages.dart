import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'ingredientl.dart';

class Homepages extends StatefulWidget {
static const String id = "home_page";
  const Homepages({super.key});

  @override
  State<Homepages> createState() => _HomepagesState();
}
//dfefdefef
class _HomepagesState extends State<Homepages> {
  List items = [];
  List<bool> favorites = [];
  bool showSaveNotification = false;
  double notificationTop = -50.0;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchdata();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore &&
        hasMore) {
      loadMoreRecipes();
    }
  }

  Future<void> fetchdata() async {
    final url = Uri.parse(
        "https://api.spoonacular.com/recipes/random?number=10&apiKey=0e18eab3239447daa969ee436fa025ec");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        items = data["recipes"];
        favorites = List.generate(items.length, (_) => false);
      });
    } else {
      print("Error ${response.statusCode}");
    }
  }

  Future<void> loadMoreRecipes() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final url = Uri.parse(
          "https://api.spoonacular.com/recipes/random?number=10&apiKey=0e18eab3239447daa969ee436fa025ec");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newRecipes = data["recipes"];

        setState(() {
          items.addAll(newRecipes);
          favorites.addAll(List.generate(newRecipes.length, (_) => false));
          currentPage++;
          // If we get fewer than 10 recipes, assume we've reached the end
          if (newRecipes.length < 10) {
            hasMore = false;
          }
        });
      }
    } catch (e) {
      print("Error loading more recipes: $e");
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlistBox = Hive.box('wishlistBox');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification &&
                        _scrollController.position.pixels ==
                            _scrollController.position.maxScrollExtent &&
                        !isLoadingMore &&
                        hasMore) {
                      loadMoreRecipes();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: items.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final item = items[index];
                      final title = item["title"];
                      final imageUrl = item["image"] ?? "";
                      final readyInMinutes = item["readyInMinutes"];
                      final servings = item["servings"];
                      final recipeId = item["id"];

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Ingredientl(
                              imageUrl: imageUrl,
                              title: title,
                              readyInMinutes: readyInMinutes,
                              servings: servings,
                              ingredients: item["extendedIngredients"] ?? [],
                              recipeId: recipeId,
                              instructions: [],
                            ),
                          ));
                        },
                        child: Card(
                          margin: const EdgeInsets.all(12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      height: 100,
                                      width: 100,
                                      color: Colors.grey,
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                favorites[index] = !favorites[index];
                                                if (favorites[index]) {
                                                  final dataToSave = {
                                                    'title': title,
                                                    'imageUrl': imageUrl,
                                                    'readyInMinutes': readyInMinutes,
                                                    'servings': servings,
                                                    'ingredients': item["extendedIngredients"] ?? [],
                                                    'recipeId': recipeId,
                                                  };
                                                  wishlistBox.add(dataToSave);
                                                  setState(() {
                                                    notificationTop = 60.0;
                                                  });
                                                  Future.delayed(const Duration(milliseconds: 1500), () {
                                                    if (mounted) {
                                                      setState(() {
                                                        notificationTop = -50.0;
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  final itemToRemove = title;
                                                  final keyToRemove = wishlistBox.keys.firstWhere(
                                                    (key) => wishlistBox.get(key)["title"] == itemToRemove,
                                                    orElse: () => null,
                                                  );
                                                  if (keyToRemove != null) {
                                                    wishlistBox.delete(keyToRemove);
                                                  }
                                                }
                                              });
                                            },
                                            icon: Icon(
                                              favorites[index]
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: favorites[index]
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 8,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.timer_rounded,
                                                  size: 16, color: Colors.green),
                                              const SizedBox(width: 4),
                                              Text("$readyInMinutes min",
                                                  style: const TextStyle(color: Colors.green)),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.apple,
                                                  size: 16, color: Colors.green),
                                              const SizedBox(width: 4),
                                              Text("$servings",
                                                  style: const TextStyle(color: Colors.green)),
                                            ],
                                          ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: notificationTop,
            right: 10,
            child: Container(
              width: 100,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
              )],
              ),
              child: const Center(
                child: Text(
                  "Saqlandi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}