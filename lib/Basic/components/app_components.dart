import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_strings.dart';


class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: BeigeFantasy,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: TextLargColor,
        selectionColor: TextLargColor.withOpacity(0.3),
        selectionHandleColor: TextLargColor,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: TextLargColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      useMaterial3: true,
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  void _showCallOptions(BuildContext context, String phoneNumber, String title) {
    final String fullPhoneNumber = '00963$phoneNumber';

    final bool isLandline = !phoneNumber.startsWith('09');

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.call, color: Colors.blue),
                title: Text('الاتصال بـ $title'),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri.parse('tel:$fullPhoneNumber'));
                },
              ),
              if (!isLandline)
                ListTile(
                  leading: Icon(Icons.call, color: Colors.blue),
                  title: Text('مراسلة واتساب ($title)'),
                  onTap: () {
                    Navigator.pop(context);
                    launchUrl(Uri.parse('whatsapp://send?phone=$fullPhoneNumber'), mode: LaunchMode.externalApplication);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color color = TextLargColor;

    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Follow Us:',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.facebook ,color: Colors.blueAccent,),
              title: Text('Facebook'),
              subtitle: Text("لمسات بوتيك _ Lamasat Boutique"),
              onTap: () => launchUrl(Uri.parse('https://www.facebook.com/Lamasat1Boutique')),
            ),
            ListTile(
              leading: Icon(Icons.person_pin,color: color,),
              title: Text('Instagram'),
              subtitle: Text("lamasat_boutique_"),
              onTap: () => launchUrl(Uri.parse('https://www.instagram.com/lamasat_boutique_')),
            ),
            ListTile(
              leading: Icon(Iconsax.whatsapp_bold,color: Colors.green,),
              title: Text('whatsapp 1'),
              subtitle: Text("0930125249"),
              onTap: () => _showCallOptions(context, "930125249", "واتساب 1"),
            ),

            ListTile(
              leading: Icon(Iconsax.whatsapp_outline,color: Colors.green,),
              title: Text('whatsapp 2'),
              subtitle: Text("0981763362"),
              onTap: () => _showCallOptions(context, "981763362", "واتساب 2"),
            ),

            ListTile(
              leading: Icon(Icons.call,color: Colors.red,),
              title: Text('هاتف ارضي'),
              subtitle: Text("0115424096"),
              onTap: () => _showCallOptions(context, "0115424096", "هاتف ارضي"),
            ),
          ],
        )
    );
  }
}

typedef ValidatorFunction = String? Function(String? value);
typedef OnSavedFunction = void Function(String? value);

class PrimaryTextFormField extends StatelessWidget {

  final String label;
  final bool readOnly;
  final IconData? prefixIcon;
  final String? suffixText;
  final OnSavedFunction onSave;
  final ValidatorFunction? onValidate;
  final TextInputType keyboardType;
  final int? maxLines;
  final String? initialName;
  final TextEditingController? controller;
  final bool isPassword;

  const PrimaryTextFormField({
    super.key,
    required this.label,
    required this.onSave,
    this.onValidate,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.initialName,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixText,
    this.controller,
    this.isPassword = false,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialName : null,
      readOnly: readOnly,
      obscureText: isPassword,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: readOnly ? Colors.grey[700] : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffixText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: readOnly ? Colors.grey : TextLargColor) : null,
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white.withOpacity(0.8),
        labelStyle: TextStyle(
          color: TextLargColor,
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppBarColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

      ),
      validator: onValidate,
      onSaved: onSave,
    );
  }
}

class ButtonWithText extends StatelessWidget {
  final Color color;
  final Color colortext;
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const ButtonWithText({
    super.key,
    required this.color,
    required this.label,
    required this.colortext,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: AppBarColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      elevation: 0.2,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: colortext,
              size: 20.0,
            ),
          if (icon != null) SizedBox(width: 8.0),
          Text(
            label,
            textAlign: icon != null ? TextAlign.start : TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              color: colortext,
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
      color: TextLargColor,
      textColor: Colors.white,
      elevation: 0.2,
      child: Text("Buy Now"),
    );
  }
}

class Closebutton extends StatelessWidget {
  const Closebutton({super.key});

  @override
  Widget build(BuildContext context) {
    return  TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text('إغلاق' ,style: TextStyle(color:TextLargColor),),
    );
  }
}

class PrimaryDropdownButtonFormField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;

  const PrimaryDropdownButtonFormField({
    Key? key,
    required this.label,
    required this.items,
    this.value,
    this.validator,
    this.onChanged,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        iconEnabledColor: TextLargColor,
        dropdownColor: BackgroundColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: TextLargColor,fontSize: 15,),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppBarColor, width: 2.0),
          ),
        ),
        value: value,
        items: items,
        validator: validator,
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
  }
}

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategoryId;
  final Function(String?) onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('categories').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('جاري تحميل الأقسام...'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('لا توجد أقسام متاحة. الرجاء إضافة قسم أولاً.');
        }
        List<DropdownMenuItem<String>> categoryItems = [];
        for (var doc in snapshot.data!.docs) {
          categoryItems.add(
            DropdownMenuItem<String>(
              value: doc.id,
              child: Text(doc['name'] ?? 'قسم غير مسمى'),
            ),
          );
        }
        return PrimaryDropdownButtonFormField<String>(
          label: 'القسم التابع',
          value: selectedCategoryId,
          items: categoryItems,
          onChanged: onChanged,
          validator: (value) => value == null ? 'الرجاء اختيار قسم' : null,
        );
      },
    );
  }
}



