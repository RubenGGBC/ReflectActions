# UI Bugfix & Design System Cleanup Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all critical bugs, runtime crashes, hardcoded colors, deprecated API usage, and minor behavioral issues across 28 UI screens — without touching localization or file decomposition.

**Architecture:** Each task targets a non-overlapping group of files so all tasks can be parallelized. All color replacements use `MinimalColors` (context-aware) or its static constants. The MinimalColors reference file is at `lib/presentation/screens/v2/components/minimal_colors.dart`.

**Tech Stack:** Flutter, Dart, Provider (ThemeProvider / OptimizedAuthProvider), `dart:math` for `pi`

---

## MinimalColors Quick Reference

Dynamic (require `BuildContext`):
- `MinimalColors.backgroundPrimary(context)` — main background
- `MinimalColors.backgroundCard(context)` — card surface
- `MinimalColors.backgroundSecondary(context)` — secondary surface
- `MinimalColors.textPrimary(context)` — primary text
- `MinimalColors.textSecondary(context)` — secondary text
- `MinimalColors.textMuted(context)` — muted/hint text
- `MinimalColors.shadow(context)` — shadow color
- `MinimalColors.primaryGradient(context)` — header gradient list
- `MinimalColors.positiveGradient(context)` — green gradient
- `MinimalColors.negativeGradient(context)` — red gradient
- `MinimalColors.neutralGradient(context)` — amber gradient

Static constants (no context needed, dark-mode values):
- `MinimalColors.primary` → `Color(0xFF3B82F6)` (blue)
- `MinimalColors.secondary` → `Color(0xFF10B981)` (green)
- `MinimalColors.accent` → `Color(0xFF8B5CF6)` (purple)
- `MinimalColors.success` → `Color(0xFF10B981)`
- `MinimalColors.warning` → `Color(0xFFF59E0B)`
- `MinimalColors.error` → `Color(0xFFEF4444)`
- `MinimalColors.info` → `Color(0xFF3B82F6)`
- `MinimalColors.primaryGradientStatic` → `[Color(0xFF1E3A8A), Color(0xFF7C3AED)]`
- `MinimalColors.negativeGradientStatic` → `[Color(0xFFEF4444), Color(0xFFfca5a5)]`
- `MinimalColors.positiveGradientStatic` → `[Color(0xFF10B981), Color(0xFF34d399)]`
- `MinimalColors.neutralGradientStatic` → `[Color(0xFFf59e0b), Color(0xFFfbbf24)]`

---

## Task 1: Critical Crashes — `activity_resource_screen.dart`

**Files:**
- Modify: `lib/presentation/screens/v2/activity_resource_screen.dart`

**Issues to fix:**

### 1a. `context` used after `Navigator.pop`
Lines 237–245: `ScaffoldMessenger.of(context).showSnackBar(...)` is called after two `Navigator.pop(context)`. The widget is already removed from the tree.

- [ ] **Step 1: Move snackbar call BEFORE the Navigator.pop calls**

```dart
// BEFORE (broken):
Navigator.pop(context); // Close dialog
Navigator.pop(context); // Go back

ScaffoldMessenger.of(context).showSnackBar(...);

// AFTER (fixed):
ScaffoldMessenger.of(context).showSnackBar(...);
Navigator.pop(context); // Close dialog
Navigator.pop(context); // Go back
```

### 1b. Dialog `setState` bug — ratings stars don't update
`_buildRatingStars()` calls `setState` on parent state while rendered inside a `showDialog`. The dialog doesn't rebuild.

- [ ] **Step 2: Wrap the dialog content with `StatefulBuilder`**

In the method that shows the rating dialog, wrap the dialog body:
```dart
showDialog(
  context: context,
  builder: (context) => StatefulBuilder(
    builder: (context, setDialogState) {
      return AlertDialog(
        content: _buildRatingStars(setDialogState), // pass setDialogState
        ...
      );
    },
  ),
);
```

Update `_buildRatingStars` to accept and use `setDialogState` instead of `setState`.

### 1c. `shouldRepaint` always returns `true` in `CircularProgressPainter`

- [ ] **Step 3: Fix `shouldRepaint` to compare fields**

