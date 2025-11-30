# UI/UX Bug Fix Notes

## Next iteration priorities

### Medium priority - UI/UX issues

1. **Low contrast** in some backgrounds using very low alpha values
   - Review containers with `alpha: 0.1` or lower in v2/v3 screens
   - Check text readability in both light and dark modes

2. **Search remaining v2/v3 screens for hardcoded colors**
   - Run: `grep -r "Color(0xFF" lib/presentation/screens/v2/` and v3
   - Files cleaned: `daily_detail_screen_v2.dart`, `home_screen_v2.dart`, `calendar_screen_v2.dart`

### Low priority - Code quality

1. **Review other screens for similar issues**:
   - Check v3 screens for missing loading/error states
   - Audit other animation controllers for unused allocations

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
