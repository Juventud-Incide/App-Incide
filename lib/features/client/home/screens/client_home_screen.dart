import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../tabs/cliente_home_tab.dart';
import '../tabs/cliente_my_quotes_tab.dart';
import '../tabs/cliente_payments_tab.dart';
import '../tabs/cliente_profile_tab.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      // --- HEADER ---
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        toolbarHeight: 85,
        titleSpacing: 24,
        title: Row(
          children: [
            // Logo del sistema con diseño estilizado
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/Isotipo_Incide.png',
                height: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Saludo y nombre de usuario con mejor jerarquía
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hola, Bienvenido',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _userName.isNotEmpty ? _userName : 'Usuario',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
              ],
            ),
          ],
        ),
        actions: [
          // Botón Notificaciones con diseño Premium mejorado
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Abrir panel de notificaciones
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$_unreadNotifications',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
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