```dart
// BEFORE:
bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

// AFTER:
bool shouldRepaint(covariant CircularProgressPainter oldDelegate) =>
    oldDelegate.progress != progress || oldDelegate.color != color;
```

### 1d. Magic number for Pi

- [ ] **Step 4: Add `dart:math` import and replace `3.14159` with `pi`**

```dart
import 'dart:math'; // add at top of file

// Replace all instances of 3.14159 with pi:
// -3.14159 / 2  →  -pi / 2
// 2 * 3.14159 * progress  →  2 * pi * progress
```

- [ ] **Step 5: Commit**
```bash
git add lib/presentation/screens/v2/activity_resource_screen.dart
git commit -m "fix: crash after navigator pop, dialog setState bug, shouldRepaint, pi constant"
```

---

## Task 2: Critical Crashes — `goal_progress_screen.dart`

**Files:**
- Modify: `lib/presentation/screens/v2/goal_progress_screen.dart`

### 2a. Force-unwrap on nullable `widget.goal!`

- [ ] **Step 1: Add null guard before entering single-goal view**

At the start of `_buildSingleGoalView` (or wherever the view is chosen), add:
```dart
if (widget.goal == null) {
  return Center(
    child: Text(
      'No hay objetivo seleccionado',
      style: TextStyle(color: MinimalColors.textSecondary(context)),
    ),
  );
}
final goal = widget.goal!; // safe from here
```

### 2b. Duplicate accidental `SizedBox` spacers (lines 251–260)

- [ ] **Step 2: Remove one of the two consecutive `const SizedBox(height: 20)`**

### 2c. Merge duplicate `_getCategoryGradient` methods

- [ ] **Step 3: Delete `_getCategoryGradient()` and update its call site to use `_getCategoryGradientForGoal(widget.goal!)`**

- [ ] **Step 4: Commit**
```bash
git add lib/presentation/screens/v2/goal_progress_screen.dart
git commit -m "fix: null crash on goal screen, remove duplicate spacers and gradient method"
```

---

## Task 3: Side-Effect in `build()` — `daily_review_screen_v2.dart`

**Files:**
- Modify: `lib/presentation/screens/v2/daily_review_screen_v2.dart`

### 3a. `SystemChrome.setEnabledSystemUIMode` called inside `build()`

- [ ] **Step 1: Move `SystemChrome.setEnabledSystemUIMode` from `build()` to `initState()`**

```dart
@override
void initState() {
  super.initState();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // ... rest of initState
}
```

Remove the call from `build()`.

### 3b. Replace ~20 hardcoded `Colors.*` with MinimalColors

- [ ] **Step 2: Replace all instances according to this mapping:**

