// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/graphql/mutations/add_event.dart';
import 'package:events_app_mobile/models/geolocation.dart';
import 'package:events_app_mobile/screens/main_screen.dart';
import 'package:events_app_mobile/screens/map_screen.dart';
import 'package:events_app_mobile/widgets/app_button.dart';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

String getGeolocationByCoords = """
  query GET_GEOLOCATION_BY_COORDS(\$latitude: Float!, \$longitude: Float!) {
    getGeolocationByCoords(latitude: \$latitude, longitude: \$longitude) {
      placeId
    }
  }
""";

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

    if (value.length < 6) {
      return 'Description must be at least 6 characters long';
    }

    if (value.length > 256) {
      return 'Description must be up to 256 characters long';
    }

    return null;
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

  void onTitleChanged(String value) {
    setState(() => _title = value);
  }

  void onDescriptionChanged(String value) {
    setState(() => _description = value);
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

  void onSelectImagePressed() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);

      setState(() {
        _imageFile = file;
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

      var response = await client.mutate(MutationOptions(
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Add Event',
                style: TextStyle(
                  color: LightThemeColors.text,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                validator: titleValidator,
                hintText: 'Title',
                obscureText: false,
                onChanged: onTitleChanged,
              ),
              const SizedBox(height: 10),
              AppTextField(
                validator: descriptionValidator,
                hintText: 'Description',
                obscureText: false,
                onChanged: onDescriptionChanged,
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
              const SizedBox(height: 10),
              _startDateTime == null
                  ? AppButton(
                      onPressed: onShowStartDatePicker,
                      text: 'Select Start Date',
                    )
                  : Row(
                      children: [
                        Text(
                          DateFormat('EEE, MMM DD yyyy hh:mm')
                              .format(_startDateTime ?? DateTime.now()),
                        ),
                        IconButton(
                            onPressed: onShowStartDatePicker,
                            icon: const Icon(Icons.edit))
                      ],
                    ),
              const SizedBox(height: 10),
              _endDateTime == null
                  ? AppButton(
                      onPressed: onShowEndDatePicker,
                      text: 'Select End Date',
                    )
                  : Row(
                      children: [
                        Text(
                          DateFormat('EEE, MMM DD yyyy hh:mm')
                              .format(_endDateTime ?? DateTime.now()),
                        ),
                        IconButton(
                            onPressed: onShowEndDatePicker,
                            icon: const Icon(Icons.edit))
                      ],
                    ),
              const SizedBox(height: 10),
              AppTextField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: ticketPriceValidator,
                hintText: 'Ticket Price',
                obscureText: false,
                onChanged: onTicketPriceChanged,
              ),
              const SizedBox(height: 10),
              AppButton(onPressed: onSelectImagePressed, text: 'Select Image'),
              const SizedBox(height: 10),
              _imageFile?.path == null
                  ? Container()
                  : Text(_imageFile?.path ?? ''),
              AppButton(
                onPressed: onSelectLocationPressed,
                text: 'Select Location',
              ),
              const SizedBox(height: 10),
              AppButton(
                onPressed: onSubmitPressed,
                text: 'Submit',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
