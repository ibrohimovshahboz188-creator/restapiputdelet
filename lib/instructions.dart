import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Instructions extends StatefulWidget {
  const Instructions({super.key});

  @override
  State<Instructions> createState() => _InstructionsState();
}

class _InstructionsState extends State<Instructions> {
  List<dynamic> instructions = [];
  bool isLoading = true;

  Future<void> fetchInstructions() async {
    final url = Uri.parse("https://api.spoonacular.com/recipes/random?number=20&apiKey=0e18eab3239447daa969ee436fa025ec");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final recipes = data["recipes"];

      // Har bir retseptdan instructions ni olish
      final allInstructions = recipes.map((recipe) {
        return recipe["analyzedInstructions"]?.isNotEmpty == true
            ? recipe["analyzedInstructions"][0]["steps"]
                .map((step) => {
                      "number": step["number"],
                      "step": step["step"],
                    })
                .toList()
            : [];
      }).expand((x) => x).toList();

      setState(() {
        instructions = allInstructions;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Xatolik: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInstructions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instructions"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : instructions.isEmpty
              ? const Center(child: Text("Ko‘rsatmalar topilmadi"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: instructions.length,
                  itemBuilder: (context, index) {
                    final instruction = instructions[index];
                    return ListTile(
                      leading: Text(
                        "${instruction['number']}.",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      title: Text(
                        instruction['step'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
    );
  }
}