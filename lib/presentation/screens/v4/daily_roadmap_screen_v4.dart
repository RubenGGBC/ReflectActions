// ============================================================================
// daily_roadmap_screen_v4.dart - DAILY ROADMAP V4 — MINIMAL NAVY DESIGN
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/roadmap_activity_model.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/optimized_providers.dart';
import '../v2/components/add_activity_modal.dart';
import '../v2/components/edit_activity_modal.dart';

// ── Design tokens ────────────────────────────────────────────────────────────
const _bg = Color(0xFF0A0E1A);
const _card = Color(0xFF141B2D);
const _cardVariant = Color(0xFF1E2A3F);
const _borderBlue = Color(0xFF1E3A8A);
const _accentBlue = Color(0xFF3B82F6);
const _accentPurple = Color(0xFF7C3AED);
const _positive = Color(0xFF10B981);
const _textPrimary = Color(0xFFE8EAF0);
const _textSecondary = Color(0xFFB3B8C8);
const _textMuted = Color(0xFF8691A8);

const _gradientAccent = LinearGradient(
  colors: [_borderBlue, _accentPurple],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const _monoStyle = TextStyle(fontFamily: 'JetBrains Mono');
const _sansStyle = TextStyle(fontFamily: 'Geist');

// ── Screen ───────────────────────────────────────────────────────────────────

class DailyRoadmapScreenV4 extends StatefulWidget {
  const DailyRoadmapScreenV4({super.key});

  @override
  State<DailyRoadmapScreenV4> createState() => _DailyRoadmapScreenV4State();
}

class _DailyRoadmapScreenV4State extends State<DailyRoadmapScreenV4>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initProvider());
  }

  Future<void> _initProvider() async {
    if (!mounted) return;
    final auth = context.read<OptimizedAuthProvider>();
    if (auth.currentUser != null) {
      await context.read<DailyRoadmapProvider>().initialize(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<DailyRoadmapProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: provider.isLoading
                ? _buildLoading()
                : _buildBody(context, provider),
          ),
        );
      },
    );
  }

  // ── Scaffolding ─────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: _accentBlue,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildBody(BuildContext context, DailyRoadmapProvider provider) {
    return Column(
      children: [
        _buildStatusBar(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider),
                  const SizedBox(height: 20),
                  _buildProgressSection(provider),
                  const SizedBox(height: 20),
                  _buildMetricsRow(provider),
                  const SizedBox(height: 20),
                  _buildActivitiesSection(context, provider),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Status bar ──────────────────────────────────────────────────────────────

  Widget _buildStatusBar() {
    final now = TimeOfDay.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$h:$m',
              style: _sansStyle.copyWith(
                fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary,
              ),
            ),
            const Icon(Icons.battery_full_rounded, color: _textPrimary, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(DailyRoadmapProvider provider) {
    final auth = context.read<OptimizedAuthProvider>();
    final firstName = auth.currentUser?.name.split(' ').first ?? 'tú';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(provider.selectedDate),
          style: _sansStyle.copyWith(
            fontSize: 11, fontWeight: FontWeight.w500,
            letterSpacing: 2, color: _textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text('Buenos días,',
          style: _sansStyle.copyWith(
            fontSize: 32, fontWeight: FontWeight.w300,
            color: _textPrimary, height: 1.1,
          ),
        ),
        Text('$firstName.',
          style: _sansStyle.copyWith(
            fontSize: 32, fontWeight: FontWeight.w600,
            color: _accentBlue, height: 1.1,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
    ];
    const days = [
      'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO',
    ];
    final weekday = days[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} DE $month';
  }

  // ── Progress section ─────────────────────────────────────────────────────────

  Widget _buildProgressSection(DailyRoadmapProvider provider) {
    final completed = provider.completedActivities;
    final total = provider.totalActivities;
    final fraction = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final pctLabel = total > 0
        ? '${(fraction * 100).toStringAsFixed(0)}% completado'
        : 'sin actividades';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$completed',
                  style: _monoStyle.copyWith(
                    fontSize: 52, fontWeight: FontWeight.w300,
                    color: _textPrimary, height: 0.85,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('de $total',
                    style: _monoStyle.copyWith(
                      fontSize: 22, fontWeight: FontWeight.w300,
                      color: _textMuted,
                    ),
                  ),
                ),
              ],
            ),
            Text(pctLabel,
              style: _sansStyle.copyWith(fontSize: 12, color: _textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            width: double.infinity,
            height: 3,
            child: Stack(
              children: [
                Container(color: _cardVariant),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction,
                  child: Container(
                    decoration: const BoxDecoration(gradient: _gradientAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Metrics row ──────────────────────────────────────────────────────────────

  Widget _buildMetricsRow(DailyRoadmapProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'ENFOQUE',
            value: _focusedTime(provider),
            sub: 'tiempo activo',
            valueColor: _textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'PRÓXIMA',
            value: _nextActivityTime(provider),
            sub: _nextActivityTitle(provider),
            valueColor: _accentBlue,
          ),
        ),
      ],
    );
  }

  String _focusedTime(DailyRoadmapProvider provider) {
    final totalMin = provider.activitiesByTime
        .where((a) => a.isCompleted)
        .fold(0, (sum, a) => sum + (a.estimatedDuration ?? 0));
    if (totalMin == 0) return '—';
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _nextActivityTime(DailyRoadmapProvider provider) =>
      provider.upcomingActivities.firstOrNull?.timeString ?? '—';

  String _nextActivityTitle(DailyRoadmapProvider provider) =>
      provider.upcomingActivities.firstOrNull?.title ?? 'sin pendientes';

  // ── Activities section ───────────────────────────────────────────────────────

  Widget _buildActivitiesSection(BuildContext context, DailyRoadmapProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ACTIVIDADES DE HOY',
              style: _sansStyle.copyWith(
                fontSize: 10, fontWeight: FontWeight.w500,
                letterSpacing: 3, color: _textMuted,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddModal(context, provider),
              child: const Icon(
                Icons.add_circle_outline_rounded,
                color: _accentBlue, size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!provider.hasActivities)
          _buildEmptyState(context, provider)
        else
          _buildActivityList(context, provider),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, DailyRoadmapProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.calendar_today_outlined,
              color: _textMuted, size: 40),
            const SizedBox(height: 12),
            Text('Sin actividades hoy',
              style: _sansStyle.copyWith(
                fontSize: 16, color: _textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text('Añade tu primera actividad del día',
              style: _sansStyle.copyWith(
                fontSize: 13, color: _textMuted,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _showAddModal(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_borderBlue, _accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Añadir actividad',
                  style: _sansStyle.copyWith(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context, DailyRoadmapProvider provider) {
    final activities = provider.activitiesByTime;
    return Column(
      children: activities
          .map((a) => _ActivityRow(
                activity: a,
                onTap: () => _showEditModal(context, provider, a),
                onToggle: () => provider.toggleActivityCompletion(a.id),
              ))
          .toList(),
    );
  }

  // ── Modal launchers ──────────────────────────────────────────────────────────

  void _showAddModal(BuildContext context, DailyRoadmapProvider provider) {
    final now = TimeOfDay.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddActivityModal(
        provider: provider,
        initialHour: now.hour,
        initialMinute: now.minute,
      ),
    );
  }

  void _showEditModal(
    BuildContext context,
    DailyRoadmapProvider provider,
    RoadmapActivityModel activity,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditActivityModal(
        provider: provider,
        activity: activity,
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color valueColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderBlue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: const TextStyle(
              fontFamily: 'Geist', fontSize: 10, fontWeight: FontWeight.w500,
              letterSpacing: 2, color: _textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(value,
            style: TextStyle(
              fontFamily: 'JetBrains Mono', fontSize: 22, color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub,
            style: const TextStyle(
              fontFamily: 'Geist', fontSize: 11, color: _textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final RoadmapActivityModel activity;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _ActivityRow({
    required this.activity,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final inProgress = activity.isInProgress;
    final completed = activity.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: inProgress
            ? const EdgeInsets.symmetric(vertical: 3)
            : EdgeInsets.zero,
        padding: inProgress
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
            : const EdgeInsets.symmetric(vertical: 12),
        decoration: inProgress
            ? BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accentBlue, width: 1),
              )
            : null,
        child: Row(
          children: [
            // Time
            SizedBox(
              width: 48,
              child: Text(
                activity.timeString,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 14,
                  fontWeight: inProgress ? FontWeight.w500 : FontWeight.w400,
                  color: inProgress
                      ? _accentBlue
                      : completed
                          ? _textMuted
                          : _textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Status dot
            _StatusDot(activity: activity),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: inProgress ? FontWeight.w600 : FontWeight.w400,
                      color: completed ? _textMuted : _textPrimary,
                      decoration: completed ? TextDecoration.lineThrough : null,
                      decorationColor: _textMuted,
                    ),
                  ),
                  if (_hasMeta)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _metaText,
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 11,
                          color: inProgress ? _accentBlue : _textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Right action
            if (inProgress)
              const Icon(Icons.arrow_forward_rounded,
                color: _accentBlue, size: 16)
            else
              GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: completed ? _positive : _textMuted,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _hasMeta =>
      activity.category != null || activity.estimatedDuration != null || activity.isInProgress;

  String get _metaText {
    final parts = <String>[];
    if (activity.category != null) parts.add(activity.category!);
    if (activity.estimatedDuration != null) {
      parts.add('${activity.estimatedDuration} min');
    }
    if (activity.isInProgress) parts.add('En progreso');
    return parts.join(' · ');
  }
}

class _StatusDot extends StatelessWidget {
  final RoadmapActivityModel activity;
  const _StatusDot({required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.isCompleted) {
      return Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(
          color: _positive, shape: BoxShape.circle,
        ),
      );
    }
    if (activity.isInProgress) {
      return Container(
        width: 10, height: 10,
        decoration: const BoxDecoration(
          color: _accentBlue, shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _textMuted, width: 1),
      ),
    );
  }
}
