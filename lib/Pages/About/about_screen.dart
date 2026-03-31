import 'package:flutter/material.dart';
import '../../Basic/appbar/appbar.dart';
import '../../Basic/components/app_components.dart';
import '../../Basic/constants/app_strings.dart';


class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: BackgroundColor,
      appBar: MyAppBar(
          titleText:'حول لمسات',
        showSearchIcon: false,
      ),
        body:
        SingleChildScrollView(
          child:Column(
            children: [
              ImageSection(
                image: 'images/card.png',
              ),
              TitleSection(
                name: 'لمسات بوتيك',
                location: 'العنوان : دمشق _ المنطقة الصناعية',
              ),
              TextSection(
                description:
                'نحن خبرة 20 سنة في الخياطة والتفصيل '
                'لمسات تعمل على تفصيل اي فستان او بدلات عرائس او قطع السبورات '
                    'و تأجير وبيع الفساتين وايضا تفصيل اجار لبسة اولى'
                    'ويمكن تصليح القطع '
                    'نعمل على ادق التفاصيل والجودة الممتازة'

              ),
              TextOurWork(),
              ButtonSection(),
            ],
          ),
        ),
    );
  }
}

class TitleSection extends StatelessWidget {
  final String name;
  final String location;

  const TitleSection({super.key,
    required this.name,
    required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(name,
                    style: TextStyle(
                      color: TextLargColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
                Text(location,
                  style: TextStyle(color: Colors.grey[500],fontSize: 15),),
              ],
            ),
          ),
          Icon(Icons.star ,color: TextLargColor,),
          const Text('41'),
        ],
      ),
    );
  }
}


class TextSection extends StatelessWidget {
  const TextSection({
    super.key,
    required this.description
  });
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(description, softWrap: true),
    );
  }
}


class ImageSection extends StatelessWidget {
  const ImageSection({
    super.key,
    required this.image
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
        image,
        width: 800,
        height: 240,
        fit: BoxFit.contain);
  }
}


class TextOurWork extends StatelessWidget {

  const TextOurWork({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ما ننتج ',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.check , color: TextLargColor,),
              title: Text('تفصيل وخياطة فساتين اعراس وسهرة وسبورات'),
            ),
            ListTile(
              leading: Icon(Icons.check, color: TextLargColor,),
              title: Text('تأجير وبيع'),
            ),
            ListTile(
              leading: Icon(Icons.check, color: TextLargColor,),
              title: Text('تفصيل واجار لبسة اولى'),
            ),
            ListTile(
              leading: Icon(Icons.check, color: TextLargColor,),
              title: Text('تعديل اي فستان'),
            ),
          ],
        )
    );
  }
}

