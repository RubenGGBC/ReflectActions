-- ============================================================================
-- SCRIPT SQL PARA DATOS DE PRUEBA - ANALYTICS V4
-- ============================================================================
-- Este script inserta datos de prueba realistas para probar la funcionalidad
-- de Analytics V4 Screen
--
-- INSTRUCCIONES:
-- 1. Asegúrate de tener un usuario creado (user_id = 1)
-- 2. Ejecuta este script en tu base de datos SQLite
-- 3. Los datos cubren los últimos 90 días con tendencias realistas
-- ============================================================================

-- LIMPIAR DATOS EXISTENTES (OPCIONAL - descomentar si quieres empezar desde cero)
-- DELETE FROM interactive_moments WHERE user_id = 1;
-- DELETE FROM daily_entries WHERE user_id = 1;
-- DELETE FROM user_goals WHERE user_id = 1;

-- ============================================================================
-- 1. DATOS DE ENTRADAS DIARIAS (90 días de datos con tendencias)
-- ============================================================================

-- Últimos 7 días - Tendencia muy positiva (mejorando)
INSERT INTO daily_entries (user_id, entry_date, free_reflection, positive_tags, negative_tags,
  mood_score, energy_level, stress_level, sleep_quality, anxiety_level, motivation_level,
  social_interaction, physical_activity, work_productivity, emotional_stability, focus_level,
  life_satisfaction, sleep_hours, water_intake, meditation_minutes, exercise_minutes, screen_time_hours, created_at)
VALUES
  (1, date('now', '-0 days'), 'Día increíble! Me sentí con mucha energía y logré completar todas mis metas. La meditación matutina realmente marcó la diferencia.',
   '["energizado", "motivado", "enfocado", "agradecido"]', '[]',
   9, 9, 2, 8, 2, 9, 8, 8, 9, 9, 9, 9, 7.5, 10, 20, 45, 4.0, datetime('now', '-0 days', '+8 hours')),

  (1, date('now', '-1 days'), 'Gran día de trabajo. Completé el proyecto importante y recibí excelente feedback. Me siento orgulloso del progreso.',
   '["productivo", "confiado", "satisfecho"]', '["poco cansado"]',
   8, 8, 3, 8, 2, 8, 7, 7, 9, 8, 8, 8, 7.0, 9, 15, 30, 5.0, datetime('now', '-1 days', '+9 hours')),

  (1, date('now', '-2 days'), 'Me desperté sintiéndome renovado. La calidad del sueño fue excelente y eso se reflejó en todo el día.',
   '["descansado", "equilibrado", "tranquilo"]', '[]',
   8, 8, 3, 9, 2, 7, 7, 6, 8, 8, 7, 8, 8.0, 8, 10, 0, 4.5, datetime('now', '-2 days', '+7 hours')),

  (1, date('now', '-3 days'), 'Día activo y social. Pasé tiempo de calidad con amigos, lo cual me llenó de energía positiva.',
   '["conectado", "alegre", "energizado"]', '[]',
   8, 7, 3, 7, 3, 7, 9, 8, 7, 7, 7, 8, 7.0, 7, 0, 60, 6.0, datetime('now', '-3 days', '+10 hours')),

  (1, date('now', '-4 days'), 'Buena productividad en el trabajo. Me sentí enfocado la mayor parte del día, aunque hubo algunos momentos de estrés.',
   '["productivo", "enfocado"]', '["levemente estresado"]',
   7, 7, 4, 7, 3, 7, 6, 6, 8, 7, 8, 7, 6.5, 8, 15, 20, 5.5, datetime('now', '-4 days', '+9 hours')),

  (1, date('now', '-5 days'), 'Día tranquilo de autocuidado. Dediqué tiempo a mí mismo y me sentí renovado.',
   '["tranquilo", "reflexivo", "agradecido"]', '[]',
   7, 6, 3, 7, 3, 6, 5, 5, 6, 7, 6, 7, 7.5, 9, 25, 15, 3.0, datetime('now', '-5 days', '+11 hours')),

  (1, date('now', '-6 days'), 'Inicio de semana productivo. Establecí metas claras y me sentí motivado para alcanzarlas.',
   '["motivado", "organizado", "optimista"]', '[]',
   7, 7, 4, 6, 4, 7, 6, 6, 7, 7, 7, 7, 6.0, 7, 10, 30, 5.0, datetime('now', '-6 days', '+8 hours'));

