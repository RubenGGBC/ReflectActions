# UI/UX Bug Fix Notes

## Current iteration progress

**Completed: All hardcoded colors in `daily_detail_screen_v2.dart`**

Fixed 50+ instances of hardcoded colors across all sections:
- Gratitude section (lines 518-528)
- Tags section (lines 585-612)
- Metric cards (line 746)
- Insights generation (lines 1107-1161)
- Moments gallery (lines 1336-1410)
- Progress summary (lines 1632-1640)
- Enhanced activities (lines 1827-1888, 1902-1907)
- Goals section (lines 2063-2069)
- Roadmap section (lines 2329-2455)
- Timeline cards (lines 2487-2524)
- Priority colors (lines 2659-2671)

## Next iteration priorities

### High priority - Other files with hardcoded colors

1. **`lib/presentation/screens/v2/home_screen_v2.dart`**
   - Search for `const Color(0xFF` to find all occurrences
   - Apply same pattern: use MinimalColors.success/error/warning/info

2. **`lib/presentation/screens/v2/calendar_screen_v2.dart`**
   - 8+ occurrences of hardcoded colors

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

## Pattern to follow for color fixes

Replace:
```dart
const Color(0xFF10B981)  // -> MinimalColors.success
const Color(0xFFEF4444)  // -> MinimalColors.error
const Color(0xFFF59E0B)  // -> MinimalColors.warning
const Color(0xFF3B82F6)  // -> MinimalColors.info
const Color(0xFF8B5CF6)  // -> MinimalColors.accent
```

For theme-aware colors in widgets, use the dynamic versions:
```dart
MinimalColors.textPrimary(context)
MinimalColors.backgroundCard(context)
```

## Test after changes

Run `flutter analyze` and test in both light and dark modes to verify color consistency.
