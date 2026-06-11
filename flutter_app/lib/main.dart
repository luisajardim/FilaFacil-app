import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'presentation/providers/fila_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FilaProvider(),
      child: const FilaFacilApp(),
    ),
  );
}
