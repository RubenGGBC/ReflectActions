// lib/presentation/providers/recommended_activities_provider.dart
// ============================================================================
// PROVEEDOR DE ACTIVIDADES RECOMENDADAS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;
import '../../data/models/recommended_activity_model.dart';

class RecommendedActivitiesProvider with ChangeNotifier {
  final Logger _logger = Logger();
  final math.Random _random = math.Random();

  List<RecommendedActivity> _allActivities = [];
  List<RecommendedActivity> _dailyRecommendations = [];
  List<ActivityCompletion> _completedActivities = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastRecommendationDate;

  // Getters
  List<RecommendedActivity> get allActivities => _allActivities;
  List<RecommendedActivity> get dailyRecommendations => _dailyRecommendations;
  List<ActivityCompletion> get completedActivities => _completedActivities;

  List<String> get completedActivitiesToday {
    final today = DateTime.now();
    return _completedActivities
        .where((completion) =>
            completion.completedAt.year == today.year &&
            completion.completedAt.month == today.month &&
            completion.completedAt.day == today.day)
        .map((completion) =>
            _allActivities
                .firstWhere((activity) => activity.id == completion.activityId)
                .title)
        .toList();
  }
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  RecommendedActivitiesProvider() {
    _initializeActivities();
  }

  /// Initialize the provider with 50 wellness activities
  void _initializeActivities() {
    _logger.d('🌱 Initializing 50 wellness activities');
    _allActivities = _createWellnessActivities();
    _generateDailyRecommendations();
    notifyListeners();
  }

