// ============================================================================
// main_navigation_screen_v2.dart - ACTUALIZADO CON NUEVA PANTALLA DE MOMENTOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';

// Screens optimizadas - ACTUALIZADO
import '../v4/analytics_screen_v4.dart';
import 'home_screen_v2.dart';
import 'quick_moments_screen.dart'; // ✅ NUEVA PANTALLA RÁPIDA
import 'daily_review_screen_v2.dart';
import 'profile_screen_v2.dart';
import 'goals_screen_enhanced.dart';
import '../v3/daily_roadmap_screen_v3.dart';
import '../v5/analytics_screen_v5.dart'; // ✅ NUEVA PANTALLA DE ANALYTICS V5

// Componentes modernos

class MainNavigationScreenV2 extends StatefulWidget {
  const MainNavigationScreenV2({super.key});

  @override
  State<MainNavigationScreenV2> createState() => _MainNavigationScreenV2State();
}

class _MainNavigationScreenV2State extends State<MainNavigationScreenV2>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // ============================================================================
  // VARIABLES DE ESTADO MEJORADAS
  // ============================================================================

  int _currentIndex = 3;
  PageController? _pageController;
  late AnimationController _navAnimationController;
  late Animation<double> _navAnimation;

  // Control de estados
  bool _isInitialized = false;
  bool _isDisposed = false;

  // Lista de pantallas con la nueva QuickMomentsScreen
  late final List<Widget> _screens;

  // ============================================================================
  // ACTUALIZADO: Configuración de navegación con nueva pantalla de momentos
  // ============================================================================

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
      color: const Color(0xFFF59E0B),
      semanticLabel: 'Análisis y estadísticas',
    ),
    NavigationItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: 'Plan',
      color: const Color(0xFF9333EA),
      semanticLabel: 'Hoja de ruta diaria',
    ),
    NavigationItem(
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt,
      label: 'Momentos',
      color: const Color(0xFF8B5CF6),
      semanticLabel: 'Captura de momentos rápidos',
    ),
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
      color: const Color(0xFF3B82F6),
      semanticLabel: 'Pantalla de inicio',
    ),
    NavigationItem(
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note,
      label: 'Reflexion',
      color: const Color(0xFF10B981),
      semanticLabel: 'Reflexión diaria',
    ),
    NavigationItem(
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag,
      label: 'Metas',
      color: const Color(0xFF4ECDC4),
      semanticLabel: 'Gestión de metas',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
      color: const Color(0xFFEF4444),
      semanticLabel: 'Perfil de usuario',
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeScreens();
    _configureSystemUI();

    // Inicialización diferida y segura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _initializeNavigation();
      }
    });
  }

  void _configureSystemUI() {
    // Enhanced Android system UI configuration
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
    
    // Adaptive system UI style based on theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final themeProvider = context.read<ThemeProvider>();
        final isDark = themeProvider.isDarkMode;
        
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pageController?.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  // ============================================================================
  // INICIALIZACIÓN Y CONFIGURACIÓN
  // ============================================================================

  void _setupAnimations() {
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _navAnimation = CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _initializeScreens() {
    _screens = [
      const _SafeScreenWrapper(child: AnalyticsScreenV5()),
      const _SafeScreenWrapper(child: DailyRoadmapScreenV3()),
      const _SafeScreenWrapper(child: QuickMomentsScreen()),
      const _SafeScreenWrapper(child: HomeScreenV2()),
      const _SafeScreenWrapper(child: DailyReviewScreenV2()),
      const _SafeScreenWrapper(child: GoalsScreenEnhanced()),
      const _SafeScreenWrapper(child: ProfileScreenV2()),
    ];
  }

  Future<void> _initializeNavigation() async {
    if (_isDisposed) return;

    try {
      _pageController = PageController(initialPage: _currentIndex);

      // Precargar datos necesarios para la navegación
      await _preloadEssentialData();

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
        _navAnimationController.forward();
      }
    } catch (e) {
      debugPrint('Error inicializando navegación: $e');
    }
  }

  Future<void> _preloadEssentialData() async {
    try {
      final authProvider = context.read<OptimizedAuthProvider>();

      if (authProvider.currentUser != null) {
        final userId = authProvider.currentUser!.id;

        // Cargar datos en paralelo de forma segura
        final futures = <Future<void>>[];

        // Solo cargar si los providers están disponibles
        try {
          futures.add(context.read<OptimizedMomentsProvider>().loadMoments(userId));
        } catch (e) {
          debugPrint('MomentsProvider no disponible: $e');
        }

        try {
          futures.add(context.read<OptimizedDailyEntriesProvider>().loadEntries(userId));
        } catch (e) {
          debugPrint('DailyEntriesProvider no disponible: $e');
        }

        if (futures.isNotEmpty) {
          await Future.wait(futures, eagerError: false);
        }
      }
    } catch (e) {
      debugPrint('Error precargando datos: $e');
    }
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    return Consumer<OptimizedAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.currentUser == null) {
          return _buildNoUserScreen();
        }

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            // Get system UI information for Android compatibility
            final mediaQuery = MediaQuery.of(context);
            final safeAreaInsets = mediaQuery.viewInsets;
            final isKeyboardVisible = safeAreaInsets.bottom > 0;
            
            return Scaffold(
              backgroundColor: themeProvider.primaryBg,
              extendBody: true,
              extendBodyBehindAppBar: true,
              // Enhanced keyboard handling for Android
              resizeToAvoidBottomInset: true,
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeProvider.primaryBg,
                      themeProvider.primaryBg.withOpacity(0.98),
                    ],
                  ),
                ),
                child: SafeArea(
                  // Enhanced safe area handling for Android devices
                  top: true,
                  bottom: false,
                  maintainBottomViewPadding: false,
                  child: _buildBody(),
                ),
              ),
              bottomNavigationBar: _buildBottomNavigation(
                isKeyboardVisible: isKeyboardVisible,
                themeProvider: themeProvider,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: themeProvider.primaryBg,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.gradientHeader,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 30,
                    color: themeProvider.surface,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Preparando tu experiencia...',
                  style: TextStyle(
                    color: themeProvider.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeProvider.accentPrimary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoUserScreen() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: themeProvider.primaryBg,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: themeProvider.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Usuario no disponible',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Por favor, reinicia la aplicación',
                  style: TextStyle(color: themeProvider.textSecondary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Reinicializar auth provider
                    context.read<OptimizedAuthProvider>().loginAsDeveloper();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.accentPrimary,
                    foregroundColor: themeProvider.surface,
                  ),
                  child: const Text('Reiniciar sesión'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _screens.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _navAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _navAnimation,
              child: _screens[index],
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // BOTTOM NAVIGATION ACTUALIZADA
  // ============================================================================

  Widget _buildBottomNavigation({
    bool isKeyboardVisible = false,
    required ThemeProvider themeProvider,
  }) {
    return AnimatedBuilder(
      animation: _navAnimation,
      builder: (context, child) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          // Enhanced keyboard handling with better animation
          offset: isKeyboardVisible ? const Offset(0, 1.5) : Offset.zero,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _navAnimation,
              curve: Curves.easeOutBack,
            )),
            child: _buildBottomNavigationContent(themeProvider),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationContent(ThemeProvider themeProvider) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final isTablet = mediaQuery.size.width > 600;
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 380;
    final isVerySmallScreen = screenWidth < 360;

    // Detectar si hay botones de navegación de Android
    final hasSystemNavButtons = bottomPadding > 0;

    // Adaptive dimensions for 7 navigation items
    final navigationHeight = isTablet ? 70.0 : (isSmallScreen ? 56.0 : 60.0);
    final horizontalMargin = isVerySmallScreen ? 2.0 : (isSmallScreen ? 4.0 : (screenWidth > 400 ? 8.0 : 6.0));

    // Si hay botones del sistema, dejar espacio; si no, pegar abajo
    final bottomMargin = hasSystemNavButtons ? bottomPadding + 2.0 : 2.0;
    
    return Container(
      height: navigationHeight,
      margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, bottomMargin),
      decoration: BoxDecoration(
        // Enhanced glassmorphism effect
        color: themeProvider.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(hasSystemNavButtons ? 24 : 20),
        border: Border.all(
          color: themeProvider.borderColor.withOpacity(0.2),
          width: 1.0,
        ),
        boxShadow: [
          // Primary shadow for depth
          BoxShadow(
            color: themeProvider.shadowColor.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          // Secondary shadow for ambient light
          BoxShadow(
            color: themeProvider.shadowColor.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
          // Inner highlight effect (simulated with light color)
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(hasSystemNavButtons ? 24 : 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isVerySmallScreen ? 1 : 2,
              horizontal: isVerySmallScreen ? 1 : 2,
            ),
            decoration: BoxDecoration(
              // Subtle gradient overlay
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return Flexible(
                  child: _buildNavigationItem(item, index, isSelected, themeProvider),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item, int index, bool isSelected, ThemeProvider themeProvider) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final isVerySmallScreen = screenWidth < 360;

    return Semantics(
      label: item.semanticLabel,
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNavigationTap(index),
          borderRadius: BorderRadius.circular(20),
          splashColor: item.color.withOpacity(0.1),
          highlightColor: item.color.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 8 : (isVerySmallScreen ? 2 : (isSmallScreen ? 3 : 6)),
              horizontal: 0,
            ),
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        item.color.withOpacity(0.15),
                        item.color.withOpacity(0.08),
                        item.color.withOpacity(0.03),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(
                      color: item.color.withOpacity(0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.9 + (value * 0.2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.all(isTablet ? 8 : (isVerySmallScreen ? 2 : (isSmallScreen ? 3 : 5))),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.transparent,
                            item.color.withOpacity(0.25),
                            value,
                          ),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: item.color.withOpacity(0.4 * value),
                                    blurRadius: 12 * value,
                                    offset: Offset(0, 4 * value),
                                    spreadRadius: -2 * value,
                                  ),
                                  BoxShadow(
                                    color: item.color.withOpacity(0.2 * value),
                                    blurRadius: 6 * value,
                                    offset: Offset(0, 2 * value),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: isTablet ? 20 : (isVerySmallScreen ? 14 : (isSmallScreen ? 15 : 18)),
                          color: Color.lerp(
                            themeProvider.textSecondary.withOpacity(0.8),
                            item.color,
                            isSelected ? 1.0 : 0.6,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: isTablet ? 4 : (isVerySmallScreen ? 0.5 : (isSmallScreen ? 1 : 2))),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isTablet ? 10 : (isVerySmallScreen ? 7 : (isSmallScreen ? 8 : 9)),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? item.color : themeProvider.textSecondary,
                    letterSpacing: isSelected ? 0.05 : 0,
                    height: 1.0,
                  ),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.0 : 1.0,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE NAVEGACIÓN MEJORADOS
  // ============================================================================

  void _onNavigationTap(int index) {
    if (_isDisposed || !_isInitialized || index == _currentIndex) return;

    // Enhanced haptic feedback for better Android experience
    _provideFeedback();

    setState(() {
      _currentIndex = index;
    });

    // Smoother page animation
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (_isDisposed) return;

    setState(() {
      _currentIndex = index;
    });
  }

  void _provideFeedback() {
    try {
      // Enhanced haptic feedback for better user experience
      HapticFeedback.selectionClick();
      // Add a subtle vibration on Android devices
      Future.delayed(const Duration(milliseconds: 50), () {
        HapticFeedback.lightImpact();
      });
    } catch (e) {
      // Silently handle haptic feedback errors
      debugPrint('Haptic feedback error: $e');
    }
  }

  // ============================================================================
  // RESPONSIVE BREAKPOINTS (Helper methods removed - using inline checks)
  // ============================================================================
}

// ============================================================================
// CLASES DE APOYO
// ============================================================================

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final String semanticLabel;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.semanticLabel,
  });
}

// Wrapper seguro para las pantallas
class _SafeScreenWrapper extends StatelessWidget {
  final Widget child;

  const _SafeScreenWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          debugPrint('Error en pantalla: $e');
          return _buildErrorScreen(e.toString());
        }
      },
    );
  }

  Widget _buildErrorScreen(String error) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: themeProvider.primaryBg,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: themeProvider.negativeMain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error en la pantalla',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error,
                    style: TextStyle(color: themeProvider.negativeMain),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}