// Archivo: lib/presentation/screens/pos_screen.dart
import 'package:flutter/material.dart';
// --- REMOVER PROVIDER IMPORTS (SI YA NO SE USAN) ---
// import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/pos/catalog_widget.dart';
import '../widgets/pos/cart_widget.dart';
// import '../providers/cart_provider.dart';
// import '../providers/auth_provider.dart';
// --- FIN REMOVER IMPORTS ---

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 2, child: CartWidget()),
          Expanded(flex: 3, child: CatalogWidget()),
        ],
      ),
    );
  }
}
