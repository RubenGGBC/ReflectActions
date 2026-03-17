# Daily Roadmap Screen V4 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a redesigned Daily Roadmap screen (V4) matching the navy/blue design from Pencil, consuming existing providers and modals with no new DB methods.

**Architecture:** Single `StatefulWidget` in `lib/presentation/screens/v4/`, consuming `DailyRoadmapProvider` (state) and `OptimizedAuthProvider` (user name + ID). Reuses existing `AddActivityModal` and `EditActivityModal`. Swapped into `main_navigation_screen_v2.dart` replacing V3.

**Tech Stack:** Flutter, Provider, `DailyRoadmapProvider`, `OptimizedAuthProvider`, `ThemeProvider`, `RoadmapActivityModel`, existing modals from `v2/components/`.

---

## File Map

| Action | File |
|--------|------|
| **Create** | `lib/presentation/screens/v4/daily_roadmap_screen_v4.dart` |
| **Modify** | `lib/presentation/screens/v2/main_navigation_screen_v2.dart` |

---

## Data Available (no new methods needed)

From `DailyRoadmapProvider`:
- `isLoading` — bool
- `error` — String?
- `hasActivities` — bool
- `activitiesByTime` — `List<RoadmapActivityModel>` sorted by time
- `completedActivities` — int
- `totalActivities` — int
- `completionPercentage` — double (0–100)
- `upcomingActivities` — list of future incomplete activities
- `selectedDate` — DateTime
- `initialize(userId)` — called in `initState`

From `RoadmapActivityModel`:
- `timeString` — "HH:mm"
- `isCompleted` — bool
- `isInProgress` — bool (within time window, not completed)
- `isPast` — bool
- `title`, `category`, `estimatedDuration` (minutes)
- `priority` → `ActivityPriority`

Computed locally (no new provider methods):
- **Greeting name**: `authProvider.currentUser?.name.split(' ').first ?? 'tú'`
- **Focused time**: sum of `estimatedDuration` from completed activities → format "Xh Ym"
- **Next activity**: `provider.upcomingActivities.firstOrNull`
- **Progress bar fraction**: `provider.completionPercentage / 100`

---

## Task 1: Create `daily_roadmap_screen_v4.dart`

**Files:**
- Create: `lib/presentation/screens/v4/daily_roadmap_screen_v4.dart`

### Screen structure

```
SafeArea
└── Column
    ├── _StatusBar (time + battery icon row, 62px)
    └── Expanded
        └── SingleChildScrollView
            └── Padding(20px H, 8px T, 16px B)
                └── Column(gap via SizedBox 20)
                    ├── _Header (date label + greeting)
                    ├── _ProgressSection (big number + bar)
                    ├── _MetricsRow (ENFOQUE + PRÓXIMA)
                    ├── _ActivitiesSection (header + list or empty state)
                    └── SizedBox(height: 20) [bottom breathing room]
```

Tab bar is NOT included — it lives in `main_navigation_screen_v2.dart`.

### Colors (ThemeProvider — dark mode defaults)

```dart
// backgrounds
bg:        ThemeProvider.darkPrimaryBg       // #0A0E1A
cardBg:    ThemeProvider.darkSurface         // #141B2D
cardBg2:   ThemeProvider.darkSurfaceVariant  // #1E2A3F
border:    ThemeProvider.darkBorderColor     // #1E3A8A (dark blue)

// text
textPrimary:   ThemeProvider.darkTextPrimary   // #E8EAF0
textSecondary: ThemeProvider.darkTextSecondary // #B3B8C8
textMuted:     ThemeProvider.darkTextHint      // #8691A8

// accents
accentBlue:    ThemeProvider.darkAccentSecondary // #3B82F6
positive:      ThemeProvider.darkPositiveMain    // #10B981
gradientStart: ThemeProvider.darkAccentPrimary   // #1E3A8A
gradientEnd:   const Color(0xFF7C3AED)           // purple

// use ThemeProvider via context.watch<ThemeProvider>()
// access through themeProvider.currentColors or direct static constants
```

### Step-by-step implementation

- [ ] **Step 1: Create the file with widget skeleton**