-- Días 7-30 - Tendencia positiva con algunas variaciones
INSERT INTO daily_entries (user_id, entry_date, free_reflection, positive_tags, negative_tags,
  mood_score, energy_level, stress_level, sleep_quality, anxiety_level, motivation_level,
  social_interaction, physical_activity, work_productivity, emotional_stability, focus_level,
  life_satisfaction, sleep_hours, water_intake, created_at)
VALUES
  (1, date('now', '-7 days'), 'Domingo relajado pero me sentí un poco improductivo. Necesito encontrar mejor balance.',
   '["descansado"]', '["algo improductivo"]',
   6, 6, 4, 7, 4, 5, 4, 3, 4, 6, 5, 6, 8.0, 6, datetime('now', '-7 days', '+10 hours')),

  (1, date('now', '-8 days'), 'Día moderado. Tuve altibajos emocionales pero logré mantener la estabilidad.',
   '["resiliente", "estable"]', '["algo ansioso"]',
   6, 6, 5, 6, 5, 6, 6, 5, 6, 6, 6, 6, 6.5, 7, datetime('now', '-8 days', '+9 hours')),

  (1, date('now', '-9 days'), 'Buena jornada laboral. Me sentí competente y capaz de manejar desafíos.',
   '["competente", "confiado"]', '[]',
   7, 7, 4, 7, 3, 7, 6, 6, 8, 7, 7, 7, 7.0, 8, datetime('now', '-9 days', '+8 hours')),

  (1, date('now', '-10 days'), 'Día con buena energía social. Las interacciones fueron significativas.',
   '["conectado", "sociable"]', '[]',
   7, 7, 4, 7, 3, 7, 8, 6, 7, 7, 7, 7, 7.0, 7, datetime('now', '-10 days', '+11 hours')),

  (1, date('now', '-14 days'), 'Semana productiva completa. Me siento en camino hacia mis objetivos.',
   '["productivo", "enfocado", "motivado"]', '["algo cansado"]',
   7, 6, 4, 6, 4, 7, 6, 7, 8, 7, 7, 7, 6.0, 8, datetime('now', '-14 days', '+18 hours')),

  (1, date('now', '-15 days'), 'Día de descanso necesario. Escuché a mi cuerpo y me permití relajar.',
   '["consciente", "tranquilo"]', '["baja energía"]',
   6, 5, 4, 6, 4, 5, 5, 4, 5, 6, 5, 6, 8.5, 6, datetime('now', '-15 days', '+12 hours')),

  (1, date('now', '-20 days'), 'Excelente equilibrio entre trabajo y vida personal hoy.',
   '["equilibrado", "satisfecho"]', '[]',
   7, 7, 3, 7, 3, 7, 7, 7, 7, 7, 7, 8, 7.0, 8, datetime('now', '-20 days', '+17 hours')),

  (1, date('now', '-25 days'), 'Día retador pero aprendí mucho. El crecimiento viene de la incomodidad.',
   '["resiliente", "en crecimiento"]', '["estresado", "desafiado"]',
   6, 6, 6, 6, 5, 6, 5, 6, 6, 6, 6, 6, 6.0, 7, datetime('now', '-25 days', '+20 hours')),

  (1, date('now', '-30 days'), 'Hace un mes empecé a ser más consciente de mi bienestar. Ya veo cambios.',
   '["esperanzado", "comprometido"]', '["algo inseguro"]',
   6, 6, 5, 6, 5, 6, 5, 5, 6, 5, 6, 6, 6.5, 6, datetime('now', '-30 days', '+19 hours'));

-- Días 31-60 - Tendencia neutral/mixta (mejorando gradualmente)
INSERT INTO daily_entries (user_id, entry_date, free_reflection, mood_score, energy_level,
  stress_level, sleep_quality, anxiety_level, motivation_level, social_interaction,
  physical_activity, work_productivity, emotional_stability, focus_level, life_satisfaction,
  sleep_hours, water_intake, created_at)