| Hardcoded | Replacement |
|---|---|
| `Colors.green.shade700` | `MinimalColors.success` |
| `Colors.green.withValues(alpha: 0.3)` | `MinimalColors.success.withValues(alpha: 0.3)` |
| `TextStyle(color: Colors.green)` | `TextStyle(color: MinimalColors.success)` |
| `Colors.white54` / `Colors.white60` | `MinimalColors.textMuted(context)` |
| `Colors.red.withValues(alpha: 0.3)` | `MinimalColors.error.withValues(alpha: 0.3)` |
| `TextStyle(color: Colors.red)` | `TextStyle(color: MinimalColors.error)` |
| `Colors.white24` | `MinimalColors.textMuted(context).withValues(alpha: 0.24)` |
| `Colors.white` (text on gradient) | `Colors.white` (keep — on dark gradient bg it's correct) |
| `Colors.red.shade300` | `MinimalColors.error.withValues(alpha: 0.8)` |
| `Colors.orange.shade300` | `MinimalColors.warning.withValues(alpha: 0.8)` |
| `Colors.green.shade300` | `MinimalColors.success.withValues(alpha: 0.8)` |
| `Colors.blue` | `MinimalColors.info` |
| `Colors.orange` | `MinimalColors.warning` |
| `Colors.yellow` | `MinimalColors.warning` |
| `Colors.amber` | `MinimalColors.warning` |

- [ ] **Step 3: Replace deprecated `withOpacity()` → `withValues(alpha:)` throughout file**

Search: `.withOpacity(` → Replace: `.withValues(alpha: `
(Check each replacement — argument value stays the same)

- [ ] **Step 4: Fix `_getEmotionColor` to use MinimalColors constants instead of raw Material colors**

```dart
Color _getEmotionColor(String emotion) {
  switch (emotion.toLowerCase()) {
    case 'feliz': case 'alegre': return MinimalColors.success;
    case 'triste': case 'melancólico': return MinimalColors.info;
    case 'ansioso': case 'estresado': return MinimalColors.warning;
    case 'enojado': case 'frustrado': return MinimalColors.error;
    default: return MinimalColors.primary;
  }
}
```

- [ ] **Step 5: Commit**
```bash
git add lib/presentation/screens/v2/daily_review_screen_v2.dart
git commit -m "fix: SystemChrome out of build, replace hardcoded colors, fix withOpacity deprecation"
```

---

## Task 4: Crash & Colors — `home_screen_v2.dart`

**Files:**
- Modify: `lib/presentation/screens/v2/home_screen_v2.dart`

### 4a. `AnimatedContainer` with `null` height (line ~1449)

- [ ] **Step 1: Replace the `AnimatedContainer` with `AnimatedCrossFade` or a sized container**

```dart
// BEFORE (crashes):
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  height: _isMomentsExpanded ? null : 0,
  child: ...
)

// AFTER (safe):
AnimatedCrossFade(
  duration: const Duration(milliseconds: 300),
  crossFadeState: _isMomentsExpanded
      ? CrossFadeState.showFirst
      : CrossFadeState.showSecond,
  firstChild: /* the moments content */,
  secondChild: const SizedBox.shrink(),
)
```

### 4b. Hardcoded `Color(0xFF3b82f6)` in loading indicator (line ~253)

- [ ] **Step 2: Replace with `MinimalColors.primary`**

```dart
valueColor: AlwaysStoppedAnimation<Color>(MinimalColors.primary),
```

### 4c. Replace deprecated `.withOpacity()` → `.withValues(alpha:)`

- [ ] **Step 3: Find and replace all `.withOpacity(` in this file**

### 4d. Remove dead `SizedBox(height: 24)` after removed widget comment

- [ ] **Step 4: Remove the orphaned spacing at lines ~388-389**

- [ ] **Step 5: Commit**
```bash
git add lib/presentation/screens/v2/home_screen_v2.dart
git commit -m "fix: AnimatedContainer null height crash, hardcoded primary color, withOpacity deprecated"
```

---

## Task 5: Hardcoded Colors — `main_navigation_screen_v2.dart` + `profile_screen_v2.dart`

**Files:**
- Modify: `lib/presentation/screens/v2/main_navigation_screen_v2.dart`
- Modify: `lib/presentation/screens/v2/profile_screen_v2.dart`

### 5a. Nav item hardcoded hex colors (main_navigation)

- [ ] **Step 1: Replace 7 hardcoded nav item colors**

```dart
// Line ~60: Color(0xFFF59E0B) → MinimalColors.warning
// Line ~67: Color(0xFF9333EA) → MinimalColors.accent
// Line ~80: Color(0xFF3B82F6) → MinimalColors.primary
// Line ~88: Color(0xFF10B981) → MinimalColors.secondary
// Line ~95: Color(0xFF4ECDC4) → const Color(0xFF4ECDC4) (no MinimalColors equivalent, keep as const)
// Line ~102: Color(0xFFEF4444) → MinimalColors.error
```

### 5b. Remove redundant `_isDisposed` flag (main_navigation)

- [ ] **Step 2: Remove the `_isDisposed` field and all references to it. Use only `mounted` checks.**

### 5c. Fix double haptic `Future.delayed` without `mounted` check (main_navigation)

- [ ] **Step 3: Add `mounted` check inside the delayed callback**

```dart
Future.delayed(const Duration(milliseconds: 50), () {
  if (mounted) HapticFeedback.lightImpact();
});
```

### 5d. Fix logout gradient in profile screen

- [ ] **Step 4: Replace hardcoded logout gradient colors**

```dart
// BEFORE:
colors: [Color(0xFFdc2626), Color(0xFFef4444)]

// AFTER:
colors: MinimalColors.negativeGradientStatic
```

### 5e. Fix snackbar error color in profile screen

- [ ] **Step 5: Replace hardcoded error color in `_showSnackBar`**

```dart
backgroundColor: isError ? MinimalColors.error : MinimalColors.primaryGradient(context)[0],
```

### 5f. Fix `Colors.white` icon/text in profile screen for light mode

- [ ] **Step 6: For icon colors inside gradient containers, keep `Colors.white` (correct — text on dark gradient). For text/icons on non-gradient backgrounds, replace with `MinimalColors.textPrimary(context)`**

- [ ] **Step 7: Commit**
```bash
git add lib/presentation/screens/v2/main_navigation_screen_v2.dart \
        lib/presentation/screens/v2/profile_screen_v2.dart
git commit -m "fix: hardcoded nav/profile colors, redundant _isDisposed, haptic mounted check"
```

---

## Task 6: Hardcoded Colors — `calendar_screen_v2.dart` + `notification_settings_screen.dart`

**Files:**
- Modify: `lib/presentation/screens/v2/calendar_screen_v2.dart`
- Modify: `lib/presentation/screens/v2/notification_settings_screen.dart`

### 6a. Dark-only empty state color in calendar (line ~631)

- [ ] **Step 1: Replace `Colors.grey.shade800.withValues(alpha: 0.3)`**

```dart
color: MinimalColors.backgroundSecondary(context).withValues(alpha: 0.6),
```

### 6b. Date picker forces `ColorScheme.dark` + `onSurface: Colors.black` (line ~1014)

- [ ] **Step 2: Fix date picker theme to respect actual theme**

```dart
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
colorScheme: themeProvider.isDarkMode
    ? ColorScheme.dark(
        primary: MinimalColors.primaryGradient(context)[0],
        surface: MinimalColors.backgroundCard(context),
        onSurface: MinimalColors.textPrimary(context),
      )
    : ColorScheme.light(
        primary: MinimalColors.primaryGradient(context)[0],
        surface: MinimalColors.backgroundCard(context),
        onSurface: MinimalColors.textPrimary(context),
      ),
```

### 6c. Leap year fix in calendar stats (line ~798)

- [ ] **Step 3: Replace hardcoded `365` with actual year day count**

```dart
final totalDays = DateTime(DateTime.now().year, 12, 31).difference(
  DateTime(DateTime.now().year, 1, 1)).inDays + 1;
```

### 6d. Replace `firstWhere` exception flow in `_getEntryForDate`

- [ ] **Step 4: Replace try/catch with `firstWhereOrNull`**

Add import if needed: `import 'package:collection/collection.dart';`

```dart
dynamic _getEntryForDate(DateTime date) {
  return entries.firstWhereOrNull(
    (e) => _isSameDay(DateTime.parse(e.date), date),
  );
}
```

### 6e. Time picker in notification settings forces dark (line ~554)

- [ ] **Step 5: Apply same pattern as 6b — use `themeProvider.isDarkMode` to pick `ColorScheme.dark` or `ColorScheme.light`**

### 6f. SharedPreferences keys as raw strings

- [ ] **Step 6: Add a `_PrefsKeys` class at the top of the file with all keys as static constants**

```dart
class _PrefsKeys {
  static const notificationsEnabled = 'notifications_enabled';
  static const dailyReviewHour = 'daily_review_hour';
  // ... all other keys
}
```

Replace all raw string key usages with `_PrefsKeys.xxx`.

- [ ] **Step 7: Commit**
```bash
git add lib/presentation/screens/v2/calendar_screen_v2.dart \
        lib/presentation/screens/v2/notification_settings_screen.dart
git commit -m "fix: calendar/notification hardcoded colors, date picker theme, leap year, prefs keys"
```

---

## Task 7: Hardcoded Colors — Activities Group

**Files:**
- Modify: `lib/presentation/screens/v2/activities_screen.dart`
- Modify: `lib/presentation/screens/v2/quick_moments_screen.dart`
- Modify: `lib/presentation/screens/v2/recommended_activities_screen.dart`

### 7a. `activities_screen.dart`

- [ ] **Step 1: Replace raw color values**

```dart
// Line ~100: Colors.red for error icon → MinimalColors.error
// Line ~242: Colors.green.withValues(alpha: 0.3) → MinimalColors.success.withValues(alpha: 0.3)
// Line ~243: Colors.white.withValues(alpha: 0.1) → Colors.white.withValues(alpha: 0.1) (keep — on dark bg)
// Line ~322: Colors.green → MinimalColors.success
// Line ~339: Colors.green.shade700 → MinimalColors.success
// Line ~350: Colors.orange → MinimalColors.warning
// Line ~407: Colors.amber → MinimalColors.warning (for stars — consider keeping amber for aesthetics)
// Line ~519: Colors.orange → MinimalColors.warning
// Line ~532: Colors.green → MinimalColors.success (snackbar)
```

### 7b. `quick_moments_screen.dart`

- [ ] **Step 2: Replace moment type colors**

```dart
// Color(0xFF10b981) → MinimalColors.success
// Color(0xFFf59e0b) → MinimalColors.warning
// Color(0xFFef4444) → MinimalColors.error
```

### 7c. `recommended_activities_screen.dart` — `_buildDifficultyBadge`

- [ ] **Step 3: Replace difficulty badge colors**

```dart
Color _getDifficultyColor(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'fácil': case 'facil': return MinimalColors.success;
    case 'moderado': return MinimalColors.warning;
    case 'difícil': case 'dificil': return MinimalColors.error;
    default: return MinimalColors.primary;
  }
}
```

- [ ] **Step 4: Commit**
```bash
git add lib/presentation/screens/v2/activities_screen.dart \
        lib/presentation/screens/v2/quick_moments_screen.dart \
        lib/presentation/screens/v2/recommended_activities_screen.dart
git commit -m "fix: hardcoded colors in activities, quick moments, and recommended activities screens"
```

---

## Task 8: Theme Isolation — `visual_timeline_widget.dart` + `edit_activity_modal.dart`

**Files:**
- Modify: `lib/presentation/screens/v2/components/visual_timeline_widget.dart`
- Modify: `lib/presentation/screens/v2/components/edit_activity_modal.dart`

### 8a. `visual_timeline_widget.dart` — static dark-only colors

- [ ] **Step 1: Remove the `static const Color` block (lines 54–60) from `_TimelineColors`**

Replace every usage of the static constants with `MinimalColors` dynamic calls, passing `context`:

```dart
// pastColor → MinimalColors.success
// currentColor → MinimalColors.primary
// futureColor → MinimalColors.textMuted(context)
// lineColor → MinimalColors.backgroundSecondary(context)
// textPrimary → MinimalColors.textPrimary(context)
// textSecondary → MinimalColors.textSecondary(context)
// surface → MinimalColors.backgroundCard(context)
```

Pass `context` down to any method that needs these colors.

### 8b. Remove unused variable `activities` (line ~538)

- [ ] **Step 2: Delete the unused variable declaration**

### 8c. `edit_activity_modal.dart` — uses `ThemeProvider` directly instead of `MinimalColors`

- [ ] **Step 3: Replace `Consumer<ThemeProvider>` + `theme.surface` / `theme.textPrimary` etc. with `MinimalColors` equivalents**

| ThemeProvider direct | MinimalColors replacement |
|---|---|
| `theme.surface` | `MinimalColors.backgroundCard(context)` |
| `theme.primaryBg` | `MinimalColors.backgroundPrimary(context)` |
| `theme.surfaceVariant` | `MinimalColors.backgroundSecondary(context)` |
| `theme.textPrimary` | `MinimalColors.textPrimary(context)` |
| `theme.textSecondary` | `MinimalColors.textSecondary(context)` |
| `theme.textHint` | `MinimalColors.textMuted(context)` |
| `theme.gradientHeader` | `MinimalColors.primaryGradient(context)` |
| `theme.positiveMain` | `MinimalColors.success` |
| `theme.negativeMain` | `MinimalColors.error` |

You can remove the `Consumer<ThemeProvider>` wrapper if `MinimalColors` is used instead (it calls `Provider.of` internally).

- [ ] **Step 4: Commit**
```bash
git add lib/presentation/screens/v2/components/visual_timeline_widget.dart \
        lib/presentation/screens/v2/components/edit_activity_modal.dart
git commit -m "fix: visual timeline dark-only colors, edit modal ThemeProvider bypass, unused variable"
```

---

## Task 9: Analytics Screens — `analytics_v3_screen.dart` + `user_progression_analytics_screen.dart`

**Files:**
- Modify: `lib/presentation/screens/v2/analytics_v3_screen.dart`
- Modify: `lib/presentation/screens/v2/user_progression_analytics_screen.dart`

### 9a. Replace `withOpacity()` → `withValues(alpha:)` in `analytics_v3_screen.dart`

- [ ] **Step 1: Global find/replace `.withOpacity(` → `.withValues(alpha: ` in this file (~30 instances)**

### 9b. Replace hardcoded colors in `analytics_v3_screen.dart`

- [ ] **Step 2: Replace raw Material colors**

```dart
// Colors.green → MinimalColors.success
// Colors.orange → MinimalColors.warning
// Colors.amber → MinimalColors.warning
// Colors.red → MinimalColors.error
// Status indicators: Colors.green/orange → MinimalColors.success/warning
// _getWellnessColor: return MinimalColors.success/warning/error
```

### 9c. Remove debug `print()` statements from `analytics_v3_screen.dart`

- [ ] **Step 3: Remove all 12 `print(...)` calls in `_loadAnalyticsData()` and elsewhere**

### 9d. Fix `user_progression_analytics_screen.dart` hardcoded loading color (line ~375)

- [ ] **Step 4: Replace `Color(0xFF3b82f6)` → `MinimalColors.primary`**

```dart
valueColor: AlwaysStoppedAnimation<Color>(MinimalColors.primary),
```

### 9e. Fix `_getCorrelationColor` in `user_progression_analytics_screen.dart`

- [ ] **Step 5: Replace `Colors.orange` / `Colors.red` → `MinimalColors.warning` / `MinimalColors.error`**

### 9f. Replace `withOpacity()` in `user_progression_analytics_screen.dart`

- [ ] **Step 6: Global find/replace in this file**

- [ ] **Step 7: Commit**
```bash
git add lib/presentation/screens/v2/analytics_v3_screen.dart \
        lib/presentation/screens/v2/user_progression_analytics_screen.dart
git commit -m "fix: analytics hardcoded colors, withOpacity deprecated, remove debug prints"
```

---

## Task 10: v4 Screens — Full Theme Integration

**Files:**
- Modify: `lib/presentation/screens/v4/analytics_screen_v4.dart`
- Modify: `lib/presentation/screens/v4/daily_roadmap_screen_v4.dart`

### 10a. `analytics_screen_v4.dart` — integrate MinimalColors

This file uses ZERO theme-awareness. Add the import and replace all hardcoded colors:

- [ ] **Step 1: Add import at top of file**

```dart
import '../../v2/components/minimal_colors.dart';
import '../../../providers/theme_provider.dart';
import 'package:provider/provider.dart';
```

- [ ] **Step 2: Replace all hardcoded colors according to this map**

```dart
// Color(0xFF000000) background → MinimalColors.backgroundPrimary(context)
// Color(0xFF1A1A1A) surface → MinimalColors.backgroundCard(context)
// Color(0xFF8b5cf6) accent → MinimalColors.accent
// Color(0xFF10b981) success → MinimalColors.success
// Color(0xFFf59e0b) warning → MinimalColors.warning
// Color(0xFF3b82f6) primary → MinimalColors.primary
// Color(0xFF1e3a8a), Color(0xFF581c87) gradient → MinimalColors.primaryGradient(context)
// Colors.white text → MinimalColors.textPrimary(context)
// Colors.white70 → MinimalColors.textSecondary(context)
// Colors.white30 → MinimalColors.textMuted(context)
```

- [ ] **Step 3: Fix `shouldRepaint` in `MiniChartPainter`**

```dart
bool shouldRepaint(MiniChartPainter oldDelegate) =>
    oldDelegate.dataPoints != dataPoints || oldDelegate.color != color;
```

- [ ] **Step 4: Fix deprecated `Key?` constructor → `super.key`**

```dart
// BEFORE:
const AnalyticsScreenV4({Key? key}) : super(key: key);

// AFTER:
const AnalyticsScreenV4({super.key});
```

- [ ] **Step 5: Replace `withOpacity()` → `withValues(alpha:)` globally in file**

### 10b. `daily_roadmap_screen_v4.dart` — integrate MinimalColors

- [ ] **Step 6: Add MinimalColors import, replace file-level `const Color` variables**

```dart
// Remove the top-level _bg, _card, _accentBlue etc. const Color variables
// Replace all their usages with MinimalColors equivalents:
// _bg → MinimalColors.backgroundPrimary(context)
// _card → MinimalColors.backgroundCard(context)
// _accentBlue → MinimalColors.primary
// _accentGreen → MinimalColors.success
// _accentAmber → MinimalColors.warning
// _textPrimary → MinimalColors.textPrimary(context)
// _textSecondary → MinimalColors.textSecondary(context)
```

- [ ] **Step 7: Fix hardcoded font families**

If `JetBrains Mono` and `Geist` are NOT in `pubspec.yaml`, remove them:
```dart
// const _monoStyle = TextStyle(fontFamily: 'JetBrains Mono');  → remove
// const _sansStyle = TextStyle(fontFamily: 'Geist');  → remove
// Use Theme.of(context).textTheme or plain TextStyle() without fontFamily
```

- [ ] **Step 8: Fix greeting to be time-aware**

```dart
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Buenos días,';
  if (hour < 18) return 'Buenas tardes,';
  return 'Buenas noches,';
}
```

- [ ] **Step 9: Commit**
```bash
git add lib/presentation/screens/v4/analytics_screen_v4.dart \
        lib/presentation/screens/v4/daily_roadmap_screen_v4.dart
git commit -m "fix: v4 screens theme integration, dynamic greeting, shouldRepaint, deprecated Key constructor"
```

---

## Task 11: Goals & Onboarding — Behavioral Bugs

**Files:**
- Modify: `lib/presentation/screens/v2/goals_screen_enhanced.dart`
- Modify: `lib/presentation/screens/v2/welcome_onboarding_screen.dart`
- Modify: `lib/presentation/screens/v2/goal_lifetime_screen.dart`

### 11a. `goals_screen_enhanced.dart` — `addPostFrameCallback` in `build()`

- [ ] **Step 1: Move `addPostFrameCallback` registration to `initState()`**

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeData();
  });
}
```

Remove the `addPostFrameCallback` call from the `build()` / `Consumer` body.

### 11b. Remove 15 `print()` calls from `goals_screen_enhanced.dart`

- [ ] **Step 2: Find and remove all `print(...)` statements in this file**

### 11c. Fix redundant `Colors.white : Colors.white` ternary (line ~793)

- [ ] **Step 3: Simplify**

```dart
// BEFORE:
color: !themeProvider.isDarkMode ? Colors.white : Colors.white,

