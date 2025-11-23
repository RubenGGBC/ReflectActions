# UI/UX Bug Fix Notes

## What was done this iteration

1. **Fixed touch target sizes** in `lib/presentation/widgets/progress_visualizations.dart:247-287`
   - Milestone markers increased from 24x24 to 48x48 (Material Design minimum)
   - Visual element is 32x32, outer container provides hit area

2. **Fixed hardcoded colors** in `lib/presentation/screens/v2/daily_detail_screen_v2.dart`
   - `_getScoreColor()` - now uses MinimalColors.error/warning/info/success
   - `_getScoreGradient()` - now uses MinimalColors constants
   - `_getMetricColor()` - now uses MinimalColors constants
   - `_getProgressColor()` - now uses MinimalColors constants
   - `_getCompletionColor()` - now uses MinimalColors constants

## Next iteration priorities

### High priority - More hardcoded colors in daily_detail_screen_v2.dart

Lines with `const Color(0xFF...)` that still need fixing:
- Lines 518, 520, 585, 594 - Blue colors for tags
- Lines 603, 612 - Red colors for negative tags
- Lines 1107-1161 - Metric colors in data structures
- Lines 1336, 1344, 1374, 1382 - Success/error indicators
- Lines 1409, 1410 - Boolean color selection
- Lines 1632, 1636, 1640 - Progress stat colors
- Lines 2329-2455 - Roadmap section hardcoded colors

### Medium priority - Other files with hardcoded colors

- `lib/presentation/screens/v2/home_screen_v2.dart` - Similar pattern
- `lib/presentation/screens/v2/calendar_screen_v2.dart` - 8+ occurrences

### Additional UI issues identified

1. **Missing loading/error states** in `home_screen_v2.dart:129-179`
   - Data loading has timeout but no user feedback on failure

2. **Text overflow potential** in `home_screen_v2.dart:1538`
   - Moment cards with maxLines:2 may overflow on small screens

3. **Unused animation controllers** in `daily_roadmap_screen_v3.dart:30-52`
   - 10 controllers created but not all are used

4. **Low contrast** in some backgrounds using very low alpha values

## Pattern to follow for color fixes

Replace:
```dart
const Color(0xFF10B981)  // -> MinimalColors.success
const Color(0xFFEF4444)  // -> MinimalColors.error
const Color(0xFFF59E0B)  // -> MinimalColors.warning
const Color(0xFF3B82F6)  // -> MinimalColors.info
```

For theme-aware colors in widgets, use the dynamic versions:
```dart
MinimalColors.textPrimary(context)
MinimalColors.backgroundCard(context)
```

## Test after changes

Run `flutter analyze` and test in both light and dark modes to verify color consistency.
