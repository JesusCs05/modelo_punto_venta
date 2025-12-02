// Archivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'data/collections/negocio.dart';
// --- End Collection Imports ---
import 'data/models/business_info.dart';
import 'presentation/screens/login_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'presentation/services/window_close_service.dart';
import 'presentation/widgets/pos/modal_cerrar_turno.dart';
import 'presentation/theme/app_colors.dart';
import 'package:crypto/crypto.dart'; // For seeding
import 'dart:convert'; // For seeding
import 'package:provider/provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/turno_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/business_provider.dart';

// 3. Global Isar instance (consider using Provider/GetIt later)
late Isar isar;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Silence debug output in production/installer runs: disable debugPrint
  debugPrint = (String? message, {int? wrapWidth}) {};
  // Inicializar window_manager (solo en desktop). Si falla, seguimos sin bloqueo nativo.
  try {
    await windowManager.ensureInitialized();
    windowManager.addListener(_MyWindowListener());
    // Previene el cierre nativo por defecto; manejamos el cierre desde Dart.
    await windowManager.setPreventClose(true);
    debugPrint('window_manager initialized');
  } catch (e) {
    debugPrint('window_manager init failed: $e');
  }

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
      NegocioSchema,
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

        // BusinessProvider: carga la información del negocio desde SharedPreferences
        ChangeNotifierProvider(
          create: (context) => BusinessProvider(isar)..load(),
        ),

        // --- AÑADE ESTO AQUÍ ---
        // CartProvider, que DEPENDE de AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          // 'auth' es el AuthProvider que creamos arriba
          create: (context) =>
              CartProvider(authProvider: context.read<AuthProvider>()),
          // 'update' asegura que si AuthProvider cambiara, CartProvider se actualiza
          update: (context, auth, previousCart) =>
              CartProvider(authProvider: auth),
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
      final password = 'admin';
      final bytes = utf8.encode(password);
      final passwordHash = sha256.convert(bytes).toString();

      final adminUser = Usuario()
        ..nombre = 'Admin Principal'
        ..username = 'admin'
        ..passwordHash = passwordHash;

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

    // 4. Ensure there is a negocio record (business info) in the DB
    final existingNegocio = await isar.negocios.where().findFirst();
    if (existingNegocio == null) {
      final defaultInfo = BusinessInfo.defaultInfo();
      final negocio = Negocio()
        ..nombre = defaultInfo.nombre
        ..razonSocial = defaultInfo.razonSocial
        ..telefono = defaultInfo.telefono
        ..direccion = defaultInfo.direccion
        ..rfc = defaultInfo.rfc;
      await isar.negocios.put(negocio);
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
      navigatorKey: navigatorKey,
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

// En lib/main.dart

class _MyWindowListener with WindowListener {
  // Evita reentradas si se recibe más de un evento de cierre.
  bool _isHandlingClose = false;

  @override
  void onWindowClose() async {
    debugPrint('onWindowClose triggered');
    if (_isHandlingClose) {
      debugPrint('Already handling close, ignoring this event');
      return;
    }
    _isHandlingClose = true;
    debugPrint('pos active: ${WindowCloseService.posScreenActive}');

    // Nota: `setPreventClose(true)` se establece globalmente al inicio de la
    // aplicación (para que podamos manejar cierres desde Dart). Aquí no es
    // necesario volver a setearlo.

    final navigator = navigatorKey.currentState;
    if (navigator == null || navigator.overlay == null) {
      debugPrint('No navigator/context - allowing close');
      await windowManager.setPreventClose(false);
      await windowManager.close();
      return;
    }

    try {
      bool confirmClose = false;

      // --- INICIO DE LA LÓGICA CORREGIDA ---
      if (WindowCloseService.posScreenActive) {
        // --- CASO 1: ESTÁ EN LA PANTALLA DE VENTAS ---
        debugPrint('Mostrando diálogo de CORTE DE CAJA (Flutter dialog)');

        // Usar el context del navigator al mostrar el diálogo. El linter
        // puede advertir sobre uso de BuildContext tras await; este context
        // se obtiene justo antes de invocar el diálogo.
        // ignore: use_build_context_synchronously
        final wantCorte = await showDialog<bool>(
          context: navigator.overlay!.context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Desea salir?'),
            content: const Text(
              'Está en una sesión de ventas. ¿Desea realizar el corte de caja ahora?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
        );

        if (wantCorte == true) {
          // El usuario quiere hacer el corte.
          // ignore: use_build_context_synchronously
          final result = await mostrarModalCerrarTurno(
            navigator.overlay!.context,
          );
          if (result == CierreTurnoResultado.exitoso) {
            // El corte fue exitoso, permitir el cierre.
            confirmClose = true;
          }
          // Si el corte fue cancelado, confirmClose sigue en false
        }
        // Si dijo "No" al diálogo, confirmClose sigue en false
      } else {
        // --- CASO 2: NO ESTÁ EN LA PANTALLA DE VENTAS (p.ej. Login) ---
        debugPrint('Mostrando diálogo de CONFIRMAR SALIDA (Flutter dialog)');
        // ignore: use_build_context_synchronously
        final confirm = await showDialog<bool>(
          context: navigator.overlay!.context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmar Salida'),
            content: const Text(
              '¿Estás seguro de que deseas salir de la aplicación?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          confirmClose = true;
        }
      }
      // --- FIN DE LA LÓGICA CORREGIDA ---

      // 3. Decisión final
      if (confirmClose) {
        // Permitir que la app se cierre
        await windowManager.setPreventClose(false);
        await windowManager.close();
      } else {
        // El usuario canceló: no cerrar. Mantener preventClose=true para que
        // no se ejecute un cierre pendiente.
        debugPrint('Cierre cancelado por el usuario.');
      }
    } catch (e) {
      debugPrint('Error in onWindowClose: $e');
      await windowManager.setPreventClose(false);
    }
    // Liberar la bandera (si la app no se cerró) después de un pequeño debounce
    // para evitar que eventos WM_CLOSE adicionales (p. ej. por doble envío
    // del sistema tras click en la X) reingresen inmediatamente.
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isHandlingClose = false;
      debugPrint('isHandlingClose reset after debounce');
    });
  }
}
