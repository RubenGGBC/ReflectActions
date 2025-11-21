// ============================================================================
// lib/presentation/providers/hopecore_quotes_provider.dart - HOPECORE QUOTES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';
import 'dart:math';

class HopecoreQuotesProvider with ChangeNotifier {
  final Logger _logger = Logger();
  final Random _random = Random();

  bool _isInitialized = false;

  // Frases inspiradoras en español
  static const List<Map<String, String>> _quotes = [
    {'quote': 'Tu luz interior es más fuerte que cualquier oscuridad que enfrentes.', 'source': 'Hopecore'},
    {'quote': 'Cada amanecer es una segunda oportunidad que la vida te regala.', 'source': 'Hopecore'},
    {'quote': 'Eres el autor de tu propia historia, escribe un capítulo hermoso hoy.', 'source': 'Hopecore'},
    {'quote': 'Tu sonrisa tiene el poder de cambiar el mundo de alguien más.', 'source': 'Hopecore'},
    {'quote': 'En tu corazón vive una fuerza que puede mover montañas.', 'source': 'Hopecore'},
    {'quote': 'Cada pequeño paso que das te acerca a la versión más hermosa de ti.', 'source': 'Hopecore'},
    {'quote': 'Tu existencia hace que el universo sea un lugar más hermoso.', 'source': 'Hopecore'},
    {'quote': 'Incluso en los días grises, tu alma brilla con colores únicos.', 'source': 'Hopecore'},
    {'quote': 'Eres una obra de arte en constante creación, y cada día te haces más hermosa.', 'source': 'Hopecore'},
    {'quote': 'Tu respiración es prueba de que mereces estar aquí, viviendo plenamente.', 'source': 'Hopecore'},
    {'quote': 'Cada latido de tu corazón es una promesa de nuevas posibilidades.', 'source': 'Hopecore'},
    {'quote': 'Tu presencia en este mundo tiene un propósito único e irreemplazable.', 'source': 'Hopecore'},
    {'quote': 'Las estrellas envidian la luz que irradias desde tu alma.', 'source': 'Hopecore'},
    {'quote': 'Tienes dentro de ti todo lo necesario para florecer magnificamente.', 'source': 'Hopecore'},
    {'quote': 'Tu bondad es como lluvia suave que nutre los corazones a tu alrededor.', 'source': 'Hopecore'},
    {'quote': 'Cada desafío que superas te convierte en una versión más sabia y fuerte.', 'source': 'Hopecore'},
    {'quote': 'Tu capacidad de amar es infinita, y eso te hace extraordinario.', 'source': 'Hopecore'},
    {'quote': 'Eres como un jardín secreto lleno de tesoros esperando ser descubiertos.', 'source': 'Hopecore'},
    {'quote': 'Tu voz tiene el poder de sanar heridas que ni siquiera puedes ver.', 'source': 'Hopecore'},
    {'quote': 'Cada momento que decides ser auténtico, el mundo se vuelve más real.', 'source': 'Hopecore'},
    {'quote': 'Tu esperanza es un faro que guía a otros hacia la luz.', 'source': 'Hopecore'},
    {'quote': 'Incluso cuando te sientes pequeño, tu impacto en el mundo es inmenso.', 'source': 'Hopecore'},
    {'quote': 'Tu corazón conoce caminos que tu mente aún no ha explorado.', 'source': 'Hopecore'},
    {'quote': 'Eres un milagro caminando, respirando y creando belleza donde vas.', 'source': 'Hopecore'},
    {'quote': 'Tu gentileza es como miel dorada que endulza la vida de quienes te rodean.', 'source': 'Hopecore'},
    {'quote': 'Cada vez que eliges el amor sobre el miedo, el mundo se transforma.', 'source': 'Hopecore'},
    {'quote': 'Tu alma es un universo de posibilidades esperando expandirse.', 'source': 'Hopecore'},
    {'quote': 'Eres como música celestial que hace danzar a los corazones.', 'source': 'Hopecore'},
    {'quote': 'Tu presencia es un regalo que ilumina los días más ordinarios.', 'source': 'Hopecore'},
    {'quote': 'Cada acto de bondad que realizas envía ondas de luz por el universo.', 'source': 'Hopecore'},
    {'quote': 'Tu fuerza interior es como un río que nunca deja de fluir hacia adelante.', 'source': 'Hopecore'},
    {'quote': 'Eres un puente de esperanza entre el hoy y el mañana más brillante.', 'source': 'Hopecore'},
    {'quote': 'Tu imaginación es un lienzo infinito donde puedes pintar realidades hermosas.', 'source': 'Hopecore'},
    {'quote': 'Cada vez que ayudas a alguien, plantas semillas de luz en el mundo.', 'source': 'Hopecore'},
    {'quote': 'Tu coraje silencioso inspira a otros a encontrar su propia valentía.', 'source': 'Hopecore'},
    {'quote': 'Eres como un amanecer que promete nuevas oportunidades cada día.', 'source': 'Hopecore'},
    {'quote': 'Tu compasión es medicina para las heridas invisibles del mundo.', 'source': 'Hopecore'},
    {'quote': 'Cada sueño que persigues hace que el universo conspire a tu favor.', 'source': 'Hopecore'},
    {'quote': 'Tu autenticidad es como agua fresca en un desierto de pretensiones.', 'source': 'Hopecore'},
    {'quote': 'Eres un tesoro viviente cuyo valor aumenta con cada experiencia.', 'source': 'Hopecore'},
    {'quote': 'Tu energía positiva es contagiosa y crea círculos de felicidad infinitos.', 'source': 'Hopecore'},
    {'quote': 'Cada momento de gratitud que sientes multiplica la abundancia en tu vida.', 'source': 'Hopecore'},
    {'quote': 'Tu sabiduría crece como un árbol, echando raíces profundas y ramas al cielo.', 'source': 'Hopecore'},
    {'quote': 'Eres un alquimista del amor, transformando momentos ordinarios en mágicos.', 'source': 'Hopecore'},
    {'quote': 'Tu perseverancia es como el agua que suavemente moldea hasta las rocas más duras.', 'source': 'Hopecore'},
    {'quote': 'Cada lágrima que has derramado ha regado el jardín de tu crecimiento personal.', 'source': 'Hopecore'},
    {'quote': 'Tu intuición es una brújula sagrada que siempre te guía hacia tu verdad.', 'source': 'Hopecore'},
    {'quote': 'Eres como un cristal único que refracta la luz en patrones hermosos e irrepetibles.', 'source': 'Hopecore'},
    {'quote': 'Tu capacidad de perdón es un superpoder que libera tanto tu alma como la de otros.', 'source': 'Hopecore'},
    {'quote': 'Cada día que eliges crecer, te conviertes en una versión más luminosa de ti mismo.', 'source': 'Hopecore'},
  ];

