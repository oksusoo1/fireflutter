import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class QuickMenuCategories extends StatefulWidget {
  const QuickMenuCategories({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final Function(CategoryModel) onTap;

  @override
  State<QuickMenuCategories> createState() => _QuickMenuCategoriesState();
}

class _QuickMenuCategoriesState extends State<QuickMenuCategories> {
  @override
  void initState() {
    super.initState();
    CategoryService.instance.getCategories().then((value) => setState(() => null));
  }

  @override
  Widget build(BuildContext context) {
    if (CategoryService.instance.categories.length == 0) return SizedBox.shrink();
    return Container(
      height: 24,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          separatorBuilder: (c, i) => SizedBox(width: 8),
          itemCount: CategoryService.instance.categories.length,
          itemBuilder: (c, i) {
            final cat = CategoryService.instance.categories[i];
            if (cat.order == -1) return SizedBox.shrink();

            return GestureDetector(
              onTap: () => widget.onTap(cat),
              child: Container(
                margin: EdgeInsets.only(left: i == 0 ? 8 : 0),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: BoxDecoration(
                  color: getColorFromHex(cat.backgroundColor, Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    cat.title,
                    style: TextStyle(
                      color: getColorFromHex(cat.foregroundColor, Colors.black),
                    ),
                  ),
                ),
              ),
              behavior: HitTestBehavior.opaque,
            );
          }),
    );
  }
}