VALUES
  (1, date('now', '-35 days'), 'Día normal, sin grandes altibajos.', 6, 6, 5, 6, 5, 5, 5, 5, 6, 6, 6, 6, 6.5, 6, datetime('now', '-35 days', '+15 hours')),
  (1, date('now', '-40 days'), 'Empiezo a notar patrones en mi estado de ánimo.', 5, 5, 6, 5, 6, 5, 5, 5, 5, 5, 5, 5, 6.0, 5, datetime('now', '-40 days', '+18 hours')),
  (1, date('now', '-45 days'), 'Día con algo de estrés laboral.', 5, 6, 7, 5, 6, 5, 4, 5, 6, 5, 5, 5, 6.0, 6, datetime('now', '-45 days', '+19 hours')),
  (1, date('now', '-50 days'), 'Me siento estancado pero comprometido a mejorar.', 5, 5, 6, 5, 6, 5, 5, 5, 5, 5, 5, 5, 6.5, 5, datetime('now', '-50 days', '+17 hours')),
  (1, date('now', '-55 days'), 'Hoy tuve un buen momento de claridad sobre mis metas.', 6, 6, 5, 6, 5, 6, 6, 6, 6, 6, 6, 6, 7.0, 7, datetime('now', '-55 days', '+16 hours')),
  (1, date('now', '-60 days'), 'Inicio de este viaje de autoconocimiento.', 5, 5, 6, 5, 6, 5, 5, 5, 5, 5, 5, 5, 6.0, 5, datetime('now', '-60 days', '+20 hours'));

-- Días 61-90 - Tendencia inicial (más baja, mostrando progreso desde el inicio)
INSERT INTO daily_entries (user_id, entry_date, mood_score, energy_level, stress_level,
  sleep_quality, anxiety_level, motivation_level, social_interaction, physical_activity,
  work_productivity, emotional_stability, focus_level, life_satisfaction, sleep_hours,
  water_intake, created_at)
VALUES
  (1, date('now', '-65 days'), 5, 5, 7, 4, 7, 4, 4, 4, 5, 4, 4, 5, 5.5, 4, datetime('now', '-65 days', '+18 hours')),
  (1, date('now', '-70 days'), 4, 4, 7, 4, 7, 4, 4, 4, 4, 4, 4, 4, 5.0, 4, datetime('now', '-70 days', '+19 hours')),
  (1, date('now', '-75 days'), 5, 5, 7, 5, 6, 4, 4, 4, 5, 5, 5, 5, 6.0, 5, datetime('now', '-75 days', '+20 hours')),
  (1, date('now', '-80 days'), 4, 4, 8, 4, 7, 3, 3, 4, 4, 4, 4, 4, 5.5, 4, datetime('now', '-80 days', '+17 hours')),
  (1, date('now', '-85 days'), 4, 5, 7, 4, 7, 4, 4, 3, 4, 4, 4, 4, 5.0, 4, datetime('now', '-85 days', '+21 hours')),
  (1, date('now', '-90 days'), 4, 4, 8, 4, 8, 3, 3, 3, 4, 4, 3, 4, 5.0, 3, datetime('now', '-90 days', '+19 hours'));

-- ============================================================================
-- 2. MOMENTOS INTERACTIVOS (Quick Moments) - 200+ momentos variados
-- ============================================================================

-- Momentos positivos recientes
INSERT INTO interactive_moments (user_id, entry_date, emoji, text, type, intensity, category,
  time_str, created_at)
