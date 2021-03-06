
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

String uuidFromObject(Object object) {
  if (object is Map<String, Object>) {
    final String typeName = object['__typename'] as String;
    final String id = object['id'].toString();
    if (typeName != null && id != null) {
      return <String>[typeName, id].join('/');
    }
  }
  return null;
}

//final GraphQLCache cache = GraphQLCache(store: new HiveStore());
final GraphQLCache cache = GraphQLCache(
  dataIdFromObject: uuidFromObject,
);

ValueNotifier<GraphQLClient> clientFor({
  @required String uri,
  @required String subscriptionUri,
}) {
  final HttpLink httpLink = HttpLink(uri);
  final WebSocketLink webSocketLink = WebSocketLink(
    subscriptionUri,
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(seconds: 30),
    ),
  );

    //link = link.concat(webSocketLink);
  final Link link = Link.split((request) => request.isSubscription, webSocketLink, httpLink);


  return ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: cache,
      link: link,
    ),
  );
}

/// Wraps the root application with the `graphql_flutter` client.
/// We use the cache for all state management.
class GraphqlProvider extends StatelessWidget {
  GraphqlProvider({
    @required this.child,
    @required String uri,
    String subscriptionUri,
  }) : client = clientFor(
    uri: uri,
    subscriptionUri: subscriptionUri,
  );

  final Widget child;
  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}