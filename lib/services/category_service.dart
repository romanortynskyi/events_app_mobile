import 'package:events_app_mobile/models/category.dart';
import 'package:events_app_mobile/models/paginated.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CategoryService {
  Future<Paginated<Category>> getCategories({
    required BuildContext context,
    required String graphqlDocument,
    int? skip,
    int? limit,
    bool shouldReturnAll = true,
    FetchPolicy fetchPolicy = FetchPolicy.cacheFirst,
  }) async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    var response = await client.query(QueryOptions(
      document: gql(graphqlDocument),
      variables: {
        'input': {
          'skip': skip,
          'limit': limit,
          'shouldReturnAll': shouldReturnAll,
        },
      },
    ));

    if (response.hasException) {
      throw Exception(response.exception!.graphqlErrors[0].message);
    }

    List<Category> categories = response.data!['getCategories']['items']
        .map((map) => Category.create().fromMap(map))
        .toList()
        .cast<Category>();
    int totalPagesCount =
        response.data!['getCategories']['totalPagesCount'] ?? 1;

    return Paginated<Category>(
        items: categories, totalPagesCount: totalPagesCount);
  }
}
