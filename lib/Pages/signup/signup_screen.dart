import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../Basic/components/app_components.dart';
import '../../logic/auth_cubit/auth_cubit.dart';
import '../../logic/auth_cubit/auth_state.dart';
import '../my_home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: AppBar(
        title: Text("إنشاء حساب جديد", style: TextStyle(color: TextLargColor)),
        backgroundColor: AppBarColor,
        iconTheme: IconThemeData(color: TextLargColor),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    "أهلاً بك! انضم إلى لمسات",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: TextLargColor
                    ),
                  ),
                  const SizedBox(height: 30),
                  PrimaryTextFormField(
                    label:  "الاسم الكامل",
                    controller: _nameController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.person,
                    onSave: (val) {},
                    onValidate: (val) => (val == null || val.isEmpty) ? "يرجى إدخال الاسم " : null,
                  ),

                  const SizedBox(height: 20),

                  PrimaryTextFormField(
                    label: "البريد الإلكتروني",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    onSave: (val) {},
                    onValidate: (val) => (val == null || val.isEmpty) ? "يرجى إدخال البريد الإلكتروني" : null,
                  ),

                  const SizedBox(height: 20),

                  PrimaryTextFormField(
                    label: "كلمة المرور",
                    controller: _passwordController,
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    onSave: (val) {},
                    onValidate: (val) => (val == null || val.isEmpty) ? "يرجى إدخال كلمة المرور" : null,
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                        context.read<AuthCubit>().register(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          _nameController.text.trim(),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TextLargColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Text(
                      'تسجيل الحساب',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}