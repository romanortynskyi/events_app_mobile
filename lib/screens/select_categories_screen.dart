// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/bloc/auth/auth_bloc.dart' as auth_bloc;
import 'package:events_app_mobile/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectCategoriesScreen extends StatefulWidget {
  const SelectCategoriesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState extends State<SelectCategoriesScreen> {
  List<int?> selectedIds = [];
  List<Category> categories = [];

  void _onInit() {}

  @override
  void initState() {
    super.initState();
    _onInit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<auth_bloc.AuthBloc, auth_bloc.AuthState>(
      builder: (BuildContext context, auth_bloc.AuthState state) {
        return Scaffold(
          body: Column(
            children: [
              const Text('What categories are you interested in?'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: List<Widget>.generate(
                  categories.length,
                  (int index) {
                    return ChoiceChip(
                      label: Text(categories[index].name ?? ''),
                      selected: selectedIds.contains(index),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            selectedIds.add(index);
                          } else {
                            selectedIds.remove(index);
                          }
                        });
                      },
                    );
                  },
                ).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
