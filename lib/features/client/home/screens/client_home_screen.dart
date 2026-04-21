import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../tabs/cliente_home_tab.dart';
import '../tabs/cliente_my_quotes_tab.dart';
import '../tabs/cliente_payments_tab.dart';
import '../tabs/cliente_profile_tab.dart';
import '../providers/home_providers.dart';
import '../widgets/client_banner_app_bar.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  int _currentIndex = 0;

  // --- VARIABLES DE ESTADO (Listas para el Backend) ---
  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// TODO (Backend): Conectar con tu API real para cargar datos del usuario.
  /// Endpoint sugerido: GET /api/client/profile
  /// Response esperada: { "name": "Juan Pérez", "email": "cliente@correo.com", "notifications": 3 }
  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Aquí iría tu llamada HTTP real. Ejemplo:
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('jwt_token');
      // final response = await http.get(Uri.parse('URL'), headers: {'Authorization': 'Bearer $token'});

      // Simulamos la latencia de red (mock)
      await Future.delayed(const Duration(milliseconds: 800));

      // Asignamos los datos obtenidos a las variables de estado
      if (mounted) {
        setState(() {
          _userName = 'Juan Pérez';
          _userEmail = 'cliente@correo.com';
          _unreadNotifications =
              3; // Aqui pones un numero mayor a 0 y se activa la burbuja roja del numero de notificaciones
        });
      }
    } catch (e) {
      // TODO: Manejo de errores de conexión/sesión (ej. token expirado -> redirigir al login)
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Lista de las secciones asignadas al BottomNavigationBar.
  // Ahora las inicializamos como métodos (getter) para pasarles las variables de estado.
  List<Widget> get _screens => [
    const HomeTab(),
    const QuotesTab(),
    const PaymentsTab(),
    ProfileTab(userName: _userName, userEmail: _userEmail),
  ];

  // Helper method removed. Logic is now in ClientHomeAppBar.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      // --- HEADER ---
      appBar: ClientHomeAppBar(
        currentIndex: _currentIndex,
        userName: _userName,
        isLoading: _isLoading,
        unreadNotifications: _unreadNotifications,
        onNotificationPressed: () {
          // TODO: Abrir panel de notificaciones
        },
      ),

      // Contenido principal que cambia según la pestaña
      body: _screens[_currentIndex],

      // --- BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_rounded),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Badge(
                  isLabelVisible: ref.watch(hasUnreadProposalsProvider),
                  backgroundColor: Colors.redAccent,
                  smallSize: 10,
                  child: const Icon(Icons.request_quote_rounded),
                ),
              ),
              label: 'Cotizaciones',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.account_balance_wallet_rounded),
              ),
              label: 'Pagos',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person_rounded),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