```dart
// lib/presentation/screens/v4/daily_roadmap_screen_v4.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/roadmap_activity_model.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../v2/components/add_activity_modal.dart';
import '../v2/components/edit_activity_modal.dart';

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
    final auth = context.read<OptimizedAuthProvider>();
    if (auth.currentUser != null) {
      await context.read<DailyRoadmapProvider>().initialize(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<DailyRoadmapProvider, ThemeProvider>(
      builder: (context, provider, themeProvider, _) {
        return Scaffold(
          backgroundColor: ThemeProvider.darkPrimaryBg,
          body: SafeArea(
            child: _buildBody(context, provider, themeProvider),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DailyRoadmapProvider provider, ThemeProvider theme) {
    if (provider.isLoading) return _buildLoading();
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

  // placeholder implementations — filled in subsequent steps
  Widget _buildLoading() => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
  Widget _buildStatusBar() => const SizedBox(height: 16);
  Widget _buildHeader(DailyRoadmapProvider p) => const SizedBox.shrink();
  Widget _buildProgressSection(DailyRoadmapProvider p) => const SizedBox.shrink();
  Widget _buildMetricsRow(DailyRoadmapProvider p) => const SizedBox.shrink();
  Widget _buildActivitiesSection(BuildContext ctx, DailyRoadmapProvider p) => const SizedBox.shrink();
}
```

- [ ] **Step 2: Implement `_buildStatusBar`**

Show the current time and a battery icon in a 62px row. Use `DateTime.now()` via a `_currentTime` getter. No `Timer` needed — the OS updates the status bar; this is static display.

```dart
Widget _buildStatusBar() {
  final now = TimeOfDay.now();
  final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  return SizedBox(
    height: 46,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(timeStr,
          style: const TextStyle(
            fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
            color: Color(0xFFE8EAF0),
          ),
        ),
        const Icon(Icons.battery_full_rounded, color: Color(0xFFE8EAF0), size: 20),
      ],
    ),
  );
}
```

- [ ] **Step 3: Implement `_buildHeader`**

Displays formatted date + two-line greeting. Gets user first name from `OptimizedAuthProvider`.

```dart
Widget _buildHeader(DailyRoadmapProvider provider) {
  final auth = context.read<OptimizedAuthProvider>();
  final firstName = auth.currentUser?.name.split(' ').first ?? 'tú';
  final date = provider.selectedDate;
  final dateStr = _formatDate(date); // e.g. "LUNES, 17 DE MARZO"

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(dateStr,
        style: const TextStyle(
          fontFamily: 'Geist', fontSize: 11, fontWeight: FontWeight.w500,
          letterSpacing: 2, color: Color(0xFF8691A8),
        ),
      ),
      const SizedBox(height: 2),
      Text('Buenos días,',
        style: const TextStyle(
          fontFamily: 'Geist', fontSize: 32, fontWeight: FontWeight.w300,
          color: Color(0xFFE8EAF0), height: 1.1,
        ),
      ),
      Text('$firstName.',
        style: const TextStyle(
          fontFamily: 'Geist', fontSize: 32, fontWeight: FontWeight.w600,
          color: Color(0xFF3B82F6), height: 1.1,
        ),
      ),
    ],
  );
}

String _formatDate(DateTime date) {
  const months = ['ENERO','FEBRERO','MARZO','ABRIL','MAYO','JUNIO',
                  'JULIO','AGOSTO','SEPTIEMBRE','OCTUBRE','NOVIEMBRE','DICIEMBRE'];
  const days = ['LUNES','MARTES','MIÉRCOLES','JUEVES','VIERNES','SÁBADO','DOMINGO'];
  final weekday = days[date.weekday - 1];
  final month = months[date.month - 1];
  return '$weekday, ${date.day} DE $month';
}
```

- [ ] **Step 4: Implement `_buildProgressSection`**

Big number counter + gradient progress bar. Handles zero-activity case gracefully.

```dart
Widget _buildProgressSection(DailyRoadmapProvider provider) {
  final completed = provider.completedActivities;
  final total = provider.totalActivities;
  final pct = provider.completionPercentage;

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
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono', fontSize: 52, fontWeight: FontWeight.w300,
                  color: Color(0xFFE8EAF0), height: 0.85,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('de $total',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono', fontSize: 22, fontWeight: FontWeight.w300,
                    color: Color(0xFF8691A8),
                  ),
                ),
              ),
            ],
          ),
          Text('${pct.toStringAsFixed(0)}% completado',
            style: const TextStyle(
              fontFamily: 'Geist', fontSize: 12, color: Color(0xFF8691A8),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      // Progress bar
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          width: double.infinity,
          height: 3,
          color: const Color(0xFF1E2A3F),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF7C3AED)],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
```