  bool get isInitialized => _isInitialized;

  /// Inicializar provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    _logger.i('🌟 Inicializando HopecoreQuotesProvider');
    
    _isInitialized = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Obtener una frase aleatoria
  Map<String, String> getRandomQuote() {
    if (_quotes.isEmpty) {
      return {'quote': 'Eres increíble tal como eres', 'source': 'Hopecore'};
    }
    
    return _quotes[_random.nextInt(_quotes.length)];
  }

  /// Obtener todas las frases disponibles
  List<Map<String, String>> getAllQuotes() {
    return _quotes;
  }

  /// Obtener frase motivacional según el estado de ánimo
  Map<String, String> getQuoteForMood(double moodScore) {
    if (moodScore <= 3) {
      // Para estados de ánimo bajos, frases más reconfortantes y directas
      final comfortingQuotes = [
        {'quote': 'Eres más fuerte que cualquier tormenta que enfrentes.', 'source': 'Hopecore'},
        {'quote': 'Tu valor no depende de cómo te sientes hoy.', 'source': 'Hopecore'},
        {'quote': 'Mañana será un día completamente nuevo para ti.', 'source': 'Hopecore'},
        {'quote': 'Tu luz interior sigue brillando, aunque no la veas.', 'source': 'Hopecore'},
        {'quote': 'Tienes todo lo que necesitas para superar esto.', 'source': 'Hopecore'},
      ];
      return comfortingQuotes[_random.nextInt(comfortingQuotes.length)];
    } else if (moodScore <= 6) {
      // Para estados neutros, frases de motivación directa
      final encouragingQuotes = [
        {'quote': 'Cada pequeño paso te acerca a algo grandioso.', 'source': 'Hopecore'},
        {'quote': 'Hoy puedes hacer algo increíble.', 'source': 'Hopecore'},
        {'quote': 'Tu progreso es real, aunque sea pequeño.', 'source': 'Hopecore'},
        {'quote': 'Confía en ti mismo, tienes razones para hacerlo.', 'source': 'Hopecore'},
      ];
      return encouragingQuotes[_random.nextInt(encouragingQuotes.length)];
    } else {
      // Para estados positivos, frases inspiradoras y empoderadoras
      final inspiringQuotes = [
        {'quote': 'Tu energía positiva contagia a todos a tu alrededor.', 'source': 'Hopecore'},
        {'quote': 'Estás viviendo tu mejor versión ahora mismo.', 'source': 'Hopecore'},
        {'quote': 'Tu felicidad inspira a otros a ser felices.', 'source': 'Hopecore'},
        {'quote': 'Tienes el poder de hacer de hoy un día extraordinario.', 'source': 'Hopecore'},
        {'quote': 'Tu sonrisa es medicina para el alma de otros.', 'source': 'Hopecore'},
      ];
      return inspiringQuotes[_random.nextInt(inspiringQuotes.length)];
    }
  }

