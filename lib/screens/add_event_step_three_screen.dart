// ignore_for_file: use_build_context_synchronously

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

    if (value.length < 6) {
      return 'Description must be at least 6 characters long';
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

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<add_event_bloc.AddEventBloc,
        add_event_bloc.AddEventState>(
      listener: (BuildContext context, add_event_bloc.AddEventState state) {
        _blocListener(context, state);
      },
      builder: (BuildContext context, add_event_bloc.AddEventState state) {
        return Container(
          margin: const EdgeInsets.all(20),
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
              AppTextField(
                hintText: 'Description',
                obscureText: false,
                onChanged: _onDescriptionChanged,
                validator: _descriptionValidator,
                controller: _descriptionTextEditingController,
              ),
              const SizedBox(height: 20),
              AppButton(
                onPressed: () {},
                text: 'Continue',
              ),
            ],
          ),
        );
      },
    );
  }
}
