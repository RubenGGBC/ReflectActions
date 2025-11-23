# UI/UX Bug Fix Notes

## Next iteration priorities

### Medium priority - UI/UX issues

1. **Missing loading/error states** in `home_screen_v2.dart:129-179`
   - Data loading has timeout but no user feedback on failure
   - Add loading spinner and error message display

2. **Text overflow potential** in `home_screen_v2.dart:1538`
   - Moment cards with maxLines:2 may overflow on small screens
   - Consider adding `softWrap: true` or adjusting container width

3. **Unused animation controllers** in `daily_roadmap_screen_v3.dart:30-52`
   - 10 controllers created but not all are used
   - Clean up unused controllers to avoid memory leaks

4. **Low contrast** in some backgrounds using very low alpha values
   - Review containers with `alpha: 0.1` or lower

### Low priority - Search for remaining hardcoded colors

Run this search across all v2 screens:
```bash
grep -r "const Color(0xFF" lib/presentation/screens/v2/
```

Files already cleaned:
- `daily_detail_screen_v2.dart`
- `home_screen_v2.dart`
- `calendar_screen_v2.dart`

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
