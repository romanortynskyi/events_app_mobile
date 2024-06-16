// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:events_app_mobile/bloc/add_event/add_event_bloc.dart';
import 'package:events_app_mobile/consts/enums/route_name.dart';
import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/controllers/add_event_screen_controller.dart';
import 'package:events_app_mobile/graphql/mutations/add_event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/screens/add_event_step_four_screen.dart';
import 'package:events_app_mobile/screens/add_event_step_one_screen.dart';
import 'package:events_app_mobile/screens/add_event_step_three_screen.dart';
import 'package:events_app_mobile/screens/add_event_step_two_screen.dart';
import 'package:events_app_mobile/screens/map_screen.dart';
import 'package:events_app_mobile/widgets/app_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  double _ticketPrice = 1.0;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  File? _imageFile;
  String? _placeId;

  late AddEventScreenController _addEventScreenController;

  List<String> titles = [
    'Vertical Image',
    'Horizontal Image',
    'Add Event Details',
    'Choose Location',
    'Five',
  ];

  List<Widget> steps = [
    const AddEventStepOneScreen(),
    const AddEventStepTwoScreen(),
    const AddEventStepThreeScreen(),
    const AddEventStepFourScreen(),
    Text('five'),
  ];

  void onSelectLocationPressed() async {
    if (_formKey.currentState!.validate()) {
      Geolocation location = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );

      if (!mounted) return;

      setState(() {
        _placeId = location.placeId;
      });
    }
  }

  String? ticketPriceValidator(String? valueString) {
    if (valueString == null || valueString.isEmpty) {
      return 'Please enter a ticket price';
    }

    double value = double.parse(valueString);

    if (value < 1) {
      return 'Ticket price must be at least 1';
    }

    return null;
  }

  void onTicketPriceChanged(String value) {
    setState(() => _ticketPrice = double.parse(value));
  }

  void onShowStartDatePicker() async {
    DateTime now = DateTime.now();

    DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year, now.month, now.day + 30),
    );

    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (startDate != null && startTime != null) {
      DateTime startDateTime = DateTime(startDate.year, startDate.month,
          startDate.day, startTime.hour, startTime.minute);

      setState(() {
        _startDateTime = startDateTime;
      });
    }
  }

  void onShowEndDatePicker() async {
    DateTime now = DateTime.now();

    DateTime? endDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year, now.month, now.day + 30),
    );

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (endDate != null && endTime != null) {
      DateTime endDateTime = DateTime(endDate.year, endDate.month, endDate.day,
          endTime.hour, endTime.minute);

      setState(() {
        _endDateTime = endDateTime;
      });
    }
  }

  void onSubmitPressed() async {
    if (_imageFile != null) {
      var byteData = _imageFile?.readAsBytesSync();

      String? mimeType = lookupMimeType(_imageFile?.path ?? '') ?? '';
      String extension = path.extension(_imageFile?.path ?? '.jpg');

      var multipartImageFile = MultipartFile.fromBytes(
        'photo',
        byteData as List<int>,
        filename: '${DateTime.now()}.$extension',
        contentType: MediaType(
          mimeType.split('/')[0],
          mimeType.split('/')[1],
        ),
      );

      GraphQLClient client = GraphQLProvider.of(context).value;

      await client.mutate(MutationOptions(
        document: gql(addEvent),
        variables: {
          'input': {
            'title': _title,
            'description': _description,
            'ticketPrice': _ticketPrice,
            'startDate': _startDateTime?.toIso8601String(),
            'endDate': _endDateTime?.toIso8601String(),
            'image': multipartImageFile,
            'placeId': _placeId,
          },
        },
      ));

      Navigator.of(context).popUntil(ModalRoute.withName(RouteName.main.value));
    }
  }

  void _onBackPressed() {
    context.read<AddEventBloc>().add(const AddEventDecrementStepRequested());
  }

  void _onContinue() {
    _addEventScreenController.onContinue(context);
  }

  void _onInit() {
    _addEventScreenController = AddEventScreenController();
  }

  @override
  void initState() {
    super.initState();

    _onInit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddEventBloc, AddEventState>(
      builder: (BuildContext context, AddEventState state) {
        int stepIndex = state.step;
        Widget step = steps[state.step];
        double progressBarValue = ((state.step + 1) / steps.length) * 100;
        String title = titles[state.step];

        return Scaffold(
            backgroundColor: LightThemeColors.background,
            floatingActionButton: stepIndex == 3
                ? FloatingActionButton(
                    onPressed: _onContinue,
                    backgroundColor: LightThemeColors.primary,
                    child: Icon(
                      Icons.arrow_forward,
                      color: LightThemeColors.white,
                    ),
                  )
                : null,
            appBar: AppBar(
              title: Text(title),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(5),
                child: AppProgressBar(
                  duration: 300,
                  color: LightThemeColors.primary,
                  height: 5,
                  radius: 0,
                  padding: 0,
                  value: progressBarValue,
                ),
              ),
              centerTitle: true,
              leading: state.step > 0
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                      onPressed: _onBackPressed,
                    )
                  : null,
            ),
            body: SingleChildScrollView(
              child: step,
            ));
      },
    );
  }
}
