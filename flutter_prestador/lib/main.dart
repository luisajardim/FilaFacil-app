import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'presentation/providers/operador_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => OperadorProvider(),
      child: const FilaFacilOperadorApp(),
    ),
  );
}
