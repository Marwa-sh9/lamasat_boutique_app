import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lamasatboutiquemyapp/sevices/firebaseoptions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Basic/components/app_components.dart';
import 'Pages/login/login_screen.dart';
import 'Pages/my_home/home_screen.dart';
import 'logic/auth_cubit/auth_cubit.dart';
import 'logic/cart_cubit/cart_cubit.dart';
import 'logic/category_cubit/category_cubit.dart';
import 'logic/favorite_cubit/favorite_cubit.dart';
import 'logic/product_cubit/product_cubit.dart';
import 'logic/search_cubit/search_cubit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String envPath = kIsWeb ? ".env" : "assets/.env";
  await dotenv.load(fileName: envPath);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => CategoryCubit()),
        BlocProvider(create: (context) => ProductCubit()),
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(),
        ),
        BlocProvider<CartCubit>(
          create: (context) => CartCubit()..fetchCart(),
        ),
        BlocProvider<FavoriteCubit>(
          create: (context) => FavoriteCubit()..fetchFavorites(),
        ),
      ],
      child:  MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return const HomePage();
            }
            return const LoginScreen();
          },
        ),
      ),
    ),
  );
}