  /// Create 50 comprehensive wellness activities
  List<RecommendedActivity> _createWellnessActivities() {
    return [
      // MINDFULNESS & MEDITATION (10 activities)
      RecommendedActivity(
        id: 'mindfulness_1',
        title: 'Meditación de 5 Minutos',
        description: 'Una sesión corta de meditación para centrar tu mente',
        category: 'Mindfulness',
        type: ActivityType.meditation,
        durationMinutes: 5,
        difficultyLevel: 1,
        benefits: ['Reduce el estrés', 'Mejora la concentración', 'Calma la mente'],
        instructions: ['Siéntate cómodamente', 'Cierra los ojos', 'Respira profundamente', 'Enfócate en tu respiración'],
        resources: {'audio': 'meditation_5min.mp3', 'guide': 'basic_meditation'},
        requiresTimer: true,
        motivationalQuote: 'La paz viene de dentro. No la busques fuera.',
      ),
      RecommendedActivity(
        id: 'mindfulness_2',
        title: 'Escaneo Corporal',
        description: 'Conecta con tu cuerpo a través de la atención plena',
        category: 'Mindfulness',
        type: ActivityType.mindfulness,
        durationMinutes: 10,
        difficultyLevel: 2,
        benefits: ['Reduce tensión', 'Mejora autoconciencia', 'Relaja músculos'],
        instructions: ['Acuéstate cómodamente', 'Respira profundo', 'Escanea cada parte del cuerpo', 'Nota sensaciones sin juzgar'],
        resources: {'audio': 'body_scan.mp3', 'positions': 'lying_down'},
        requiresTimer: true,
        motivationalQuote: 'Tu cuerpo es tu templo. Mantén la mente y el cuerpo puros.',
      ),
      RecommendedActivity(
        id: 'mindfulness_3',
        title: 'Atención Plena al Comer',
        description: 'Practica mindfulness durante tu próxima comida',
        category: 'Mindfulness',
        type: ActivityType.mindfulness,
        durationMinutes: 15,
        difficultyLevel: 2,
        benefits: ['Mejora digestión', 'Aumenta satisfacción', 'Reduce comer emocional'],
        instructions: ['Elige una comida', 'Elimina distracciones', 'Come lentamente', 'Observa sabores y texturas'],
        resources: {'guide': 'mindful_eating', 'tips': 'eating_awareness'},
        requiresTimer: false,
        motivationalQuote: 'Comer con atención plena es una forma de meditación.',
      ),
      RecommendedActivity(
        id: 'mindfulness_4',
        title: 'Caminata Consciente',
        description: 'Camina con plena atención al presente',
        category: 'Mindfulness',
        type: ActivityType.mindfulness,
        durationMinutes: 20,
        difficultyLevel: 2,
        benefits: ['Conecta con naturaleza', 'Reduce ansiedad', 'Mejora estado de ánimo'],
        instructions: ['Camina lentamente', 'Observa el entorno', 'Siente cada paso', 'Respira conscientemente'],
        resources: {'locations': 'outdoor_spaces', 'safety': 'walking_tips'},
        requiresTimer: true,
        motivationalQuote: 'Cada paso te acerca a la paz interior.',
      ),
      RecommendedActivity(
        id: 'mindfulness_5',
        title: 'Respiración 4-7-8',
        description: 'Técnica de respiración para calmar el sistema nervioso',
        category: 'Respiración',
        type: ActivityType.breathing,
        durationMinutes: 5,
        difficultyLevel: 1,
        benefits: ['Reduce ansiedad', 'Mejora sueño', 'Calma mente'],
        instructions: ['Inhala 4 segundos', 'Mantén 7 segundos', 'Exhala 8 segundos', 'Repite 4 ciclos'],
        resources: {'technique': '4-7-8_breathing', 'timer': 'breathing_timer'},
        requiresTimer: true,
        motivationalQuote: 'La respiración es el puente entre la mente y el cuerpo.',
      ),
      RecommendedActivity(
        id: 'mindfulness_6',
        title: 'Meditación de Bondad Amorosa',
        description: 'Cultiva compasión hacia ti mismo y otros',
        category: 'Mindfulness',
        type: ActivityType.meditation,
        durationMinutes: 15,
        difficultyLevel: 3,
        benefits: ['Aumenta compasión', 'Reduce crítica interna', 'Mejora relaciones'],
        instructions: ['Siéntate cómodamente', 'Envía amor a ti mismo', 'Extiende amor a otros', 'Incluye a todos los seres'],
        resources: {'guided': 'loving_kindness.mp3', 'phrases': 'metta_phrases'},
        requiresTimer: true,
        motivationalQuote: 'El amor y la compasión son necesidades, no lujos.',
      ),
      RecommendedActivity(
        id: 'mindfulness_7',
        title: 'Observación de Pensamientos',
        description: 'Observa tus pensamientos sin juzgarlos',
        category: 'Mindfulness',
        type: ActivityType.mindfulness,
        durationMinutes: 10,
        difficultyLevel: 3,
        benefits: ['Mejora autoconciencia', 'Reduce rumiación', 'Aumenta claridad mental'],
        instructions: ['Siéntate en silencio', 'Observa pensamientos que surgen', 'No juzgues ni analices', 'Deja que pasen como nubes'],
        resources: {'technique': 'thought_observation', 'metaphors': 'clouds_sky'},
        requiresTimer: true,
        motivationalQuote: 'Los pensamientos son como nubes, van y vienen.',
      ),
      RecommendedActivity(
        id: 'mindfulness_8',
        title: 'Meditación de los 5 Sentidos',
        description: 'Conecta con el presente usando tus 5 sentidos',
        category: 'Mindfulness',
        type: ActivityType.mindfulness,
        durationMinutes: 8,
        difficultyLevel: 2,
        benefits: ['Ancla en el presente', 'Reduce ansiedad', 'Mejora percepción'],
        instructions: ['5 cosas que ves', '4 que tocas', '3 que oyes', '2 que hueles', '1 que saboreas'],
        resources: {'technique': '5_senses', 'examples': 'sensory_awareness'},
        requiresTimer: true,
        motivationalQuote: 'El presente es el único momento que tienes.',
      ),
      RecommendedActivity(
        id: 'mindfulness_9',
        title: 'Respiración Cuadrada',
        description: 'Técnica de respiración para equilibrar el sistema nervioso',
        category: 'Respiración',
        type: ActivityType.breathing,
        durationMinutes: 6,
        difficultyLevel: 2,
        benefits: ['Balancea energía', 'Mejora concentración', 'Reduce estrés'],
        instructions: ['Inhala 4 segundos', 'Mantén 4 segundos', 'Exhala 4 segundos', 'Mantén 4 segundos'],
        resources: {'technique': 'box_breathing', 'visual': 'square_timer'},
        requiresTimer: true,
        motivationalQuote: 'La respiración equilibrada crea una mente equilibrada.',
      ),
      RecommendedActivity(
        id: 'mindfulness_10',
        title: 'Meditación en Movimiento',
        description: 'Combina movimiento suave con mindfulness',
        category: 'Mindfulness',
        type: ActivityType.movement,
        durationMinutes: 12,
        difficultyLevel: 2,
        benefits: ['Integra cuerpo y mente', 'Mejora coordinación', 'Reduce tensión'],
        instructions: ['Muévete muy lentamente', 'Observa cada movimiento', 'Sincroniza con respiración', 'Mantén conciencia corporal'],
        resources: {'movements': 'slow_motion', 'sequences': 'mindful_movement'},
        requiresTimer: true,
        motivationalQuote: 'El movimiento consciente es meditación en acción.',
      ),

      // PHYSICAL EXERCISE (10 activities)
      RecommendedActivity(
        id: 'exercise_1',
        title: 'Rutina de Estiramiento',
        description: 'Estira tu cuerpo para liberar tensión',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 10,
        difficultyLevel: 1,
        benefits: ['Mejora flexibilidad', 'Reduce dolor', 'Aumenta movilidad'],
        instructions: ['Calienta ligeramente', 'Estira cada grupo muscular', 'Mantén 30 segundos', 'Respira profundo'],
        resources: {'routine': 'basic_stretching', 'videos': 'stretch_guide'},
        requiresTimer: true,
        motivationalQuote: 'La flexibilidad es la clave de la estabilidad.',
      ),
      RecommendedActivity(
        id: 'exercise_2',
        title: 'Ejercicios de Fuerza Sin Equipo',
        description: 'Fortalece tu cuerpo usando solo tu peso corporal',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 15,
        difficultyLevel: 3,
        benefits: ['Aumenta fuerza', 'Mejora resistencia', 'Tonifica músculos'],
        instructions: ['Calentamiento 2 min', 'Flexiones', 'Sentadillas', 'Plancha'],
        resources: {'exercises': 'bodyweight_routine', 'modifications': 'beginner_advanced'},
        requiresTimer: true,
        motivationalQuote: 'La fuerza no viene del físico, viene de la voluntad.',
      ),
      RecommendedActivity(
        id: 'exercise_3',
        title: 'Yoga Matutino',
        description: 'Secuencia de yoga para energizar tu día',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 20,
        difficultyLevel: 2,
        benefits: ['Mejora flexibilidad', 'Reduce estrés', 'Aumenta energía'],
        instructions: ['Saludo al sol', 'Posturas básicas', 'Respiración consciente', 'Relajación final'],
        resources: {'sequence': 'morning_yoga', 'poses': 'basic_asanas'},
        requiresTimer: true,
        motivationalQuote: 'El yoga es un viaje del ser, a través del ser, hacia el ser.',
      ),
      RecommendedActivity(
        id: 'exercise_4',
        title: 'Cardio de Baja Intensidad',
        description: 'Ejercicio cardiovascular suave y sostenible',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 25,
        difficultyLevel: 2,
        benefits: ['Mejora resistencia', 'Quema calorías', 'Fortalece corazón'],
        instructions: ['Camina a paso ligero', 'Mantén ritmo constante', 'Respira cómodamente', 'Enfríate gradualmente'],
        resources: {'routes': 'walking_paths', 'music': 'cardio_playlist'},
        requiresTimer: true,
        motivationalQuote: 'Cada paso cuenta hacia una vida más saludable.',
      ),
      RecommendedActivity(
        id: 'exercise_5',
        title: 'Ejercicios de Equilibrio',
        description: 'Mejora tu equilibrio y coordinación',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 8,
        difficultyLevel: 2,
        benefits: ['Mejora equilibrio', 'Fortalece core', 'Previene caídas'],
        instructions: ['Párate en un pie', 'Mantén 30 segundos', 'Usa apoyo si necesario', 'Alterna piernas'],
        resources: {'exercises': 'balance_routine', 'progressions': 'difficulty_levels'},
        requiresTimer: true,
        motivationalQuote: 'El equilibrio es la clave de todo.',
      ),
      RecommendedActivity(
        id: 'exercise_6',
        title: 'Bailoterapia',
        description: 'Baila libremente para liberar energía y estrés',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 12,
        difficultyLevel: 1,
        benefits: ['Mejora estado de ánimo', 'Ejercicio divertido', 'Libera endorfinas'],
        instructions: ['Pon música que te guste', 'Muévete libremente', 'No juzgues tu baile', 'Disfruta el momento'],
        resources: {'playlists': 'dance_music', 'styles': 'free_dance'},
        requiresTimer: true,
        motivationalQuote: 'Baila como si nadie te viera.',
      ),
      RecommendedActivity(
        id: 'exercise_7',
        title: 'Ejercicios de Respiración Activa',
        description: 'Combina ejercicios de respiración con movimiento',
        category: 'Ejercicio',
        type: ActivityType.breathing,
        durationMinutes: 10,
        difficultyLevel: 2,
        benefits: ['Mejora capacidad pulmonar', 'Reduce ansiedad', 'Aumenta energía'],
        instructions: ['Respira profundo mientras te mueves', 'Sincroniza movimiento con respiración', 'Mantén ritmo constante'],
        resources: {'techniques': 'breath_exercise', 'movements': 'breathing_movements'},
        requiresTimer: true,
        motivationalQuote: 'La respiración es el ritmo de la vida.',
      ),
      RecommendedActivity(
        id: 'exercise_8',
        title: 'Pilates Básico',
        description: 'Ejercicios de Pilates para fortalecer el core',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 18,
        difficultyLevel: 3,
        benefits: ['Fortalece core', 'Mejora postura', 'Aumenta flexibilidad'],
        instructions: ['Enfócate en la respiración', 'Mantén el core activado', 'Movimientos controlados', 'Precisión sobre velocidad'],
        resources: {'exercises': 'pilates_basic', 'modifications': 'beginner_options'},
        requiresTimer: true,
        motivationalQuote: 'Pilates es el cuerpo en movimiento con la mente.',
      ),
      RecommendedActivity(
        id: 'exercise_9',
        title: 'Caminata Energizante',
        description: 'Camina con energía para activar tu cuerpo',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 15,
        difficultyLevel: 1,
        benefits: ['Activa circulación', 'Mejora humor', 'Aumenta energía'],
        instructions: ['Camina a paso vigoroso', 'Mueve los brazos', 'Mantén postura erguida', 'Respira profundo'],
        resources: {'routes': 'energizing_walks', 'tips': 'power_walking'},
        requiresTimer: true,
        motivationalQuote: 'Caminar es la mejor medicina del hombre.',
      ),
      RecommendedActivity(
        id: 'exercise_10',
        title: 'Ejercicios de Movilidad',
        description: 'Mejora tu movilidad articular',
        category: 'Ejercicio',
        type: ActivityType.exercise,
        durationMinutes: 12,
        difficultyLevel: 2,
        benefits: ['Mejora movilidad', 'Reduce rigidez', 'Previene lesiones'],
        instructions: ['Movimientos circulares', 'Rango completo de movimiento', 'Sin forzar', 'Movimientos suaves'],
        resources: {'routine': 'mobility_exercises', 'joints': 'joint_mobility'},
        requiresTimer: true,
        motivationalQuote: 'El movimiento es una medicina que crea cambios físicos, emocionales y mentales.',
      ),

      // CREATIVITY & SELF-EXPRESSION (8 activities)
      RecommendedActivity(
        id: 'creativity_1',
        title: 'Escritura Libre',
        description: 'Escribe sin censura durante 10 minutos',
        category: 'Creatividad',
        type: ActivityType.creativity,
        durationMinutes: 10,
        difficultyLevel: 1,
        benefits: ['Libera pensamientos', 'Mejora creatividad', 'Reduce estrés'],
        instructions: ['Escribe sin parar', 'No juzgues lo que escribes', 'Deja fluir los pensamientos', 'No te preocupes por gramática'],
        resources: {'prompts': 'writing_prompts', 'techniques': 'free_writing'},
        requiresTimer: true,
        motivationalQuote: 'La creatividad es la inteligencia divirtiéndose.',
      ),
      RecommendedActivity(
        id: 'creativity_2',
        title: 'Dibujo Meditativo',
        description: 'Dibuja mandalas o patrones repetitivos',
        category: 'Creatividad',
        type: ActivityType.creativity,
        durationMinutes: 15,
        difficultyLevel: 2,
        benefits: ['Calma la mente', 'Mejora concentración', 'Expresión artística'],
        instructions: ['Dibuja patrones simples', 'Repite formas básicas', 'Enfócate en el proceso', 'No busques perfección'],
        resources: {'patterns': 'mandala_templates', 'supplies': 'drawing_materials'},
        requiresTimer: true,
        motivationalQuote: 'El arte lava el alma del polvo de la vida cotidiana.',
      ),
      RecommendedActivity(
        id: 'creativity_3',
        title: 'Fotografía Consciente',
        description: 'Toma fotos enfocándote en el momento presente',
        category: 'Creatividad',
        type: ActivityType.creativity,
        durationMinutes: 20,
        difficultyLevel: 2,
        benefits: ['Mejora observación', 'Captura belleza', 'Practica mindfulness'],
        instructions: ['Busca detalles interesantes', 'Observa luz y sombras', 'Toma tu tiempo', 'Captura lo que te inspire'],
        resources: {'techniques': 'mindful_photography', 'subjects': 'photo_ideas'},
        requiresTimer: true,
        motivationalQuote: 'La fotografía es una forma de sentir, tocar y amar.',
      ),
      RecommendedActivity(
        id: 'creativity_4',
        title: 'Collage de Intenciones',
        description: 'Crea un collage que represente tus metas',
        category: 'Creatividad',
        type: ActivityType.creativity,
        durationMinutes: 25,
        difficultyLevel: 2,
        benefits: ['Clarifica objetivos', 'Estimula creatividad', 'Visualiza futuro'],
        instructions: ['Reúne revistas o imágenes', 'Recorta lo que te inspire', 'Arma tu collage', 'Reflexiona sobre el resultado'],
        resources: {'materials': 'collage_supplies', 'themes': 'intention_themes'},
        requiresTimer: true,
        motivationalQuote: 'La creatividad implica romper patrones para mirar las cosas de manera diferente.',
      ),
      RecommendedActivity(
        id: 'creativity_5',
        title: 'Música Improvisada',
        description: 'Crea música con objetos cotidianos',
        category: 'Creatividad',
        type: ActivityType.creativity,
        durationMinutes: 12,
        difficultyLevel: 1,
        benefits: ['Libera expresión', 'Mejora humor', 'Estimula creatividad'],
        instructions: ['Busca objetos que suenen', 'Experimenta con ritmos', 'No busques perfección', 'Diviértete'],
        resources: {'instruments': 'household_items', 'rhythms': 'basic_beats'},
        requiresTimer: true,
        motivationalQuote: 'La música es el lenguaje universal del corazón.',
      ),
      RecommendedActivity(
        id: 'creativity_6',
        title: 'Escritura de Cartas',
        description: 'Escribe una carta a tu yo futuro',
        category: 'Creatividad',
        type: ActivityType.creativity,
        durationMinutes: 18,
        difficultyLevel: 2,
        benefits: ['Clarifica pensamientos', 'Conecta con el futuro', 'Práctica de gratitud'],
        instructions: ['Escribe a tu yo de 1 año', 'Comparte tus esperanzas', 'Incluye consejos', 'Guarda para leer después'],
        resources: {'templates': 'letter_templates', 'prompts': 'future_self_prompts'},
        requiresTimer: true,
        motivationalQuote: 'Las cartas son conversaciones con el tiempo.',
      ),
      RecommendedActivity(
        id: 'creativity_7',
        title: 'Danza Libre',
        description: 'Baila expresando tus emociones',
        category: 'Creatividad',
        type: ActivityType.creativity,
        durationMinutes: 10,
        difficultyLevel: 1,
        benefits: ['Libera emociones', 'Mejora autoexpresión', 'Aumenta alegría'],
        instructions: ['Pon música que te mueva', 'Muévete según sientes', 'No juzgues tus movimientos', 'Expresa libremente'],
        resources: {'playlists': 'expressive_music', 'styles': 'free_movement'},
        requiresTimer: true,
        motivationalQuote: 'La danza es el lenguaje oculto del alma.',
      ),
      RecommendedActivity(
        id: 'creativity_8',
        title: 'Poesía Espontánea',
        description: 'Escribe un poema sobre tu día',
        category: 'Creatividad',
        type: ActivityType.creativity,
        durationMinutes: 15,
        difficultyLevel: 2,
        benefits: ['Procesa emociones', 'Mejora expresión', 'Estimula creatividad'],
        instructions: ['Piensa en tu día', 'Escribe sin preocuparte por reglas', 'Usa metáforas', 'Expresa tus sentimientos'],
        resources: {'structures': 'poetry_forms', 'inspiration': 'poetry_prompts'},
        requiresTimer: true,
        motivationalQuote: 'La poesía es la música del alma.',
      ),

      // SOCIAL & RELATIONSHIP (6 activities)
      RecommendedActivity(
        id: 'social_1',
        title: 'Llamada de Gratitud',
        description: 'Llama a alguien para expresar gratitud',
        category: 'Social',
        type: ActivityType.social,
        durationMinutes: 10,
        difficultyLevel: 1,
        benefits: ['Fortalece relaciones', 'Aumenta gratitud', 'Mejora conexión'],
        instructions: ['Piensa en alguien especial', 'Llama sin agenda', 'Expresa tu gratitud', 'Escucha activamente'],
        resources: {'phrases': 'gratitude_expressions', 'tips': 'meaningful_calls'},
        requiresTimer: true,
        motivationalQuote: 'La gratitud conecta corazones.',
      ),
      RecommendedActivity(
        id: 'social_2',
        title: 'Acto de Bondad',
        description: 'Realiza un acto de bondad aleatorio',
        category: 'Social',
        type: ActivityType.social,
        durationMinutes: 15,
        difficultyLevel: 1,
        benefits: ['Mejora humor', 'Crea conexión', 'Impacto positivo'],
        instructions: ['Piensa en algo pequeño pero significativo', 'Actúa sin esperar nada', 'Observa el impacto', 'Disfruta la experiencia'],
        resources: {'ideas': 'kindness_acts', 'inspiration': 'random_kindness'},
        requiresTimer: false,
        motivationalQuote: 'Ningún acto de bondad es demasiado pequeño.',
      ),
      RecommendedActivity(
        id: 'social_3',
        title: 'Conversación Profunda',
        description: 'Ten una conversación significativa',
        category: 'Social',
        type: ActivityType.social,
        durationMinutes: 20,
        difficultyLevel: 2,
        benefits: ['Profundiza relaciones', 'Mejora comunicación', 'Aumenta intimidad'],
        instructions: ['Elige a alguien de confianza', 'Haz preguntas abiertas', 'Escucha sin juzgar', 'Comparte auténticamente'],
        resources: {'questions': 'deep_conversation', 'techniques': 'active_listening'},
        requiresTimer: true,
        motivationalQuote: 'Las conversaciones profundas alimentan el alma.',
      ),
      RecommendedActivity(
        id: 'social_4',
        title: 'Mensaje de Aprecio',
        description: 'Envía un mensaje de aprecio sincero',
        category: 'Social',
        type: ActivityType.social,
        durationMinutes: 8,
        difficultyLevel: 1,
        benefits: ['Fortalece vínculos', 'Aumenta positividad', 'Mejora relaciones'],
        instructions: ['Piensa en alguien importante', 'Escribe desde el corazón', 'Sé específico', 'Envía sin esperar respuesta'],
        resources: {'templates': 'appreciation_messages', 'examples': 'heartfelt_messages'},
        requiresTimer: true,
        motivationalQuote: 'Las palabras de aprecio son regalos que no cuestan nada.',
      ),
      RecommendedActivity(
        id: 'social_5',
        title: 'Escucha Activa',
        description: 'Practica escuchar completamente a alguien',
        category: 'Social',
        type: ActivityType.social,
        durationMinutes: 15,
        difficultyLevel: 2,
        benefits: ['Mejora relaciones', 'Aumenta empatía', 'Fortalece conexión'],
        instructions: ['Pon atención completa', 'No interrumpas', 'Haz preguntas clarificadoras', 'Refleja lo que escuchas'],
        resources: {'techniques': 'active_listening', 'tips': 'empathetic_listening'},
        requiresTimer: true,
        motivationalQuote: 'Escuchar es un acto de amor.',
      ),
      RecommendedActivity(
        id: 'social_6',
        title: 'Tiempo de Calidad',
        description: 'Dedica tiempo de calidad a alguien especial',
        category: 'Social',
        type: ActivityType.social,
        durationMinutes: 30,
        difficultyLevel: 1,
        benefits: ['Fortalece vínculos', 'Crea memorias', 'Mejora bienestar'],
        instructions: ['Elimina distracciones', 'Enfócate en la persona', 'Disfruten actividades juntos', 'Crea momentos especiales'],
        resources: {'activities': 'quality_time_ideas', 'tips': 'meaningful_connections'},
        requiresTimer: true,
        motivationalQuote: 'El tiempo de calidad es el regalo más valioso.',
      ),

      // SELF-CARE & WELLNESS (8 activities)
      RecommendedActivity(
        id: 'selfcare_1',
        title: 'Baño Relajante',
        description: 'Toma un baño mindful para relajarte',
        category: 'Autocuidado',
        type: ActivityType.selfCare,
        durationMinutes: 20,
        difficultyLevel: 1,
        benefits: ['Reduce estrés', 'Relaja músculos', 'Mejora sueño'],
        instructions: ['Prepara agua tibia', 'Añade sales o aceites', 'Apaga dispositivos', 'Disfruta el momento'],
        resources: {'additions': 'bath_enhancements', 'safety': 'bath_safety'},
        requiresTimer: true,
        motivationalQuote: 'El autocuidado no es un lujo, es una necesidad.',
      ),
      RecommendedActivity(
        id: 'selfcare_2',
        title: 'Masaje Autocompasivo',
        description: 'Date un masaje suave para conectar contigo',
        category: 'Autocuidado',
        type: ActivityType.selfCare,
        durationMinutes: 15,
        difficultyLevel: 1,
        benefits: ['Reduce tensión', 'Aumenta autocompasión', 'Mejora circulación'],
        instructions: ['Masajea suavemente', 'Usa aceites si tienes', 'Enfócate en áreas tensas', 'Sé gentil contigo'],
        resources: {'techniques': 'self_massage', 'oils': 'massage_oils'},
        requiresTimer: true,
        motivationalQuote: 'Trátate con la misma gentileza que a un buen amigo.',
      ),
      RecommendedActivity(
        id: 'selfcare_3',
        title: 'Rutina de Cuidado Facial',
        description: 'Dedica tiempo a cuidar tu piel',
        category: 'Autocuidado',
        type: ActivityType.selfCare,
        durationMinutes: 12,
        difficultyLevel: 1,
        benefits: ['Cuida la piel', 'Momento de calma', 'Práctica de amor propio'],
        instructions: ['Limpia suavemente', 'Aplica productos con cuidado', 'Masajea suavemente', 'Disfruta el ritual'],
        resources: {'products': 'skincare_basics', 'routine': 'facial_care'},
        requiresTimer: true,
        motivationalQuote: 'Invierte en tu piel, te acompañará toda la vida.',
      ),
      RecommendedActivity(
        id: 'selfcare_4',
        title: 'Té Mindful',
        description: 'Prepara y disfruta té con atención plena',
        category: 'Autocuidado',
        type: ActivityType.selfCare,
        durationMinutes: 10,
        difficultyLevel: 1,
        benefits: ['Momento de calma', 'Práctica mindfulness', 'Hidratación'],
        instructions: ['Elige tu té favorito', 'Prepara conscientemente', 'Huele los aromas', 'Saborea cada sorbo'],
        resources: {'teas': 'herbal_teas', 'ceremony': 'tea_mindfulness'},
        requiresTimer: true,
        motivationalQuote: 'El té es tranquilidad líquida.',
      ),
      RecommendedActivity(
        id: 'selfcare_5',
        title: 'Organización Terapéutica',
        description: 'Organiza un espacio pequeño mindfully',
        category: 'Autocuidado',
        type: ActivityType.selfCare,
        durationMinutes: 15,
        difficultyLevel: 2,
        benefits: ['Reduce estrés', 'Mejora enfoque', 'Crea orden'],
        instructions: ['Elige un área pequeña', 'Ordena con intención', 'Observa cómo te sientes', 'Disfruta el resultado'],
        resources: {'areas': 'organizing_spots', 'techniques': 'mindful_organizing'},
        requiresTimer: true,
        motivationalQuote: 'Un espacio ordenado refleja una mente clara.',
      ),
      RecommendedActivity(
        id: 'selfcare_6',
        title: 'Lectura Relajante',
        description: 'Lee algo que te inspire y relaje',
        category: 'Autocuidado',
        type: ActivityType.selfCare,
        durationMinutes: 20,
        difficultyLevel: 1,
        benefits: ['Reduce estrés', 'Estimula mente', 'Momento de escape'],
        instructions: ['Elige algo que disfrutes', 'Encuentra lugar cómodo', 'Lee sin prisa', 'Absorbe las palabras'],
        resources: {'genres': 'relaxing_reading', 'positions': 'comfortable_reading'},
        requiresTimer: true,
        motivationalQuote: 'La lectura es el refugio del alma.',
      ),
      RecommendedActivity(
        id: 'selfcare_7',
        title: 'Aromaterapia Casera',
        description: 'Crea un ambiente relajante con aromas',
        category: 'Autocuidado',
        type: ActivityType.selfCare,
        durationMinutes: 5,
        difficultyLevel: 1,
        benefits: ['Mejora humor', 'Reduce estrés', 'Crea ambiente'],
        instructions: ['Elige aromas relajantes', 'Usa velas o aceites', 'Respira profundamente', 'Disfruta el ambiente'],
        resources: {'scents': 'relaxing_scents', 'safety': 'aromatherapy_safety'},
        requiresTimer: true,
        motivationalQuote: 'Los aromas despiertan memorias y calman el alma.',
      ),
      RecommendedActivity(
        id: 'selfcare_8',
        title: 'Siesta Reparadora',
        description: 'Toma una siesta consciente de 20 minutos',
        category: 'Autocuidado',
        type: ActivityType.selfCare,
        durationMinutes: 20,
        difficultyLevel: 1,
        benefits: ['Restaura energía', 'Mejora humor', 'Reduce fatiga'],
        instructions: ['Encuentra lugar cómodo', 'Oscurece la habitación', 'Relaja conscientemente', 'Despierta suavemente'],
        resources: {'environment': 'nap_setup', 'techniques': 'power_napping'},
        requiresTimer: true,
        motivationalQuote: 'Una siesta es una sonrisa del alma.',
      ),

      // GRATITUDE & REFLECTION (8 activities)
      RecommendedActivity(
        id: 'gratitude_1',
        title: 'Diario de Gratitud',
        description: 'Escribe 3 cosas por las que estás agradecido',
        category: 'Gratitud',
        type: ActivityType.gratitude,
        durationMinutes: 8,
        difficultyLevel: 1,
        benefits: ['Mejora perspectiva', 'Aumenta felicidad', 'Reduce negatividad'],
        instructions: ['Escribe 3 cosas específicas', 'Incluye por qué estás agradecido', 'Sé específico', 'Siente la gratitud'],
        resources: {'prompts': 'gratitude_prompts', 'techniques': 'gratitude_writing'},
        requiresTimer: true,
        motivationalQuote: 'La gratitud convierte lo que tenemos en suficiente.',
      ),
      RecommendedActivity(
        id: 'gratitude_2',
        title: 'Carta de Agradecimiento',
        description: 'Escribe una carta de agradecimiento a alguien',
        category: 'Gratitud',
        type: ActivityType.gratitude,
        durationMinutes: 15,
        difficultyLevel: 2,
        benefits: ['Fortalece relaciones', 'Aumenta gratitud', 'Mejora conexión'],
        instructions: ['Piensa en alguien especial', 'Escribe específicamente', 'Expresa cómo te ha impactado', 'Decide si enviarla'],
        resources: {'templates': 'gratitude_letters', 'examples': 'thank_you_notes'},
        requiresTimer: true,
        motivationalQuote: 'La gratitud expresada es un regalo para quien la recibe.',
      ),
      RecommendedActivity(
        id: 'reflection_1',
        title: 'Reflexión del Día',
        description: 'Reflexiona sobre las lecciones del día',
        category: 'Reflexión',
        type: ActivityType.reflection,
        durationMinutes: 10,
        difficultyLevel: 2,
        benefits: ['Aumenta autoconocimiento', 'Procesa experiencias', 'Mejora aprendizaje'],
        instructions: ['¿Qué aprendí hoy?', '¿Cómo me sentí?', '¿Qué haría diferente?', '¿Qué celebro?'],
        resources: {'questions': 'reflection_questions', 'techniques': 'daily_reflection'},
        requiresTimer: true,
        motivationalQuote: 'La reflexión es el camino hacia la sabiduría.',
      ),
      RecommendedActivity(
        id: 'reflection_2',
        title: 'Valores Personales',
        description: 'Reflexiona sobre tus valores fundamentales',
        category: 'Reflexión',
        type: ActivityType.reflection,
        durationMinutes: 20,
        difficultyLevel: 3,
        benefits: ['Clarifica propósito', 'Mejora decisiones', 'Aumenta autenticidad'],
        instructions: ['Lista tus valores principales', 'Reflexiona por qué son importantes', 'Evalúa si vives según ellos', 'Haz plan de alineación'],
        resources: {'values': 'core_values_list', 'exercises': 'values_clarification'},
        requiresTimer: true,
        motivationalQuote: 'Tus valores son tu brújula en la vida.',
      ),
      RecommendedActivity(
        id: 'reflection_3',
        title: 'Logros y Aprendizajes',
        description: 'Reflexiona sobre tus logros recientes',
        category: 'Reflexión',
        type: ActivityType.reflection,
        durationMinutes: 12,
        difficultyLevel: 2,
        benefits: ['Aumenta autoestima', 'Reconoce progreso', 'Motiva crecimiento'],
        instructions: ['Lista 3 logros recientes', 'Incluye logros pequeños', 'Reflexiona sobre el proceso', 'Celebra tu crecimiento'],
        resources: {'categories': 'achievement_areas', 'prompts': 'accomplishment_prompts'},
        requiresTimer: true,
        motivationalQuote: 'Cada logro es un paso hacia quien estás destinado a ser.',
      ),
      RecommendedActivity(
        id: 'reflection_4',
        title: 'Visión de Futuro',
        description: 'Visualiza tu yo futuro ideal',
        category: 'Reflexión',
        type: ActivityType.reflection,
        durationMinutes: 15,
        difficultyLevel: 2,
        benefits: ['Clarifica metas', 'Aumenta motivación', 'Mejora dirección'],
        instructions: ['Visualiza tu vida ideal', 'Incluye todos los aspectos', 'Sé específico', 'Siente las emociones'],
        resources: {'areas': 'life_domains', 'techniques': 'future_visualization'},
        requiresTimer: true,
        motivationalQuote: 'El futuro pertenece a quienes pueden imaginarlo.',
      ),
      RecommendedActivity(
        id: 'reflection_5',
        title: 'Perdón y Liberación',
        description: 'Reflexiona sobre el perdón hacia ti mismo',
        category: 'Reflexión',
        type: ActivityType.reflection,
        durationMinutes: 18,
        difficultyLevel: 3,
        benefits: ['Libera culpa', 'Mejora autocompasión', 'Reduce estrés'],
        instructions: ['Identifica autojuicios', 'Practica autocompasión', 'Libera la culpa', 'Abraza el crecimiento'],
        resources: {'techniques': 'self_forgiveness', 'practices': 'self_compassion'},
        requiresTimer: true,
        motivationalQuote: 'El perdón es un regalo que te das a ti mismo.',
      ),
      RecommendedActivity(
        id: 'reflection_6',
        title: 'Intenciones Semanales',
        description: 'Establece intenciones para la próxima semana',
        category: 'Reflexión',
        type: ActivityType.reflection,
        durationMinutes: 10,
        difficultyLevel: 2,
        benefits: ['Mejora enfoque', 'Aumenta propósito', 'Guía acciones'],
        instructions: ['Reflexiona sobre la semana pasada', 'Establece 3 intenciones', 'Sé específico', 'Visualiza el éxito'],
        resources: {'templates': 'weekly_intentions', 'examples': 'intention_examples'},
        requiresTimer: true,
        motivationalQuote: 'Las intenciones claras crean resultados poderosos.',
      ),
    ];
  }

