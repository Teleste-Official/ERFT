import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/hover_position.dart';
import 'models/import.dart';
import 'models/polyline.dart';
import 'providers/function.dart';
import 'providers/values.dart';
import 'widgets/draw.dart';
import 'widgets/function.dart';
import 'widgets/graph.dart';
import 'widgets/import.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Import()),
        ChangeNotifierProxyProvider<Import, FunctionProvider>(
          create: (_) => FunctionProvider([]),
          update: (_, Import value, previous) {
            final json = value.json;
            if (json == null) return previous ?? FunctionProvider([]);
            return FunctionProvider.fromJson(value.json!);
          },
        ),
        ChangeNotifierProxyProvider<Import, PolyLine>(
          create: (_) => PolyLine([]),
          update: (_, Import value, previous) {
            final json = value.json;
            if (json == null) return previous ?? PolyLine([]);
            return PolyLine.fromJson(value.json!);
          },
        ),
        ChangeNotifierProvider(create: (_) => HoverPosition()),
        ProxyProvider2<PolyLine, FunctionProvider, ValuesProvider>(
          update: (_, polyLine, funcProvider, __) {
            return ValuesProvider(polyLine, funcProvider.functions);
          },
        )
      ],
      child: MaterialApp(
          theme: ThemeData(
              textSelectionTheme:
                  const TextSelectionThemeData(cursorColor: Colors.black)),
          home: const Scaffold(
            body: MainScreen(),
          )),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Import>();
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: DrawingTool(key: GlobalKey(),
                          imported: provider.json != null
                              ? PolyLine.fromJson(provider.json!).points
                              : null),
                    )),
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: const Graph())),
              )
            ],
          ),
        ),
        const Expanded(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child:
                  Padding(padding: EdgeInsets.all(8.0), child: FunctionInput()),
            ),
            Expanded(
              child:
                  Padding(padding: EdgeInsets.all(8.0), child: ImportScreen()),
            )
          ],
        ))
      ],
    );
  }
}
