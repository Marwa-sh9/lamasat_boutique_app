import 'package:flutter/material.dart';
import 'package:lamasatboutiquemyapp/Pages/About/about_screen.dart';
import '../../Pages/Favorite/favorite_screen.dart';
import '../../Pages/mycategory/categoris_screen.dart';
import '../../Pages/my_home/home_screen.dart';
import '../constants/app_strings.dart';

class MyNavBar extends StatelessWidget {
  const MyNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 50.0,
      backgroundColor: AppBarColor,
      destinations: [
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            },
            icon: Icon(
              Icons.home,
              color: TextLargColor,
            )),
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoriesViewScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.category_outlined,
              color: TextLargColor,
            )),
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.favorite,
              color: TextLargColor,
            )),
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => About(),
                ),
              );
            },
            icon: Icon(
              Icons.details,
              color: TextLargColor,
            )),
      ],
    );
  }
}
