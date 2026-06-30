// ============================================================================
// daily_roadmap_screen_v4.dart — COMMAND CENTER REDESIGN
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../data/models/roadmap_activity_model.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/optimized_providers.dart';
import '../v2/components/minimal_colors.dart';
import 'components/add_activity_modal_v4.dart';
import 'components/edit_activity_modal_v4.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class DailyRoadmapScreenV4 extends StatefulWidget {
  const DailyRoadmapScreenV4({super.key});

  @override
  State<DailyRoadmapScreenV4> createState() => _DailyRoadmapScreenV4State();
}

class _DailyRoadmapScreenV4State extends State<DailyRoadmapScreenV4>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _pulse;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic);
    _slideUp = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _pulse = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProvider();
      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
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
          backgroundColor: MinimalColors.backgroundPrimary(context),
          body: SafeArea(
            child: provider.isLoading
                ? _LoadingView()
                : AnimatedBuilder(
                    animation: _entryController,
                    builder: (_, child) => Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideUp.value),
                        child: child,
                      ),
                    ),
                    child: Column(
                      children: [
                        _CommandHeader(provider: provider),
                        Expanded(child: _TimelineBody(
                          provider: provider,
                          pulseAnimation: _pulse,
                          onAdd: () => _showAddModal(context, provider),
                          onEdit: (a) => _showEditModal(context, provider, a),
                          onToggle: (id) {
                            HapticFeedback.mediumImpact();
                            provider.toggleActivityCompletion(id);
                          },
                        )),
                      ],
                    ),
                  ),
          ),
          floatingActionButton: provider.isLoading ? null : _GradientFAB(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showAddModal(context, provider);
            },
          ),
        );
      },
    );
  }

  void _showAddModal(BuildContext context, DailyRoadmapProvider provider) {
    final now = TimeOfDay.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => AddActivityModalV4(
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
      useSafeArea: true,
      builder: (_) => EditActivityModalV4(
        provider: provider,
        activity: activity,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMMAND HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _CommandHeader extends StatelessWidget {
  final DailyRoadmapProvider provider;
  const _CommandHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    final grad = MinimalColors.primaryGradient(context);
    final completed = provider.completedActivities;
    final total = provider.totalActivities;
    final progress = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    final auth = context.read<OptimizedAuthProvider>();
    final firstName = auth.currentUser?.name.split(' ').first ?? 'tú';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        border: Border(
          bottom: BorderSide(
            color: grad.first.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + subtitle (estilo coherente con las demás pantallas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mi día',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_greeting()} $firstName.',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _ProgressRing(
                progress: progress,
                completed: completed,
                total: total,
                gradColors: grad,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metrics strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MetricPill(
                    label: 'ENFOQUE',
                    value: _focusTime(provider),
                    gradColors: grad,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: MinimalColors.backgroundCard(context),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: _MetricPill(
                    label: 'PRÓXIMA',
                    value: provider.upcomingActivities.isEmpty
                        ? '──'
                        : provider.upcomingActivities.first.timeString,
                    gradColors: grad,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: MinimalColors.backgroundCard(context),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: _MetricPill(
                    label: 'PENDIENTES',
                    value: '${total - completed}',
                    gradColors: grad,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días,';
    if (h < 20) return 'Buenas tardes,';
    return 'Buenas noches,';
  }

  static String _focusTime(DailyRoadmapProvider provider) {
    final min = provider.activitiesByTime
        .where((a) => a.isCompleted)
        .fold(0, (s, a) => s + (a.estimatedDuration ?? 0));
    if (min == 0) return '──';
    final h = min ~/ 60;
    final m = min % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h${m}m';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMELINE BODY
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineBody extends StatelessWidget {
  final DailyRoadmapProvider provider;
  final Animation<double> pulseAnimation;
  final VoidCallback onAdd;
  final void Function(RoadmapActivityModel) onEdit;
  final void Function(String) onToggle;

  const _TimelineBody({
    required this.provider,
    required this.pulseAnimation,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final activities = provider.activitiesByTime;
    final grad = MinimalColors.primaryGradient(context);

    return Column(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 20, 8),
          child: Row(
            children: [
              Text(
                'HOY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.5,
                  color: MinimalColors.textMuted(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        grad.first.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _AddButton(onTap: onAdd),
            ],
          ),
        ),

        // List
        Expanded(
          child: activities.isEmpty
              ? _EmptyState(onAdd: onAdd)
              : _buildList(context, activities),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, List<RoadmapActivityModel> activities) {
    final now = DateTime.now();
    final sel = provider.selectedDate;
    final isToday = sel.year == now.year &&
        sel.month == now.month &&
        sel.day == now.day;

    int nowIdx = activities.length;
    if (isToday) {
      for (int i = 0; i < activities.length; i++) {
        final t = DateTime(now.year, now.month, now.day,
            activities[i].hour, activities[i].minute);
        if (t.isAfter(now)) {
          nowIdx = i;
          break;
        }
      }
    }

    final children = <Widget>[];
    for (int i = 0; i < activities.length; i++) {
      if (isToday && i == nowIdx) {
        children.add(_NowIndicator(
          time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ));
      }
      children.add(_TimelineRow(
        activity: activities[i],
        isLast: i == activities.length - 1,
        pulseAnimation: pulseAnimation,
        onTap: () => onEdit(activities[i]),
        onToggle: () => onToggle(activities[i].id),
      ));
    }
    if (isToday && nowIdx == activities.length) {
      children.add(_NowIndicator(
        time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
      children: children,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMELINE COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  final RoadmapActivityModel activity;
  final bool isLast;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _TimelineRow({
    required this.activity,
    required this.isLast,
    required this.pulseAnimation,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final grad = MinimalColors.primaryGradient(context);
    final pos = MinimalColors.positiveGradient(context);
    final completed = activity.isCompleted;
    final inProgress = activity.isInProgress;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time label
          SizedBox(
            width: 62,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 14, right: 6),
                  child: Text(
                    activity.timeString,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: inProgress ? FontWeight.w700 : FontWeight.w400,
                      color: inProgress
                          ? grad.last
                          : completed
                              ? MinimalColors.textMuted(context)
                              : MinimalColors.textSecondary(context),
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              (inProgress ? grad.last : completed ? pos.first : MinimalColors.textMuted(context)).withValues(alpha: 0.3),
                              MinimalColors.backgroundSecondary(context).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Node
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: _StatusNode(
              completed: completed,
              inProgress: inProgress,
              gradColors: grad,
              positiveColor: pos.first,
              mutedColor: MinimalColors.textMuted(context),
              pulseAnimation: pulseAnimation,
            ),
          ),

          const SizedBox(width: 10),

          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 20, 6),
              child: GestureDetector(
                onTap: onTap,
                child: _ActivityCard(
                  activity: activity,
                  gradColors: grad,
                  positiveColors: pos,
                  onToggle: onToggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusNode extends StatelessWidget {
  final bool completed;
  final bool inProgress;
  final List<Color> gradColors;
  final Color positiveColor;
  final Color mutedColor;
  final Animation<double> pulseAnimation;

  const _StatusNode({
    required this.completed,
    required this.inProgress,
    required this.gradColors,
    required this.positiveColor,
    required this.mutedColor,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (inProgress) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (_, __) => Transform.scale(
          scale: pulseAnimation.value,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradColors.last.withValues(alpha: 0.55),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (completed) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: positiveColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 6),
      );
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: mutedColor.withValues(alpha: 0.5), width: 1.5),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final RoadmapActivityModel activity;
  final List<Color> gradColors;
  final List<Color> positiveColors;
  final VoidCallback onToggle;

  const _ActivityCard({
    required this.activity,
    required this.gradColors,
    required this.positiveColors,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completed = activity.isCompleted;
    final inProgress = activity.isInProgress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inProgress
              ? gradColors.last.withValues(alpha: 0.45)
              : completed
                  ? positiveColors.first.withValues(alpha: 0.18)
                  : MinimalColors.backgroundSecondary(context),
          width: inProgress ? 1.5 : 1,
        ),
        boxShadow: inProgress
            ? [
                BoxShadow(
                  color: gradColors.last.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Priority strip
          Container(
            width: 3,
            height: 38,
            margin: const EdgeInsets.only(right: 11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: completed
                    ? [positiveColors.first, positiveColors.last]
                    : inProgress
                        ? gradColors
                        : [
                            MinimalColors.textMuted(context).withValues(alpha: 0.25),
                            MinimalColors.textMuted(context).withValues(alpha: 0.08),
                          ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: inProgress ? FontWeight.w600 : FontWeight.w500,
                    color: completed
                        ? MinimalColors.textMuted(context)
                        : MinimalColors.textPrimary(context),
                    decoration: completed ? TextDecoration.lineThrough : null,
                    decorationColor: MinimalColors.textMuted(context),
                  ),
                ),
                if (activity.category != null || activity.estimatedDuration != null ||
                    activity.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      _meta(),
                      style: TextStyle(
                        fontSize: 11,
                        color: inProgress
                            ? gradColors.last.withValues(alpha: 0.85)
                            : MinimalColors.textMuted(context),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action
          if (inProgress)
            Icon(Icons.arrow_forward_rounded, color: gradColors.last, size: 15)
          else
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  completed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: completed ? positiveColors.first : MinimalColors.textMuted(context),
                  size: 21,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _meta() {
    final parts = <String>[];
    if (activity.category != null) parts.add(activity.category!);
    if (activity.estimatedDuration != null) parts.add('${activity.estimatedDuration}m');
    if (activity.isInProgress) parts.add('En progreso');
    return parts.join(' · ');
  }
}

class _NowIndicator extends StatelessWidget {
  final String time;
  const _NowIndicator({required this.time});

  @override
  Widget build(BuildContext context) {
    final grad = MinimalColors.primaryGradient(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: grad),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: grad.last.withValues(alpha: 0.65),
                  blurRadius: 7,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AHORA  $time',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
              color: grad.last,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [grad.last.withValues(alpha: 0.5), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final grad = MinimalColors.primaryGradient(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: grad.map((c) => c.withValues(alpha: 0.12)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: grad.first.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.today_outlined,
                color: grad.last,
                size: 34,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Sin actividades hoy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MinimalColors.textPrimary(context),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Planifica tu día añadiendo\ntus primeras actividades',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MinimalColors.textMuted(context),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onAdd();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: grad),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: grad.first.withValues(alpha: 0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Añadir actividad',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final grad = MinimalColors.primaryGradient(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(grad.last),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CARGANDO',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              color: MinimalColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _GradientFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final grad = MinimalColors.primaryGradient(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: grad.first.withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final grad = MinimalColors.primaryGradient(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: grad),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: grad.first.withValues(alpha: 0.38),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 18),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> gradColors;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.gradColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: MinimalColors.textMuted(context),
          ),
        ),
        const SizedBox(height: 3),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(colors: gradColors).createShader(b),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;
  final List<Color> gradColors;

  const _ProgressRing({
    required this.progress,
    required this.completed,
    required this.total,
    required this.gradColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(70, 70),
            painter: _ArcPainter(
              progress: progress,
              colors: gradColors,
              trackColor: MinimalColors.backgroundSecondary(context),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$completed',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: MinimalColors.textPrimary(context),
                  height: 1,
                ),
              ),
              Text(
                'de $total',
                style: TextStyle(
                  fontSize: 8,
                  color: MinimalColors.textMuted(context),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final Color trackColor;
  static const double _s = 5.5;

  const _ArcPainter({
    required this.progress,
    required this.colors,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (math.min(size.width, size.height) - _s) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    canvas.drawCircle(
      c, r,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _s,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          colors: colors,
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _s
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.progress != progress;
}

