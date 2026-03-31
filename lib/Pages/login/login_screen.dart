import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../Basic/appbar/appbar.dart';
import '../../Basic/components/app_components.dart';
import '../../logic/auth_cubit/auth_cubit.dart';
import '../../logic/auth_cubit/auth_state.dart';
import '../my_home/home_screen.dart';
import '../signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(
        titleText:' تسجيل الدخول',
        showSearchIcon: false,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
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
                    "مرحباً بك ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: TextLargColor,
                    ),
                  ),
                  const SizedBox(height: 30),
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
                      context.read<AuthCubit>().login(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TextLargColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("أو", style: TextStyle(color: Colors.grey[600])),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ]),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: state is AuthLoading
                        ? null
                        : () => context.read<AuthCubit>().loginWithGoogle(),
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.blue),
                    ),
                    label: const Text(
                      "تسجيل الدخول عبر Google",
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      elevation: 1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      "ليس لديك حساب؟ إنشاء حساب جديد",
                      style: TextStyle(
                        color: TextLargColor,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
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