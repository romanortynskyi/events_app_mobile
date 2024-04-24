// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/graphql/add_event_step_three_screen/add_event_step_three_screen_queries.dart';
import 'package:events_app_mobile/models/category.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:events_app_mobile/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart'
    as add_event_bloc;
import 'package:graphql_flutter/graphql_flutter.dart';

class AddEventStepThreeScreenController {
  final CategoryService categoryService;

  const AddEventStepThreeScreenController({required this.categoryService});

  void onTitleChanged(BuildContext context, String value) {
    context
        .read<add_event_bloc.AddEventBloc>()
        .add(add_event_bloc.AddEventSetTitleRequested(title: value));
  }

  void onDescriptionChanged(BuildContext context, String value) {
    context.read<add_event_bloc.AddEventBloc>().add(
        add_event_bloc.AddEventSetDescriptionRequested(description: value));
  }

  String? titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }

    return null;
  }

  String? descriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }

    if (value.length > 256) {
      return 'Description must be up to 256 characters long';
    }

    return null;
  }

  void setTitle(TextEditingController textEditingController, String value) {
    textEditingController.text = value;
    textEditingController.selection =
        TextSelection.collapsed(offset: value.length);
  }

  void setDescription(
      TextEditingController textEditingController, String value) {
    textEditingController.text = value;
    textEditingController.selection =
        TextSelection.collapsed(offset: value.length);
  }

  void onContinuePressed({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required List<int> selectedCategoryIds,
  }) {
    bool isFormValid = formKey.currentState!.validate();

    if (selectedCategoryIds.isEmpty) {
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

  void onInit({
    required BuildContext context,
    required TextEditingController titleTextEditingController,
    required TextEditingController descriptionTextEditingController,
  }) async {
    String defaultTitle =
        context.read<add_event_bloc.AddEventBloc>().state.eventInput.title ??
            '';
    String defaultDescription = context
            .read<add_event_bloc.AddEventBloc>()
            .state
            .eventInput
            .description ??
        '';

    setTitle(titleTextEditingController, defaultTitle);
    setDescription(descriptionTextEditingController, defaultDescription);
  }

  void didChangeDependencies(
    BuildContext context,
    Function? callback,
  ) async {
    Paginated<Category>? response = await categoryService.getCategories(
      context: context,
      graphqlDocument: AddEventStepThreeScreenQueries.getCategories,
      shouldReturnAll: true,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    List<Category> categories = response.items ?? [];

    callback!(categories);
  }
}