// AFTER:
color: Colors.white,
```

### 11d. `welcome_onboarding_screen.dart` — Next button doesn't react to typing

- [ ] **Step 4: Add `onChanged` callback to the name `TextField`**

```dart
TextField(
  controller: _nameController,
  onChanged: (_) => setState(() {}), // triggers rebuild → button re-evaluates
  ...
)
```

### 11e. `goal_lifetime_screen.dart` — non-scrollable Column

- [ ] **Step 5: Wrap the body `Column` in a `SingleChildScrollView`**

```dart
body: SingleChildScrollView(
  child: Column(
    children: [...],
  ),
),
```

- [ ] **Step 6: Commit**
```bash
git add lib/presentation/screens/v2/goals_screen_enhanced.dart \
        lib/presentation/screens/v2/welcome_onboarding_screen.dart \
        lib/presentation/screens/v2/goal_lifetime_screen.dart
git commit -m "fix: addPostFrameCallback in build, debug prints, next button reactive, scrollable goal lifetime"
```

---

## Task 12: v3 Roadmap — Invisible Cards & No-Op Modals

**Files:**
- Modify: `lib/presentation/screens/v3/daily_roadmap_screen_v3.dart`

### 12a. Activity cards render invisible on first load

`_bounceAnimation` starts at 0.0 and controller doesn't auto-forward, so all cards are `scale: 0.8, opacity: 0.0`.

- [ ] **Step 1: In `initState`, forward the bounce controller after initial load**

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) _bounceController.forward();
});
```

