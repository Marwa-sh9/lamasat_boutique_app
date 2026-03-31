import 'package:flutter/material.dart';
import '../../Pages/Search/search_screen.dart';
import '../../Pages/admin_screen/admin_orders/admin_orders_screen.dart';
import '../constants/app_strings.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final bool isClickableTitle;
  final bool showSearchIcon;
  final int notificationCount;

  const MyAppBar({
    super.key,
    required this.titleText,
    this.isClickableTitle = false,
    this.showSearchIcon = true,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    void goToHomePage() {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    Widget titleWidget = Text(
      titleText,
      style: TextStyle(color: TextLargColor, fontWeight: FontWeight.bold),
    );

    if (isClickableTitle) {
      titleWidget = InkWell(onTap: goToHomePage, child: titleWidget);
    }

    return AppBar(
      elevation: 0.1,
      backgroundColor: AppBarColor,
      title: titleWidget,
      iconTheme: IconThemeData(color: TextLargColor),
      actions: [
        if (notificationCount > 0)
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminOrdersScreen())
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15, top: 10),
              child: Badge(
                label: Text('$notificationCount'),
                backgroundColor: TextLargColor,
                child: Icon(Icons.notifications, color: TextLargColor),
              ),
            ),
          ),


        if (showSearchIcon)
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
            },
            icon: Icon(Icons.search, color: TextLargColor),
          )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}