  /// Obtener frase para hora específica del día
  Map<String, String> getQuoteForTimeOfDay() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      // Mañana
      final morningQuotes = [
        {'quote': 'Este amanecer trae nuevas oportunidades solo para ti.', 'source': 'Hopecore'},
        {'quote': 'Hoy vas a lograr algo maravilloso.', 'source': 'Hopecore'},
        {'quote': 'Tu día está lleno de posibilidades esperándote.', 'source': 'Hopecore'},
      ];
      return morningQuotes[_random.nextInt(morningQuotes.length)];
    } else if (hour >= 12 && hour < 18) {
      // Tarde
      final afternoonQuotes = [
        {'quote': 'Tu energía positiva está transformando tu día.', 'source': 'Hopecore'},
        {'quote': 'Cada sonrisa tuya hace el mundo más hermoso.', 'source': 'Hopecore'},
        {'quote': 'Tu persistencia está dando frutos increíbles.', 'source': 'Hopecore'},
      ];
      return afternoonQuotes[_random.nextInt(afternoonQuotes.length)];
    } else {
      // Noche
      final eveningQuotes = [
        {'quote': 'Hoy hiciste cosas que te acercan a tus sueños.', 'source': 'Hopecore'},
        {'quote': 'Descansa sabiendo que eres increíblemente valioso.', 'source': 'Hopecore'},
        {'quote': 'Mañana despertarás con nuevas fuerzas y esperanzas.', 'source': 'Hopecore'},
      ];
      return eveningQuotes[_random.nextInt(eveningQuotes.length)];
    }
  }

  /// Obtener número total de frases
  int getTotalQuotesCount() {
    return _quotes.length;
  }

  /// Obtener frases por fuente específica
  List<Map<String, String>> getQuotesBySource(String source) {
    return _quotes.where((quote) => 
      quote['source']?.toLowerCase() == source.toLowerCase()).toList();
  }
}