Or set the initial value of the animation to 1.0 if the bounce effect is not desired on load:
```dart
_bounceController.value = 1.0; // in initState, after controller creation
```

### 12b. Options modal actions are no-ops

- [ ] **Step 2: Add the intended action or remove the options modal entirely until implemented**

At minimum, replace the no-op `onTap: () => Navigator.pop(context)` with a TODO comment and a disabled appearance, or remove the modal if it has no current purpose.

- [ ] **Step 3: Commit**
```bash
git add lib/presentation/screens/v3/daily_roadmap_screen_v3.dart
git commit -m "fix: invisible activity cards on load, no-op options modal"
```

---

## Task 13: `login_screen_v2.dart` — Security & Design System

**Files:**
- Modify: `lib/presentation/screens/v2/login_screen_v2.dart`

### 13a. Password shown in plain text in success dialog

- [ ] **Step 1: Remove the `Text('key $userPassword', ...)` line from the dialog**

This should never display any password, even a hardcoded one, in a UI element.

### 13b. Replace `withOpacity()` → `withValues(alpha:)` in file

- [ ] **Step 2: Global find/replace in this file**

- [ ] **Step 3: Commit**
```bash
git add lib/presentation/screens/v2/login_screen_v2.dart
git commit -m "fix: remove password display in UI, withOpacity deprecated"
```

