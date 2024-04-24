// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/controllers/add_event_step_three_screen_controller.dart';
import 'package:events_app_mobile/models/category.dart';
import 'package:events_app_mobile/services/category_service.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart'
    as add_event_bloc;

class AddEventStepThreeScreen extends StatefulWidget {
  const AddEventStepThreeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventStepThreeScreenState();
}

class _AddEventStepThreeScreenState extends State<AddEventStepThreeScreen> {
  final TextEditingController _titleTextEditingController =
      TextEditingController();
  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoadingCategories = true;

  List<Category> _categories = [];
  final List<int> _selectedCategoryIds = [];

  late AddEventStepThreeScreenController _addEventStepThreeScreenController;

  void _onTitleChanged(String value) {
    _addEventStepThreeScreenController.onTitleChanged(context, value);
  }

  void _onDescriptionChanged(String value) {
    _addEventStepThreeScreenController.onDescriptionChanged(context, value);
  }

  void _onCategorySelected(int index, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategoryIds.add(index);
      } else {
        _selectedCategoryIds.remove(index);
      }
    });
  }

  void _onContinuePressed() {
    _addEventStepThreeScreenController.onContinuePressed(
      context: context,
      formKey: _formKey,
      selectedCategoryIds: _selectedCategoryIds,
    );
  }

  void _blocListener(BuildContext context, add_event_bloc.AddEventState state) {
    if (state.eventInput.title != _titleTextEditingController.text) {
      _addEventStepThreeScreenController.setTitle(
        _titleTextEditingController,
        state.eventInput.title ?? '',
      );
    }

    if (state.eventInput.description !=
        _descriptionTextEditingController.text) {
      _addEventStepThreeScreenController.setDescription(
        _descriptionTextEditingController,
        state.eventInput.description ?? '',
      );
    }
  }

  @override
  void initState() {
    super.initState();

    CategoryService categoryService = CategoryService();

    _addEventStepThreeScreenController = AddEventStepThreeScreenController(
      categoryService: categoryService,
    );

    _addEventStepThreeScreenController.onInit(
      context: context,
      titleTextEditingController: _titleTextEditingController,
      descriptionTextEditingController: _descriptionTextEditingController,
    );
  }

  void _onDidChangeDependencies(List<Category> categories) {
    setState(() {
      _categories = categories;
      _isLoadingCategories = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _addEventStepThreeScreenController.didChangeDependencies(
      context,
      _onDidChangeDependencies,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<add_event_bloc.AddEventBloc,
        add_event_bloc.AddEventState>(
      listener: (BuildContext context, add_event_bloc.AddEventState state) {
        _blocListener(context, state);
      },
      builder: (BuildContext context, add_event_bloc.AddEventState state) {
        return _isLoadingCategories
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                margin: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      AppTextField(
                        hintText: 'Title',
                        obscureText: false,
                        onChanged: _onTitleChanged,
                        validator:
                            _addEventStepThreeScreenController.titleValidator,
                        controller: _titleTextEditingController,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        hintText: 'Description',
                        obscureText: false,
                        onChanged: _onDescriptionChanged,
                        validator: _addEventStepThreeScreenController
                            .descriptionValidator,
                        controller: _descriptionTextEditingController,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          const Text('Select categories'),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: List<Widget>.generate(
                              _categories.length,
                              (int index) {
                                return ChoiceChip(
                                    label: Text(_categories[index].name ?? ''),
                                    selected:
                                        _selectedCategoryIds.contains(index),
                                    onSelected: (bool selected) {
                                      _onCategorySelected(index, selected);
                                    });
                              },
                            ).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        onPressed: _onContinuePressed,
                        text: 'Continue',
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
