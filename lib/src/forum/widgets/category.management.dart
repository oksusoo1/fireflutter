import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryManagement extends StatefulWidget {
  CategoryManagement({
    Key? key,
    this.padding = const EdgeInsets.all(0),
    required this.onError,
    required this.onCreate,
  }) : super(key: key);

  final EdgeInsets padding;
  final Function(dynamic) onError;
  final Function() onCreate;

  @override
  State<CategoryManagement> createState() => _CategoryManagementState();
}

class _CategoryManagementState extends State<CategoryManagement>
    with FirestoreMixin {
  final category = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(padding: widget.padding, children: [
      const Text('Category menagement'),
      const Text('Create a category'),
      const Divider(),
      const Text('Category.\nEx) qna, discussion, job'),
      TextField(controller: category),
      const Divider(),
      const Text('Title'),
      TextField(controller: title),
      const Divider(),
      const Text('Description'),
      TextField(controller: description),
      ElevatedButton(
        onPressed: () async {
          try {
            await CategoryModel.create(
              category: category.text,
              title: title.text,
              description: description.text,
            );
            title.text = '';
            description.text = '';
            category.text = '';
            setState(() {});
            widget.onCreate();
          } catch (e) {
            widget.onError(e);
          }
        },
        child: const Text('CREATE CATEGORY'),
      ),
      Text('Regulations'),
      Text(
          'If order is set to -1, then the category should not be displayed on menu.'),
      SizedBox(height: 16),
      FirestoreListView<Map<String, dynamic>>(
        shrinkWrap: true,
        primary: false,
        query: categoryCol.orderBy('order', descending: true)
            as Query<Map<String, dynamic>>,
        itemBuilder: (context, snapshot) {
          CategoryModel cat =
              CategoryModel.fromJson(snapshot.data(), snapshot.id);

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.0),
                          color: getColorFromHex(
                              cat.backgroundColor, Colors.grey.shade300),
                          child: Text(
                            cat.title,
                            style: TextStyle(
                              color: getColorFromHex(
                                  cat.foregroundColor, Colors.black),
                            ),
                          ),
                        ),
                        Text(
                          "[${cat.id}] (${cat.order}) ${cat.description}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => updateColor('foregroundColor', cat),
                        icon: Icon(Icons.colorize_rounded),
                      ),
                      IconButton(
                        onPressed: () => updateColor('backgroundColor', cat),
                        icon: Icon(Icons.color_lens),
                      ),
                      IconButton(
                          onPressed: () {
                            String selected = cat.categoryGroup;
                            showDialog(
                                context: context,
                                builder: (c) {
                                  /// Category update
                                  return AlertDialog(
                                    title: Text('Update [${cat.id}] category'),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Automatic save after edit',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Divider(),
                                        Text('Title'),
                                        TextField(
                                          controller: TextEditingController()
                                            ..text = cat.title,
                                          onChanged: (s) => bounce(
                                            't',
                                            500,
                                            (x) => cat
                                                .update('title', s)
                                                .catchError(widget.onError),
                                          ),
                                        ),
                                        Divider(),
                                        Text('Description'),
                                        TextField(
                                          controller: TextEditingController()
                                            ..text = cat.description,
                                          onChanged: (s) => bounce(
                                            'd',
                                            500,
                                            (x) => cat
                                                .update('description', s)
                                                .catchError(widget.onError),
                                          ),
                                        ),
                                        Divider(),
                                        Text('Priority of order list'),
                                        TextField(
                                          controller: TextEditingController()
                                            ..text = cat.order.toString(),
                                          // keyboardType: TextInputT,
                                          onChanged: (s) => bounce(
                                            'p',
                                            400,
                                            (x) => cat
                                                .update('order',
                                                    s == '' ? 0 : int.parse(s))
                                                .catchError(widget.onError),
                                          ),
                                        ),

                                        Text('Category Menu'),

                                        /// Category menu select
                                        StatefulBuilder(
                                          builder: ((context, setState) {
                                            return FutureBuilder<
                                                DocumentSnapshot>(
                                              future: forumSettingDoc.get(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  Map data = snapshot.data
                                                          ?.data()
                                                      as Map<String, dynamic>;
                                                  String categoryGroup =
                                                      data['categoryGroup'];

                                                  return DropdownButton<String>(
                                                    value: selected,
                                                    items: [
                                                      DropdownMenuItem(
                                                        child: Text(
                                                            'Select category menu'),
                                                        value: '',
                                                      ),
                                                      ...categoryGroup
                                                          .split(',')
                                                          .map((name) =>
                                                              DropdownMenuItem(
                                                                  child: Text(
                                                                      name),
                                                                  value: name))
                                                          .toList(),
                                                    ],
                                                    onChanged: (v) {
                                                      setState(() {
                                                        selected = v ?? '';
                                                      });
                                                      cat
                                                          .update(
                                                              'categoryGroup',
                                                              v ?? '')
                                                          .catchError(
                                                              widget.onError);
                                                    },
                                                  );
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              },
                                            );
                                          }),
                                        ),

                                        ///
                                        ///
                                        /// Point
                                        Text(
                                            'Point on create post. It can be negative value.'),
                                        TextField(
                                          controller: TextEditingController()
                                            ..text = cat.point.toString(),
                                          // keyboardType: TextInputT,
                                          onChanged: (s) => bounce(
                                            'point',
                                            400,
                                            (x) => cat
                                                .update('point',
                                                    s == '' ? 0 : int.parse(s))
                                                .catchError(widget.onError),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Close'),
                                      ),
                                    ],
                                  );
                                });
                          },
                          icon: Icon(Icons.edit)),
                      IconButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Delete'),
                                content: Text(
                                  'Do you want to delete [ ${cat.title} ] category?',
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('No')),
                                  TextButton(
                                    onPressed: () {
                                      cat.delete();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
            ],
          );
        },
      ),
    ]);
  }

  updateColor(String field, CategoryModel cat) {
    Color selectedColor = getColorFromHex(
        field == 'backgroundColor' ? cat.backgroundColor : cat.foregroundColor);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: getColorFromHex(field == 'backgroundColor'
                ? cat.backgroundColor
                : cat.foregroundColor),
            onColorChanged: (color) => selectedColor = color,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              // update color value into firestore
              if (field == 'backgroundColor') {
                cat.updateBackgroundColor(
                    selectedColor.value.toRadixString(16));
              } else {
                cat.updateForegroundColor(
                    selectedColor.value.toRadixString(16));
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
