import 'package:example/services/defines.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  @override
  void initState() {
    super.initState();
    CategoryService.instance.getCategories().then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (CategoryService.instance.categories.isEmpty) return SizedBox.shrink();
    return SizedBox(
      height: 22,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          separatorBuilder: (c, i) => spaceXs,
          itemCount: CategoryService.instance.categories.length,
          itemBuilder: (c, i) {
            final cat = CategoryService.instance.categories[i];
            if (cat.order == -1) return SizedBox.shrink();

            return Container(
              color: getColorFromHex(cat.backgroundColor, Colors.grey.shade100),
              child: Text(
                '${cat.title} ',
                style: TextStyle(color: getColorFromHex(cat.foregroundColor, Colors.black)),
              ),
            );
          }),
    );
  }
}