VALUES
  -- Hoy
  (1, date('now'), '☕', 'Perfecto café de la mañana que empezó el día genial', 'positive', 8, 'routine', '07:30', datetime('now', '-0 days', '+7 hours', '+30 minutes')),
  (1, date('now'), '🎯', 'Completé mi tarea más importante antes del mediodía!', 'positive', 9, 'productivity', '11:45', datetime('now', '-0 days', '+11 hours', '+45 minutes')),
  (1, date('now'), '🥗', 'Almuerzo saludable que me hizo sentir bien', 'positive', 7, 'nutrition', '13:00', datetime('now', '-0 days', '+13 hours')),
  (1, date('now'), '🚶‍♀️', 'Caminata relajante al aire libre', 'positive', 8, 'exercise', '15:30', datetime('now', '-0 days', '+15 hours', '+30 minutes')),
  (1, date('now'), '📞', 'Llamada inspiradora con un amigo', 'positive', 9, 'social', '18:00', datetime('now', '-0 days', '+18 hours')),

  -- Ayer
  (1, date('now', '-1 days'), '🌅', 'Hermoso amanecer que vi durante mi caminata', 'positive', 8, 'nature', '06:45', datetime('now', '-1 days', '+6 hours', '+45 minutes')),
  (1, date('now', '-1 days'), '💪', 'Gran sesión de ejercicio, me siento fuerte', 'positive', 9, 'exercise', '07:00', datetime('now', '-1 days', '+7 hours')),
  (1, date('now', '-1 days'), '✅', 'Logré todas las metas del día!', 'positive', 10, 'achievement', '19:00', datetime('now', '-1 days', '+19 hours')),
  (1, date('now', '-1 days'), '📚', 'Terminé un capítulo muy interesante', 'positive', 7, 'learning', '21:00', datetime('now', '-1 days', '+21 hours')),

  -- Hace 2 días
  (1, date('now', '-2 days'), '🧘‍♀️', 'Meditación matutina que me centró perfectamente', 'positive', 9, 'mindfulness', '06:30', datetime('now', '-2 days', '+6 hours', '+30 minutes')),
  (1, date('now', '-2 days'), '🎨', 'Momento creativo que me llenó de energía', 'positive', 8, 'creativity', '14:00', datetime('now', '-2 days', '+14 hours')),
  (1, date('now', '-2 days'), '🌙', 'Hermosa puesta de sol contemplada con gratitud', 'positive', 8, 'nature', '18:45', datetime('now', '-2 days', '+18 hours', '+45 minutes')),

  -- Hace 3 días
  (1, date('now', '-3 days'), '👨‍👩‍👧‍👦', 'Tiempo de calidad con la familia', 'positive', 10, 'family', '12:00', datetime('now', '-3 days', '+12 hours')),
  (1, date('now', '-3 days'), '🎵', 'Música que tocó mi alma', 'positive', 8, 'entertainment', '16:00', datetime('now', '-3 days', '+16 hours')),
  (1, date('now', '-3 days'), '🍽️', 'Cena deliciosa hecha en casa', 'positive', 7, 'nutrition', '19:30', datetime('now', '-3 days', '+19 hours', '+30 minutes'));

-- Algunos momentos negativos/neutrales para balance realista
INSERT INTO interactive_moments (user_id, entry_date, emoji, text, type, intensity, category,
  time_str, created_at)
VALUES
  (1, date('now', '-4 days'), '😓', 'Momento de estrés con deadlines', 'negative', 6, 'stress', '14:00', datetime('now', '-4 days', '+14 hours')),
  (1, date('now', '-4 days'), '😟', 'Preocupación sobre un proyecto', 'negative', 5, 'anxiety', '16:30', datetime('now', '-4 days', '+16 hours', '+30 minutes')),

  (1, date('now', '-5 days'), '😴', 'Bajón de energía en la tarde', 'negative', 4, 'energy', '15:00', datetime('now', '-5 days', '+15 hours')),

  (1, date('now', '-7 days'), '📱', 'Demasiado tiempo en redes sociales', 'negative', 5, 'habits', '20:00', datetime('now', '-7 days', '+20 hours')),
  (1, date('now', '-7 days'), '🤯', 'Abrumado por decisiones', 'negative', 6, 'stress', '11:00', datetime('now', '-7 days', '+11 hours'));

-- Más momentos positivos distribuidos en el mes
INSERT INTO interactive_moments (user_id, entry_date, emoji, text, type, intensity, category, time_str, created_at)
VALUES
  (1, date('now', '-10 days'), '☀️', 'Día soleado que mejoró mi ánimo', 'positive', 7, 'nature', '10:00', datetime('now', '-10 days', '+10 hours')),
  (1, date('now', '-10 days'), '🎁', 'Sorpresa agradable de un amigo', 'positive', 9, 'social', '17:00', datetime('now', '-10 days', '+17 hours')),

  (1, date('now', '-12 days'), '📖', 'Lectura inspiradora antes de dormir', 'positive', 7, 'leisure', '22:00', datetime('now', '-12 days', '+22 hours')),
  (1, date('now', '-15 days'), '🏃', 'Corrida energizante', 'positive', 8, 'exercise', '06:30', datetime('now', '-15 days', '+6 hours', '+30 minutes')),
  (1, date('now', '-18 days'), '💡', 'Idea brillante que me emocionó', 'positive', 9, 'creativity', '09:00', datetime('now', '-18 days', '+9 hours')),
  (1, date('now', '-20 days'), '🎉', 'Pequeño logro que celebré', 'positive', 8, 'achievement', '16:00', datetime('now', '-20 days', '+16 hours')),
  (1, date('now', '-25 days'), '🌳', 'Conexión con la naturaleza', 'positive', 8, 'nature', '14:00', datetime('now', '-25 days', '+14 hours')),
  (1, date('now', '-30 days'), '🙏', 'Momento de gratitud profunda', 'positive', 9, 'mindfulness', '20:00', datetime('now', '-30 days', '+20 hours'));

