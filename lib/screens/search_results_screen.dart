// ignore_for_file: use_build_context_synchronously

import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/controllers/search_results_screen_controller.dart';
import 'package:events_app_mobile/graphql/search_results_screen/search_results_screen_queries.dart';
import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:events_app_mobile/screens/event_screen.dart';
import 'package:events_app_mobile/services/event_service.dart';
import 'package:events_app_mobile/utils/month_utils.dart';
import 'package:events_app_mobile/widgets/app_autocomplete.dart';
import 'package:events_app_mobile/widgets/event_card.dart';
import 'package:events_app_mobile/widgets/events_counter.dart';
import 'package:events_app_mobile/widgets/month_tile.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<StatefulWidget> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<Month> _months = [];
  int _skip = 0;
  late ScrollController _scrollController;
  bool _isLoadingEvents = true;
  final FocusNode _focusNode = FocusNode();

  TextEditingController? _textEditingController;

  late EventService _eventService;
  late SearchResultsScreenController _searchResultsScreenController;

  List<Month> _getMonths(List<Event> events) {
    return MonthUtils.getMonths(
      events: events,
      prevMonths: _months,
    ).toList();
  }

  Future<void> _searchEvents(FetchPolicy fetchPolicy) async {
    List<Event> events = await _searchResultsScreenController.searchEvents(
      context: context,
      graphqlDocument: SearchResultsScreenQueries.searchEvents,
      query: widget.query,
      skip: _skip,
      limit: 10,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    List<Month> months = _getMonths(events);

    if (mounted) {
      setState(() {
        _months = months;
        _skip += 10;
        _isLoadingEvents = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _textEditingController = TextEditingController(text: widget.query);

    _eventService = EventService();

    _searchResultsScreenController =
        SearchResultsScreenController(eventService: _eventService);

    _scrollController.addListener(() async {
      var nextPageTrigger = 0.8 * _scrollController.position.maxScrollExtent;
      if (_scrollController.position.pixels >= nextPageTrigger &&
          !_isLoadingEvents) {
        _searchEvents(FetchPolicy.networkOnly);
      }
    });
  }

  @override
  void didChangeDependencies() {
    _searchEvents(FetchPolicy.cacheFirst);

    super.didChangeDependencies();
  }

  void onClearSearch() {
    _textEditingController?.clear();
  }

  void onEventPressed(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventScreen(id: event.id ?? -1)),
    );
  }

  Future<void> onRefresh(BuildContext context) async {
    return _searchEvents(FetchPolicy.networkOnly);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  Future<Iterable<String>> optionsBuilder(TextEditingValue textEditingValue) {
    return _searchResultsScreenController.autocompleteEventsOptionsBuilder(
      context: context,
      graphqlDocument: SearchResultsScreenQueries.autocompleteEvents,
      query: textEditingValue.text,
      skip: 0,
      limit: 10,
      fetchPolicy: FetchPolicy.networkOnly,
    );
  }

  Widget optionsViewBuilder(
    BuildContext context,
    onAutoCompleteSelect,
    Iterable<String> options,
  ) {
    return _searchResultsScreenController.autocompleteEventsOptionsViewBuilder(
      context: context,
      onAutoCompleteSelect: onAutoCompleteSelect,
      options: options,
      scrollController: _scrollController,
    );
  }

  void onAutocompleteSelected(BuildContext context, String text) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsScreen(query: text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade200, LightThemeColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: AppAutocomplete(
          textEditingController:
              _textEditingController ?? TextEditingController(),
          textInputAction: TextInputAction.search,
          focusNode: _focusNode,
          backgroundColor: Colors.transparent,
          enabledBorderColor: Colors.transparent,
          focusedBorderColor: Colors.transparent,
          placeholderColor: Colors.white,
          hintText: 'Search for events...',
          optionsBuilder: optionsBuilder,
          optionsViewBuilder: optionsViewBuilder,
          onSelected: (String selection) {
            onAutocompleteSelected(context, selection);
          },
          onSubmitted: (String selection) {
            onAutocompleteSelected(context, selection);
          },
          maxLines: 1,
        ),
      ),
      body: _isLoadingEvents
          ? Center(
              child: CircularProgressIndicator(
                color: LightThemeColors.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: () => onRefresh(context),
              child: Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    final month = _months[index];

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MonthTile(text: month.name),
                            EventsCounter(count: month.events.length),
                          ],
                        ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: month.events.length,
                          itemBuilder: (context, eventIndex) {
                            Event event = month.events[eventIndex];

                            return TouchableOpacity(
                              onTap: () => onEventPressed(context, event),
                              child: EventCard(event: event),
                            );
                          },
                        ).build(context),
                      ],
                    );
                  },
                ).build(context),
              )),
    );
  }
}