---

## Task 14: Duplicate `modern_design_system.dart` Conflict

**Files:**
- Modify: `lib/presentation/screens/components/modern_design_system.dart`
- Modify: `lib/presentation/screens/v2/components/modern_design_system.dart`

The two files define conflicting `ModernCard`, `ModernSpacing`, `ModernTypography` classes. The non-v2 version (`components/modern_design_system.dart`) uses hardcoded dark-mode-only constants.

- [ ] **Step 1: Audit which screens import `components/modern_design_system.dart` vs `v2/components/modern_design_system.dart`**

```bash
grep -r "modern_design_system" lib/ --include="*.dart" -l
```

- [ ] **Step 2: For any screen importing the non-v2 version, update the import to point to the v2 version, and verify nothing breaks visually**

- [ ] **Step 3: If no file imports the non-v2 version after migration, delete `lib/presentation/screens/components/modern_design_system.dart`**

- [ ] **Step 4: Commit**
```bash
git add -A
git commit -m "fix: resolve conflicting modern_design_system files, delete unused dark-only version"
```

---

## Execution Order

Tasks are independent by file group. Recommended parallel execution:

| Parallel Batch | Tasks |
|---|---|
| Batch A | Task 1 + Task 2 (crash fixes) |
| Batch B | Task 3 + Task 4 (build-method side effects) |
| Batch C | Task 5 + Task 6 (nav/profile/calendar/notifications colors) |
| Batch D | Task 7 + Task 8 (activities group + components) |
| Batch E | Task 9 + Task 10 (analytics + v4 screens) |
| Batch F | Task 11 + Task 12 + Task 13 (goals/onboarding/login/v3) |
| Sequential | Task 14 (after all others — resolves design system conflict) |

---

## Out of Scope (Separate Future Plans)

- **Localization** — all hardcoded Spanish strings, no `intl` or ARB files
- **File decomposition** — 2000+ line files need splitting into focused widget files
- **Type safety** — replace `dynamic` entry types with strongly-typed models
- **Duplicate utility extraction** — `_isSameDay`, date formatting, mood colors across 4+ files
- **Animation performance** — pause infinite `.repeat()` controllers when offscreen
- **`FutureBuilder` in list items** — cache results outside animation scope
