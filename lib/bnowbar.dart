  import 'package:flutter/material.dart';
  import 'package:restapiputdelet/homepages.dart';
  import 'package:restapiputdelet/search.dart';
  import 'package:restapiputdelet/wishlist.dart';

  class Bnowbar extends StatefulWidget {
    static final String id="bnowbar_page";
    const Bnowbar({super.key});

    @override
    State<Bnowbar> createState() => _BnowbarState();
  }

  class _BnowbarState extends State<Bnowbar> {
    int _sellectindex=0;
    final List<Widget> pages=[
      Homepages(),
      Wishlist(),
      Search(),
      
    ];

    /*GIT push test*/

    void _onitenTapped(int index){
      setState(() {
        _sellectindex=index;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
      body: pages[_sellectindex],
      bottomNavigationBar:BottomNavigationBar(
        currentIndex: _sellectindex,
        onTap: _onitenTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home,color: Colors.green,), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite,color: Colors.green,), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.search,color: Colors.green,), label: "Search"),
        ]) ,
      );
    }
  }
