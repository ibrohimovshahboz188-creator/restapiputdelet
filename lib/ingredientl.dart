import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Ingredientl extends StatefulWidget {
  final String title;
  final String imageUrl;
  final int readyInMinutes;
  final int servings;
  final List ingredients;
  final int recipeId;

  const Ingredientl({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.readyInMinutes,
    required this.servings,
    required this.ingredients,
    required this.recipeId,
    required List instructions, 
  });

  @override
  State<Ingredientl> createState() => _IngredientlState();
}

class _IngredientlState extends State<Ingredientl> {
  bool showIngredients = true;
  bool isListView = true;
  bool isFavorite = false;
  late Future<List<String>> futureInstructions;
  bool showSaveNotification = false; 
  double notificationTop = -50.0; 

  @override
  void initState() {
    super.initState();
    futureInstructions = fetchInstructions(widget.recipeId);
    final wishlistBox = Hive.box('wishlistBox');
    final savedItems = wishlistBox.values.toList();
    for (var item in savedItems) {
      if (item['title'] == widget.title) {
        setState(() {
          isFavorite = true;
        });
        break;
      }
    }
  }

  Future<List<String>> fetchInstructions(int recipeId) async {
    final response = await http.get(Uri.parse(
      'https://api.spoonacular.com/recipes/$recipeId/analyzedInstructions?apiKey=0e18eab3239447daa969ee436fa025ec',
    ));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        List<dynamic> steps = data[0]["steps"];
        return steps.map<String>((step) {
          return "${step["number"]}. ${step["step"]}";
        }).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load instructions: ${response.statusCode}');
    }
  }

  void toggleFavorite() {
    final wishlistBox = Hive.box('wishlistBox');
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      final dataToSave = {
        'title': widget.title,
        'imageUrl': widget.imageUrl, 
        'readyInMinutes': widget.readyInMinutes,
        'servings': widget.servings,
        'ingredients': widget.ingredients,
        'recipeId': widget.recipeId,
      };
      wishlistBox.add(dataToSave);
      print("Saqlangan ma'lumot: $dataToSave");
      
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
      final itemToRemove = widget.title;
      final keyToRemove = wishlistBox.keys.firstWhere(
        (key) => wishlistBox.get(key)['title'] == itemToRemove,
        orElse: () => null,
      );
      if (keyToRemove != null) {
        wishlistBox.delete(keyToRemove);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
        actions: [
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(height: 250, color: Colors.grey),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 30,
                        ),
                        onPressed: toggleFavorite,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: Colors.green),
                      SizedBox(width: 5),
                      Text("${widget.readyInMinutes} min", style: TextStyle(color: Colors.green)),
                      Spacer(),
                      Text("${widget.servings}", style: TextStyle(color: Colors.green)),
                      Icon(Icons.restaurant_menu, color: Colors.green),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => showIngredients = true),
                      child: Text(
                        "Ingredients",
                        style: TextStyle(
                          color: showIngredients ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          decoration: showIngredients ? TextDecoration.underline : TextDecoration.none,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => showIngredients = false),
                      child: Text(
                        "Instructions",
                        style: TextStyle(
                          color: !showIngredients ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          decoration: !showIngredients ? TextDecoration.underline : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (showIngredients)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => isListView = false),
                          style: TextButton.styleFrom(
                            backgroundColor: !isListView ? Colors.green : Colors.grey.shade200,
                          ),
                          child: Text(
                            "grid",
                            style: TextStyle(color: !isListView ? Colors.white : Colors.black),
                          ),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () => setState(() => isListView = true),
                          style: TextButton.styleFrom(
                            backgroundColor: isListView ? Colors.green : Colors.grey.shade200,
                          ),
                          child: Text(
                            "list",
                            style: TextStyle(color: isListView ? Colors.white : Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 10),
                if (showIngredients)
                  isListView
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.ingredients.length,
                          itemBuilder: (context, index) {
                            final ingredient = widget.ingredients[index];
                            final image = ingredient["image"] ?? "";
                            final name = ingredient["original"] ?? "";

                            return Expanded(
                              child: ListTile(
                                leading: image.isNotEmpty
                                    ? Image.network(
                                        "https://spoonacular.com/cdn/ingredients_100x100/$image",
                                        width: 90,
                                        height: 90,
                                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image),
                                      )
                                    : Icon(Icons.food_bank),
                                title: Text(name),
                              ),
                            );
                          },
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.ingredients.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              final ingredient = widget.ingredients[index];
                              final image = ingredient["image"] ?? "";
                              final name = ingredient["original"] ?? "";

                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (image.isNotEmpty)
                                            Image.network(
                                              "https://spoonacular.com/cdn/ingredients_100x100/$image",
                                              width: 120,
                                              height: 120,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Icon(Icons.image),
                                              fit: BoxFit.cover,
                                            ),
                                          SizedBox(height: 12),
                                          Text(
                                            name,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("OK", style: TextStyle(color: Colors.green)),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Column(
                                    children: [
                                      if (image.isNotEmpty)
                                        Image.network(
                                          "https://spoonacular.com/cdn/ingredients_100x100/$image",
                                          width: 50,
                                          height: 50,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.image),
                                        ),
                                      SizedBox(height: 8),
                                      Text(
                                        name,
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                else
                  FutureBuilder<List<String>>(
                    future: futureInstructions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading instructions: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No instructions found'));
                      } else {
                        final instructions = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: instructions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: instructions[index].split('. ')[0] + '. ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextSpan(
                                      text: instructions[index].substring(instructions[index].indexOf('. ') + 2),
                                      style: TextStyle(
                                        color: Colors.green.shade500,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
              ],
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
                  ),
                ],
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