- [ ] **Step 5: Implement `_buildMetricsRow`**

Two cards: focused time (sum of completed durations) and next activity. Both show placeholder copy when data is unavailable.

```dart
Widget _buildMetricsRow(DailyRoadmapProvider provider) {
  return Row(
    children: [
      Expanded(child: _buildMetricCard(
        label: 'ENFOQUE',
        value: _formatFocusedTime(provider),
        sub: 'tiempo activo',
        valueColor: const Color(0xFFE8EAF0),
      )),
      const SizedBox(width: 10),
      Expanded(child: _buildMetricCard(
        label: 'PRÓXIMA',
        value: _nextActivityTime(provider),
        sub: _nextActivityTitle(provider),
        valueColor: const Color(0xFF3B82F6),
      )),
    ],
  );
}

Widget _buildMetricCard({
  required String label,
  required String value,
  required String sub,
  required Color valueColor,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF141B2D),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1E3A8A), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(
            fontFamily: 'Geist', fontSize: 10, fontWeight: FontWeight.w500,
            letterSpacing: 2, color: Color(0xFF8691A8),
          ),
        ),
        const SizedBox(height: 6),
        Text(value,
          style: TextStyle(
            fontFamily: 'JetBrains Mono', fontSize: 22,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(sub,
          style: const TextStyle(
            fontFamily: 'Geist', fontSize: 11, color: Color(0xFF8691A8),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

String _formatFocusedTime(DailyRoadmapProvider provider) {
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

String _nextActivityTime(DailyRoadmapProvider provider) {
  final next = provider.upcomingActivities.firstOrNull;
  return next?.timeString ?? '—';
}

String _nextActivityTitle(DailyRoadmapProvider provider) {
  final next = provider.upcomingActivities.firstOrNull;
  return next?.title ?? 'sin pendientes';
}
```

- [ ] **Step 6: Implement `_buildActivitiesSection`**

Section header with add button + activity list or empty state.

```dart
Widget _buildActivitiesSection(BuildContext context, DailyRoadmapProvider provider) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('ACTIVIDADES DE HOY',
            style: TextStyle(
              fontFamily: 'Geist', fontSize: 10, fontWeight: FontWeight.w500,
              letterSpacing: 3, color: Color(0xFF8691A8),
            ),
          ),
          GestureDetector(
            onTap: () => _showAddModal(context, provider),
            child: const Icon(Icons.add_circle_outline_rounded,
              color: Color(0xFF3B82F6), size: 18),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // List or empty state
      if (!provider.hasActivities)
        _buildEmptyState(context, provider)
      else
        _buildActivityList(context, provider),
    ],
  );
}

Widget _buildEmptyState(BuildContext context, DailyRoadmapProvider provider) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Icon(Icons.calendar_today_outlined, color: Color(0xFF8691A8), size: 40),
        const SizedBox(height: 12),
        const Text('Sin actividades hoy',
          style: TextStyle(fontFamily: 'Geist', fontSize: 16, color: Color(0xFFB3B8C8)),
        ),
        const SizedBox(height: 4),
        const Text('Añade tu primera actividad del día',
          style: TextStyle(fontFamily: 'Geist', fontSize: 13, color: Color(0xFF8691A8)),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _showAddModal(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Añadir actividad',
              style: TextStyle(fontFamily: 'Geist', fontSize: 13,
                fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActivityList(BuildContext context, DailyRoadmapProvider provider) {
  final activities = provider.activitiesByTime;
  return Column(
    children: activities.map((activity) =>
      _buildActivityRow(context, provider, activity)
    ).toList(),
  );
}
```

- [ ] **Step 7: Implement `_buildActivityRow`**

Three visual states: completed (green dot + strikethrough), in-progress (blue card), upcoming (outline dot).