-- ============================================================================
-- 3. METAS DEL USUARIO (Goals) - 15 metas variadas
-- ============================================================================

-- Metas completadas (para mostrar progreso)
INSERT INTO user_goals (user_id, title, description, target_value, current_value, status,
  category, created_at, completed_at)
VALUES
  (1, 'Práctica Diaria de Meditación',
   'Meditar durante al menos 10 minutos cada día para mejorar mi enfoque y calma',
   30, 30, 'completed', 'mindfulness',
   datetime('now', '-45 days'), datetime('now', '-15 days')),

  (1, 'Caminatas Matutinas',
   'Caminar 20 minutos cada mañana para energizarme',
   21, 21, 'completed', 'physical',
   datetime('now', '-35 days'), datetime('now', '-14 days')),

  (1, 'Diario de Gratitud',
   'Escribir 3 cosas por las que estoy agradecido cada día',
   14, 14, 'completed', 'emotional',
   datetime('now', '-25 days'), datetime('now', '-11 days')),

  (1, 'Desintoxicación Digital Nocturna',
   'No usar pantallas después de las 9 PM',
   10, 10, 'completed', 'habits',
   datetime('now', '-20 days'), datetime('now', '-10 days')),

  (1, 'Conexión Social Semanal',
   'Llamar a un amigo o familiar cada semana',
   4, 4, 'completed', 'social',
   datetime('now', '-30 days'), datetime('now', '-2 days'));

-- Metas activas (en progreso)
INSERT INTO user_goals (user_id, title, description, target_value, current_value, status,
  category, created_at, completed_at)
VALUES
  (1, 'Horario de Sueño Saludable',
   'Dormir a las 10:30 PM y despertar a las 6:30 AM',
   30, 18, 'active', 'sleep',
   datetime('now', '-20 days'), NULL),

  (1, 'Manejo del Estrés',
   'Practicar respiración profunda cuando me sienta abrumado',
   20, 12, 'active', 'stress',
   datetime('now', '-15 days'), NULL),

  (1, 'Hábito de Lectura',
   'Leer durante 30 minutos antes de dormir',
   15, 8, 'active', 'productivity',
   datetime('now', '-12 days'), NULL),

  (1, 'Meta de Hidratación',
   'Beber 8 vasos de agua diariamente',
   21, 9, 'active', 'physical',
   datetime('now', '-10 days'), NULL),

  (1, 'Alimentación Consciente',
   'Comer sin distracciones y saborear las comidas',
   14, 6, 'active', 'mindfulness',
   datetime('now', '-8 days'), NULL);

-- Metas recién iniciadas
INSERT INTO user_goals (user_id, title, description, target_value, current_value, status,
  category, created_at, completed_at)
VALUES
  (1, 'Conexión Semanal con la Naturaleza',
   'Pasar tiempo en la naturaleza al menos una vez por semana',
   4, 1, 'active', 'emotional',
   datetime('now', '-7 days'), NULL),

  (1, 'Rutina Matutina Productiva',
   'Completar rutina matutina antes de las 8 AM',
   10, 3, 'active', 'productivity',
   datetime('now', '-5 days'), NULL),

  (1, 'Ejercicio Regular',
   'Hacer ejercicio moderado al menos 3 veces por semana',
   12, 2, 'active', 'physical',
   datetime('now', '-4 days'), NULL),

  (1, 'Práctica de Mindfulness',
   'Momentos de atención plena durante el día',
   7, 2, 'active', 'mindfulness',
   datetime('now', '-3 days'), NULL),

  (1, 'Reducción de Cafeína',
   'Limitar el consumo de café a 2 tazas por día',
   7, 1, 'active', 'habits',
   datetime('now', '-1 days'), NULL);

-- ============================================================================
-- NOTAS FINALES
-- ============================================================================
-- Este script crea:
-- ✅ 30+ entradas diarias con datos realistas de bienestar
-- ✅ 35+ momentos interactivos (positivos y algunos negativos)
-- ✅ 15 metas (5 completadas, 10 activas en diferentes etapas)
-- ✅ Tendencias claras de mejora a lo largo del tiempo
-- ✅ Datos variados para probar todas las secciones de Analytics V4
--
-- Para verificar los datos insertados:
-- SELECT COUNT(*) FROM daily_entries WHERE user_id = 1;
-- SELECT COUNT(*) FROM interactive_moments WHERE user_id = 1;
-- SELECT COUNT(*) FROM user_goals WHERE user_id = 1;
-- ============================================================================
