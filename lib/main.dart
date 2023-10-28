import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/hover_position.dart';
import 'providers/import.dart';
import 'models/polyline.dart';
import 'providers/function.dart';
import 'providers/values.dart';
import 'widgets/draw.dart';
import 'widgets/function.dart';
import 'widgets/graph.dart';
import 'widgets/import.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Import()),

        // Update [FunctionProvider] when [Import] has changed.

        ChangeNotifierProxyProvider<Import, FunctionProvider>(
          create: (_) => FunctionProvider([]),
          update: (_, Import import, previous) {
            return import.functions ?? previous ?? FunctionProvider([]);
          },
        ),

        // Update [PolyLine] when [Import] has changed.

        ChangeNotifierProxyProvider<Import, PolyLine>(
          create: (_) => PolyLine([]),
          update: (_, Import import, previous) {
            return import.line ?? previous ?? PolyLine([]);
          },
        ),
        ChangeNotifierProvider(create: (_) => HoverPosition()),

        // Update [ValueProvider] when [PolyLine] or [FunctionProvider] has changed.

        ProxyProvider2<PolyLine, FunctionProvider, ValueProvider>(
          update: (_, polyLine, funcProvider, __) {
            return ValueProvider(polyLine, funcProvider.functions);
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
    // re-render on import
    final provider = context.watch<Import>();
    return Column(
      children: [
        Expanded(
          // [DrawingTool] and [Graph] twice the height of [FunctionInput] and [ImportScreen]
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: DrawingTool(
                          // key needed to re-render properly
                          key: GlobalKey(),
                          imported: provider.line?.points),
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
