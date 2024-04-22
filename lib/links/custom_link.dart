import 'dart:async';

import 'package:graphql_flutter/graphql_flutter.dart';

typedef GetHeaders = Future<Map<String, String>> Function();

class CustomLink extends Link {
  GetHeaders getHeaders;

  CustomLink({
    required this.getHeaders,
  }) : super();

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    Map<String, String> addedHeaders = await getHeaders();

    final Request req = request.updateContextEntry<HttpLinkHeaders>(
      (HttpLinkHeaders? headers) => HttpLinkHeaders(
        headers: <String, String>{
          ...headers?.headers ?? <String, String>{},
          ...addedHeaders,
        },
      ),
    );

    yield* forward!(req);
  }
}
