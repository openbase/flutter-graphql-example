import 'package:flutter/material.dart';
import 'package:flutter_graphql_example/graphql_api.dart';
import 'package:flutter_graphql_example/graphql_provide.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphqlProvider(
        uri: 'http://demo.basecubeone.org:13781/graphql',
        subscriptionUri: 'ws://demo.basecubeone.org:13781/subscriptions',
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
            // This makes the visual density adapt to the platform that you run
            // the app on. For desktop platforms, the controls will be smaller and
            // closer together (more dense) than on mobile platforms.
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MyHomePage(title: 'Flutter Demo Home Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Subscription(
            options: SubscriptionOptions(
              document: PowerStateSubscriptionSubscription().document,
              variables: {"id": "66b5b93f-9f33-4d7d-8e61-5951a22f5483"},
            ),
            builder: (result) {
              print('New result?' + result.toString());

              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.isLoading) {
                return Center(
                  child: const CircularProgressIndicator(),
                );
              }

              //result.data
              //final unitConfigs =
                  //FilterByTypeViaSubscription$Subscription.fromJson(result.data).unitConfigs;

              // ResultAccumulator is a provided helper widget for collating subscription results.
              // careful though! It is stateful and will discard your results if the state is disposed
              return ResultAccumulator.appendUniqueEntries(
                latest: result.data,
                builder: (context, {results}) => createSubscriptionWidget(results)
              );
            },
          )),
          Expanded(
            child: Query(
              options: QueryOptions(
                  document: FilterByTypeQuery().document,
                  variables: {"alias": "ColorableLight-17"}),
              builder: (
                QueryResult result, {
                Future<QueryResult> Function() refetch,
                FetchMore fetchMore,
              }) {
                if (result.hasException) {
                  return Text(result.exception.toString());
                }

                if (result.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final unitConfigs =
                    FilterByType$QueryType.fromJson(result.data).unitConfigs;

                return ListView.builder(
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: Icon(Icons.card_travel),
                      title: Text(unitConfigs[index].labelString),
                      subtitle: Text(unitConfigs[index].id),
                    );
                  },
                  itemCount: unitConfigs.length,
                );
              },
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.contain, // otherwise the logo will be tiny
              child: const FlutterLogo(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

ListView createSubscriptionWidget(List<Map<String, dynamic>> results) {
  print('Results.length' + results.length.toString());
  final List<PowerStateSubscription$Subscription$OpenbaseTypeDomoticUnitUnitData> units = [];
  for (var unit in results.map((e) => PowerStateSubscription$Subscription.fromJson(e).units)) {
      units.add(unit);
  }
  print(units.length);

  return ListView.builder(
      itemBuilder: (_, index) {
    return ListTile(
      leading: Icon(Icons.card_travel),
      title: Text((units[index].powerState != null) ? units[index].powerState.value.toString() : 'Unknown'),
      subtitle: Text((units[index].id != null) ? units[index].id : 'ID?'),
    );
  },
  itemCount: units.length,
  );
}
