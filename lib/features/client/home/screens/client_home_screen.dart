import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
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
              3; //Aqui pones un numero mayor a 0 y se activa la burbuja roja del numero de notificaciones
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
    const _HomeTab(),
    const _QuotesTab(),
    const _PaymentsTab(),
    _ProfileTab(userName: _userName, userEmail: _userEmail),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      // --- HEADER ---
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        titleSpacing: 24,
        title: Row(
          children: [
            // Logo del sistema interactuando con fondo azul
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/Isotipo_Incide.png',
                height: 26,
              ),
            ),
            const SizedBox(width: 14),
            // Saludo y nombre de usuario
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, Bienvenido',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                _isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _userName.isNotEmpty ? _userName : 'Usuario',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),
          ],
        ),
        actions: [
          // Botón Notificaciones con Badge (Alertas)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                // TODO: Abrir panel de notificaciones / marcar como leídas
              },
              icon: Badge(
                isLabelVisible: _unreadNotifications > 0,
                label: Text(
                  '$_unreadNotifications',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.redAccent,
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
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
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_rounded),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.request_quote_rounded),
              ),
              label: 'Cotizaciones',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.account_balance_wallet_rounded),
              ),
              label: 'Pagos',
            ),
            BottomNavigationBarItem(
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

// ─────────────────────────────────────────────────────────
//            SUB-PANTALLAS (TABS) TEMPORALES
// ─────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_rounded,
            size: 80,
            color: AppColors.primaryBlue.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'PANEL DE CLIENTES',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Encuentra y gestiona tus proyectos aquí.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _QuotesTab extends StatelessWidget {
  const _QuotesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mis Cotizaciones en construcción',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mis Pagos en construcción',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _ProfileTab({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_rounded,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            userName.isNotEmpty ? userName : 'Cargando nombre...',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            userEmail.isNotEmpty ? userEmail : 'Cargando email...',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () async {
              // --- TODO (Backend) - CIERRE DE SESIÓN ---
              // 1. Invalidar token remoto.
              // 2. Limpiar cache local (SharedPreferences).
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');
              await prefs.remove('user_role');
              if (context.mounted) {
                context.go('/roles');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text(
              'Cerrar Sesión',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