  /// Generate daily recommendations (2 activities per day)
  void _generateDailyRecommendations() {
    final today = DateTime.now();
    
    // Check if we need to generate new recommendations
    if (_lastRecommendationDate == null ||
        !_isSameDay(_lastRecommendationDate!, today)) {
      
      _logger.d('🎯 Generating daily recommendations for ${today.toLocal()}');
      
      // Filter activities that haven't been recommended recently
      final availableActivities = _allActivities.where((activity) {
        return !activity.isRecommendedToday;
      }).toList();
      
      // If we have fewer than 2 available activities, reset all
      if (availableActivities.length < 2) {
        _resetAllActivities();
        availableActivities.clear();
        availableActivities.addAll(_allActivities);
      }
      
      // Select 2 random activities from different categories
      _dailyRecommendations = _selectDiverseActivities(availableActivities, 2);
      
      // Mark as recommended today
      for (var activity in _dailyRecommendations) {
        final updatedActivity = activity.copyWith(lastRecommended: today);
        final index = _allActivities.indexWhere((a) => a.id == activity.id);
        if (index != -1) {
          _allActivities[index] = updatedActivity;
        }
      }
      
      _lastRecommendationDate = today;
      _logger.i('✅ Generated ${_dailyRecommendations.length} daily recommendations');
    } else {
      _logger.d('📅 Using existing recommendations for today');
    }
  }

