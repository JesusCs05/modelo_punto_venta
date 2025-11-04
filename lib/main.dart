// Archivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:isar/isar.dart'; // 1. Import Isar
import 'package:path_provider/path_provider.dart';
// 2. Import ALL your collection schemas
import 'data/collections/rol.dart';
import 'data/collections/usuario.dart';
import 'data/collections/tipo_producto.dart';
import 'data/collections/producto.dart';
import 'data/collections/venta.dart';
import 'data/collections/venta_detalle.dart';
import 'data/collections/turno.dart';
import 'data/collections/movimiento_inventario.dart';
// --- End Collection Imports ---
import 'presentation/screens/login_screen.dart';
import 'presentation/theme/app_colors.dart';
import 'utils/password_hasher.dart'; // Import the new hasher
import 'package:provider/provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/turno_provider.dart';
import 'presentation/providers/cart_provider.dart';

// 3. Global Isar instance (consider using Provider/GetIt later)
late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [
      // 5. Pass all schemas here
      RolSchema,
      UsuarioSchema,
      TipoProductoSchema,
      ProductoSchema,
      VentaSchema,
      VentaDetalleSchema,
      TurnoSchema,
      MovimientoInventarioSchema,
    ],
    directory: dir.path,
    name: 'posDepositoDB', // Name your database file
  );

  // 6. Seed initial data (now using Isar's API)
  await _seedDatabase();

  // 7. Provide AuthProvider at the app root so screens can read it via Provider
runApp(
    MultiProvider(
      providers: [
        // Proveedores que no dependen de nada
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => TurnoProvider()),
        
        // --- AÑADE ESTO AQUÍ ---
        // CartProvider, que DEPENDE de AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          // 'auth' es el AuthProvider que creamos arriba
          create: (context) => CartProvider(authProvider: context.read<AuthProvider>()),
          // 'update' asegura que si AuthProvider cambiara, CartProvider se actualiza
          update: (context, auth, previousCart) => CartProvider(authProvider: auth),
        ),
        // --- FIN DE LA MODIFICACIÓN ---
      ],
      child: const MyApp(),
    ),
  );
}

// Updated Seeding function using Isar
Future<void> _seedDatabase() async {
  await isar.writeTxn(() async {
    // 1. Create Roles
    final adminRoleExists = await isar.rols
        .filter()
        .nombreEqualTo('Administrador')
        .findFirst();
    Rol adminRol;
    if (adminRoleExists == null) {
      adminRol = Rol()..nombre = 'Administrador';
      await isar.rols.put(adminRol);
    } else {
      adminRol = adminRoleExists;
    }

    final cajeroRoleExists = await isar.rols
        .filter()
        .nombreEqualTo('Cajero')
        .findFirst();
    Rol cajeroRol;
    if (cajeroRoleExists == null) {
      cajeroRol = Rol()..nombre = 'Cajero';
      await isar.rols.put(cajeroRol);
    } else {
      cajeroRol = cajeroRoleExists;
    }

    // 2. Create Default Admin User
    final adminUserExists = await isar.usuarios
        .filter()
        .usernameEqualTo('admin')
        .findFirst();
    if (adminUserExists == null) {
      // Use the new PasswordHasher utility
      final hashedPassword = PasswordHasher.hashPassword('admin');

      final adminUser = Usuario()
        ..nombre = 'Admin Principal'
        ..username = 'admin'
        ..passwordHash = hashedPassword['hash']!
        ..salt = hashedPassword['salt']!;

      await isar.usuarios.put(adminUser);
      // Link the role AFTER putting the user
      adminUser.rol.value = adminRol;
      await adminUser.rol.save();
    }

    // 3. Create Product Types
    if (await isar.tipoProductos.count() < 3) {
      await isar.tipoProductos.putAll([
        TipoProducto()..nombre = 'Normal',
        TipoProducto()..nombre = 'Líquido',
        TipoProducto()..nombre = 'Envase',
      ]);
    }
  });
  debugPrint("Isar database 'seeded' with roles, admin, and types.");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 8. No Provider needed here anymore for the DB itself
    return MaterialApp(
      title: 'POS Depósito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const LoginScreen(),
    );
  }
}
