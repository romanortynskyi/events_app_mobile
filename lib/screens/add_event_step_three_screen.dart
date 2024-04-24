// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/models/category.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:events_app_mobile/services/category_service.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart'
    as add_event_bloc;
import 'package:events_app_mobile/graphql/add_event_step_three_screen/add_event_step_three_screen_queries.dart';

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

  void _onTitleChanged(String value) {
    context
        .read<add_event_bloc.AddEventBloc>()
        .add(add_event_bloc.AddEventSetTitleRequested(title: value));
  }

  void _onDescriptionChanged(String value) {
    context.read<add_event_bloc.AddEventBloc>().add(
        add_event_bloc.AddEventSetDescriptionRequested(description: value));
  }

  String? _titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }

    return null;
  }

  String? _descriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }

    if (value.length > 256) {
      return 'Description must be up to 256 characters long';
    }

    return null;
  }

  void _setTitle(String value) {
    _titleTextEditingController.text = value;
    _titleTextEditingController.selection =
        TextSelection.collapsed(offset: value.length);
  }

  void _setDescription(String value) {
    _descriptionTextEditingController.text = value;
    _descriptionTextEditingController.selection =
        TextSelection.collapsed(offset: value.length);
  }

  void _blocListener(BuildContext context, add_event_bloc.AddEventState state) {
    if (state.eventInput.title != _titleTextEditingController.text) {
      _setTitle(state.eventInput.title ?? '');
    }

    if (state.eventInput.description !=
        _descriptionTextEditingController.text) {
      _setDescription(state.eventInput.description ?? '');
    }
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

  void _onContinue() {
    bool isFormValid = _formKey.currentState!.validate();

    if (_selectedCategoryIds.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Select at least one category'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    }

    if (isFormValid) {
      context
          .read<add_event_bloc.AddEventBloc>()
          .add(const add_event_bloc.AddEventIncrementStepRequested());

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  void _onInit() async {
    String defaultTitle =
        context.read<add_event_bloc.AddEventBloc>().state.eventInput.title ??
            '';
    String defaultDescription = context
            .read<add_event_bloc.AddEventBloc>()
            .state
            .eventInput
            .description ??
        '';

    _setTitle(defaultTitle);
    _setDescription(defaultDescription);
  }

  void _didChangeDependencies() async {
    Paginated<Category>? response = await CategoryService().getCategories(
      context: context,
      graphqlDocument: AddEventStepThreeScreenQueries.getCategories,
      shouldReturnAll: true,
    );

    List<Category> categoriesFromBe = response.items ?? [];

    setState(() {
      _categories = categoriesFromBe;
      _isLoadingCategories = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _onInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _didChangeDependencies();
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
                        validator: _titleValidator,
                        controller: _titleTextEditingController,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        hintText: 'Description',
                        obscureText: false,
                        onChanged: _onDescriptionChanged,
                        validator: _descriptionValidator,
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
                        onPressed: _onContinue,
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
