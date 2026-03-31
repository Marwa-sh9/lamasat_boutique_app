import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Basic/constants/app_strings.dart';
import '../../sevices/cloudinary_constants.dart';
import '../Product/products_screen.dart';

class HorizontalList extends StatelessWidget {
  const HorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppBarColor));
        }
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('لا توجد أقسام مضافة بعد.'));
        }

        final categories = snapshot.data!.docs;
        return Container(
          height: 120.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryDoc = categories[index];
              final categoryData = categoryDoc.data() as Map<String, dynamic>?;

              return Category(
                image_location: categoryData?['image_url']?.toString() ?? '',
                image_caption: categoryData?['name']?.toString() ?? 'غير مسمى',
                categoryId: categoryDoc.id,
              );
            },
          ),
        );
      },
    );
  }
}

class Category extends StatelessWidget {
  final String image_location;
  final String image_caption;
  final String categoryId;

  const Category({
    super.key,
    required this.image_location,
    required this.image_caption,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyProducts(
                categoryId: categoryId,
                titleText: 'قسم $image_caption',
                showAppBar: true,
              ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: ReusableImageWidget(
                url: image_location,
                size: 70.0,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              child: Text(
                image_caption,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}