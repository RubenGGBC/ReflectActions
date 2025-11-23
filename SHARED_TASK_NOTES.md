# UI/UX Bug Fix Notes

## Next iteration priorities

### Medium priority - UI/UX issues

1. **Text overflow potential** in `home_screen_v2.dart:1638` (line numbers shifted after edits)
   - Moment cards with maxLines:2 may overflow on small screens
   - Consider adding `softWrap: true` or adjusting container width

2. **Unused animation controllers** in `daily_roadmap_screen_v3.dart:30-52`
   - 10 controllers created but not all are used
   - Clean up unused controllers to avoid memory leaks

3. **Low contrast** in some backgrounds using very low alpha values
   - Review containers with `alpha: 0.1` or lower

### Low priority - Search for remaining hardcoded colors

Run this search across all v2 screens:
```bash
grep -r "const Color(0xFF" lib/presentation/screens/v2/
```

Files already cleaned:
- `daily_detail_screen_v2.dart`
- `home_screen_v2.dart` - ✅ Completed (hardcoded colors in `_buildGoalCard` fixed)
- `calendar_screen_v2.dart`

## Completed this iteration

- Added loading indicator and error message feedback in `home_screen_v2.dart`
  - Shows "Cargando datos..." with spinner during initial data load
  - Shows warning banner with retry option on error
  - Users can tap the error message to retry loading
- Fixed hardcoded `Color(0xFF10B981)` in `_buildGoalCard` celebration message - now uses `MinimalColors.success`

## Pattern for color fixes

Replace:
```dart
const Color(0xFF10B981)  // -> MinimalColors.success
const Color(0xFFEF4444)  // -> MinimalColors.error
const Color(0xFFF59E0B)  // -> MinimalColors.warning
const Color(0xFF3B82F6)  // -> MinimalColors.info
const Color(0xFF8B5CF6)  // -> MinimalColors.accent
```

For gradients:
```dart
MinimalColors.positiveGradientStatic  // green gradient
MinimalColors.negativeGradientStatic  // red gradient
MinimalColors.neutralGradientStatic   // warning/amber gradient
MinimalColors.primaryGradientStatic   // blue/purple gradient
```

## Test after changes

Run `flutter analyze` and test in both light and dark modes to verify color consistency.