```dart
Widget _buildActivityRow(BuildContext context, DailyRoadmapProvider provider, RoadmapActivityModel activity) {
  final isInProgress = activity.isInProgress;
  final isCompleted = activity.isCompleted;

  return GestureDetector(
    onTap: () => _showEditModal(context, provider, activity),
    child: Container(
      margin: isInProgress ? const EdgeInsets.symmetric(vertical: 2) : EdgeInsets.zero,
      padding: isInProgress
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
          : const EdgeInsets.symmetric(vertical: 12),
      decoration: isInProgress
          ? BoxDecoration(
              color: const Color(0xFF141B2D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3B82F6), width: 1),
            )
          : null,
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 48,
            child: Text(activity.timeString,
              style: TextStyle(
                fontFamily: 'JetBrains Mono', fontSize: 14,
                color: isInProgress
                    ? const Color(0xFF3B82F6)
                    : isCompleted
                        ? const Color(0xFF8691A8)
                        : const Color(0xFFB3B8C8),
                fontWeight: isInProgress ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Status dot
          _buildStatusDot(activity),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: isInProgress ? FontWeight.w600 : FontWeight.w400,
                    color: isCompleted
                        ? const Color(0xFF8691A8)
                        : const Color(0xFFE8EAF0),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFF8691A8),
                  ),
                ),
                if (activity.category != null || activity.estimatedDuration != null) ...[
                  const SizedBox(height: 2),
                  Text(_buildMeta(activity),
                    style: TextStyle(
                      fontFamily: 'Geist', fontSize: 11,
                      color: isInProgress
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF8691A8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Arrow for in-progress
          if (isInProgress)
            const Icon(Icons.arrow_forward_rounded,
              color: Color(0xFF3B82F6), size: 16),
          // Completion toggle
          if (!isInProgress)
            GestureDetector(
              onTap: () => provider.toggleActivityCompletion(activity.id),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF8691A8),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildStatusDot(RoadmapActivityModel activity) {
  if (activity.isCompleted) {
    return Container(
      width: 8, height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        shape: BoxShape.circle,
      ),
    );
  }
  if (activity.isInProgress) {
    return Container(
      width: 10, height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6),
        shape: BoxShape.circle,
      ),
    );
  }
  return Container(
    width: 8, height: 8,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFF8691A8), width: 1),
    ),
  );
}

String _buildMeta(RoadmapActivityModel activity) {
  final parts = <String>[];
  if (activity.category != null) parts.add(activity.category!);
  if (activity.estimatedDuration != null) parts.add('${activity.estimatedDuration} min');
  if (activity.isInProgress) parts.add('En progreso');
  return parts.join(' · ');
}
```

- [ ] **Step 8: Implement modal launchers**

```dart
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

void _showEditModal(BuildContext context, DailyRoadmapProvider provider, RoadmapActivityModel activity) {
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
```

- [ ] **Step 9: Hot reload and verify the screen compiles without errors**

```bash
cd /Users/rubengallego/StudioProjects/ReflectActions
flutter analyze lib/presentation/screens/v4/daily_roadmap_screen_v4.dart
```

Expected: no errors.

---

## Task 2: Swap V3 → V4 in navigation

**Files:**
- Modify: `lib/presentation/screens/v2/main_navigation_screen_v2.dart`

- [ ] **Step 1: Add import for V4**

In `main_navigation_screen_v2.dart`, add at the top with the other screen imports:
```dart
import '../v4/daily_roadmap_screen_v4.dart';
```

- [ ] **Step 2: Replace the V3 reference with V4**

Find the line:
```dart
const _SafeScreenWrapper(child: DailyRoadmapScreenV3()),
```

Replace with:
```dart
const _SafeScreenWrapper(child: DailyRoadmapScreenV4()),
```

- [ ] **Step 3: Verify the import for V3 is no longer needed (optional cleanup)**

If `DailyRoadmapScreenV3` is not referenced anywhere else, the import can be removed. Check:
```bash
grep -r "DailyRoadmapScreenV3" /Users/rubengallego/StudioProjects/ReflectActions/lib --include="*.dart"
```

- [ ] **Step 4: Analyze and run**

```bash
flutter analyze lib/presentation/screens/v2/main_navigation_screen_v2.dart
```

Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/v4/daily_roadmap_screen_v4.dart \
        lib/presentation/screens/v2/main_navigation_screen_v2.dart
git commit -m "feat: implement DailyRoadmapScreenV4 with minimal navy design

- New minimalist UI: navy dark bg (#0A0E1A), blue/purple gradient accents
- Reuses DailyRoadmapProvider, AddActivityModal, EditActivityModal unchanged
- Three activity states: completed (green), in-progress (blue card), upcoming
- Empty state with add CTA
- Metric cards: focused time + next activity (computed, no new DB methods)
- Swapped into main_navigation_screen_v2 replacing V3"
```