  /// Select activities from different categories to ensure diversity
  List<RecommendedActivity> _selectDiverseActivities(
    List<RecommendedActivity> activities, 
    int count
  ) {
    final selected = <RecommendedActivity>[];
    final usedCategories = <String>{};
    final shuffled = List<RecommendedActivity>.from(activities)..shuffle(_random);
    
    // First pass: select activities from different categories
    for (var activity in shuffled) {
      if (selected.length >= count) break;
      
      if (!usedCategories.contains(activity.category)) {
        selected.add(activity);
        usedCategories.add(activity.category);
      }
    }
    
    // Second pass: fill remaining slots if needed
    while (selected.length < count && selected.length < activities.length) {
      final remaining = activities.where((a) => !selected.contains(a)).toList();
      if (remaining.isEmpty) break;
      
      selected.add(remaining[_random.nextInt(remaining.length)]);
    }
    
    return selected;
  }

  /// Reset all activities' recommendation dates
  void _resetAllActivities() {
    _allActivities = _allActivities.map((activity) => 
      activity.copyWith(lastRecommended: null)
    ).toList();
    _logger.d('🔄 Reset all activity recommendation dates');
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Get activities by category
  List<RecommendedActivity> getActivitiesByCategory(String category) {
    return _allActivities.where((activity) => 
      activity.category == category
    ).toList();
  }

  /// Get activities by type
  List<RecommendedActivity> getActivitiesByType(ActivityType type) {
    return _allActivities.where((activity) => 
      activity.type == type
    ).toList();
  }

  /// Get activities by difficulty level
  List<RecommendedActivity> getActivitiesByDifficulty(int level) {
    return _allActivities.where((activity) => 
      activity.difficultyLevel == level
    ).toList();
  }

  /// Get activities by duration range
  List<RecommendedActivity> getActivitiesByDuration(int minMinutes, int maxMinutes) {
    return _allActivities.where((activity) => 
      activity.durationMinutes >= minMinutes && 
      activity.durationMinutes <= maxMinutes
    ).toList();
  }

  /// Complete an activity
  Future<void> completeActivity(
    String activityId, 
    int actualDuration, 
    double rating,
    {String? notes}
  ) async {
    _logger.d('✅ Completing activity: $activityId');
    
    try {
      final completion = ActivityCompletion(
        activityId: activityId,
        completedAt: DateTime.now(),
        durationMinutes: actualDuration,
        rating: rating,
        notes: notes,
      );
      
      _completedActivities.add(completion);
      
      // Update activity completion count
      final activityIndex = _allActivities.indexWhere((a) => a.id == activityId);
      if (activityIndex != -1) {
        final activity = _allActivities[activityIndex];
        final newCompletionCount = activity.timesCompleted + 1;
        final newAverageRating = (activity.averageRating * activity.timesCompleted + rating) / newCompletionCount;
        
        _allActivities[activityIndex] = activity.copyWith(
          timesCompleted: newCompletionCount,
          averageRating: newAverageRating,
        );
      }
      
      _logger.i('✅ Activity completed successfully');
      notifyListeners();
      
    } catch (e) {
      _logger.e('❌ Error completing activity: $e');
      _setError('Error al completar actividad');
    }
  }

  /// Get completion statistics
  Map<String, dynamic> getCompletionStats() {
    final completions = _completedActivities;
    
    if (completions.isEmpty) {
      return {
        'total_completions': 0,
        'average_rating': 0.0,
        'favorite_categories': <String>[],
        'total_time': 0,
        'streak_days': 0,
      };
    }
    
    final totalCompletions = completions.length;
    final averageRating = completions.fold<double>(
      0.0, (sum, completion) => sum + completion.rating
    ) / totalCompletions;
    
    final totalTime = completions.fold<int>(
      0, (sum, completion) => sum + completion.durationMinutes
    );
    
    // Calculate favorite categories
    final categoryCount = <String, int>{};
    for (var completion in completions) {
      final activity = _allActivities.firstWhere(
        (a) => a.id == completion.activityId,
        orElse: () => _allActivities.first,
      );
      categoryCount[activity.category] = (categoryCount[activity.category] ?? 0) + 1;
    }
    
    final favoriteCategories = categoryCount.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    
    return {
      'total_completions': totalCompletions,
      'average_rating': averageRating,
      'favorite_categories': favoriteCategories.take(3).map((e) => e.key).toList(),
      'total_time': totalTime,
      'streak_days': _calculateStreak(),
    };
  }

  /// Calculate current completion streak
  int _calculateStreak() {
    if (_completedActivities.isEmpty) return 0;
    
    final sortedCompletions = _completedActivities.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    var streak = 0;
    var currentDate = DateTime.now();
    
    for (var completion in sortedCompletions) {
      if (_isSameDay(completion.completedAt, currentDate) ||
          _isSameDay(completion.completedAt, currentDate.subtract(const Duration(days: 1)))) {
        streak++;
        currentDate = completion.completedAt.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Refresh daily recommendations
  void refreshDailyRecommendations() {
    _lastRecommendationDate = null;
    _generateDailyRecommendations();
    notifyListeners();
  }

  /// Get random activity from category
  RecommendedActivity? getRandomActivityFromCategory(String category) {
    final categoryActivities = getActivitiesByCategory(category);
    if (categoryActivities.isEmpty) return null;
    
    return categoryActivities[_random.nextInt(categoryActivities.length)];
  }

  /// Search activities
  List<RecommendedActivity> searchActivities(String query) {
    final lowerQuery = query.toLowerCase();
    return _allActivities.where((activity) =>
      activity.title.toLowerCase().contains(lowerQuery) ||
      activity.description.toLowerCase().contains(lowerQuery) ||
      activity.category.toLowerCase().contains(lowerQuery) ||
      activity.benefits.any((benefit) => benefit.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  // Helper methods
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _logger.d('🧹 Disposing RecommendedActivitiesProvider');
    super.dispose();
  }
}