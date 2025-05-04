import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/icons_list.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.onChanged});
  final ValueChanged<String?> onChanged;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  String currentCategory = "All";
  List<Map<String, dynamic>> categorylist = [];
  final scrollController = ScrollController();
  
  var appIcons = AppIcons();
  var addCat = {"name": "All", "icon": FontAwesomeIcons.cartPlus};

  @override
  void initState() {
    super.initState();
    setState(() {
      categorylist = appIcons.homeExpensesCategories;
      categorylist.insert(0, addCat);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 46,
        child: ListView.builder(
          controller: scrollController,
          itemCount: categorylist.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemBuilder: (context, index) {
            var data = categorylist[index];
            bool isSelected = currentCategory == data['name'];
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    currentCategory = data['name'];
                    widget.onChanged(data['name']);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkGreen : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        data['icon'],
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.darkGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}