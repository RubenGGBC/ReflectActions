# V4 Analytics Test Data Seeding Instructions

## Quick Start

1. **Using Dev Tools Widget (Recommended)**
   - Run the app in debug mode
   - Look for the orange "DEV" floating button in the top-right corner
   - Tap it and select "V4 Analytics Data"
   - Wait for the success message

2. **Manual Code Execution**
   ```dart
   import 'package:your_app/test_data/v4_seeder_runner.dart';
   
   // Seed data for current user
   await V4SeederRunner.seedDataForCurrentUser(userId);
   
   // Or clear and reseed
   await V4SeederRunner.seedAndRefresh(userId);
   ```

## What Gets Generated

### 📝 Daily Entries (60 days)
- **Wellbeing metrics**: mood, energy, sleep quality, stress, motivation
- **Health data**: sleep hours, water intake, exercise, meditation
- **Productivity**: work productivity, focus level, screen time
- **Emotional data**: anxiety level, emotional stability, life satisfaction
- **Realistic trends**: gradual improvements over time with weekly/seasonal patterns

### 🎯 Goals (12 total)
- **4 Completed goals**: Meditation, walks, gratitude journal, digital detox
- **8 Active goals**: Sleep schedule, stress management, reading, hydration, etc.
- **Diverse categories**: Mindfulness, physical, emotional, sleep, stress, productivity
- **Realistic progress**: Various stages of completion

### ⚡ Interactive Moments (150+)
- **Time-based patterns**: Different types throughout the day
- **Emotional variety**: 60% positive, 40% negative/neutral for realism
- **Categories**: Work, social, exercise, mindfulness, routine, nature, etc.
- **Intensity levels**: 3-8 scale with realistic distributions

## Data Patterns

### Trending Improvements
- **Mood**: Gradual 30% improvement over 60 days
- **Energy**: 40% improvement with weekday/weekend patterns
- **Stress**: 35% reduction over time
- **Sleep Quality**: 25% improvement
- **Motivation**: 50% increase with realistic fluctuations

### Weekly Patterns
- **Weekdays**: Higher productivity, work focus, stress
- **Weekends**: Better mood, more social interaction, less stress
- **Monday**: Typically lower energy, higher stress
- **Friday**: Better mood, higher motivation

### Seasonal Adjustments
- **Spring/Summer**: Higher overall mood and energy
- **Fall/Winter**: Slightly lower mood, more introspection

## Analytics Features Enabled

✅ **Wellbeing Trends**: Line charts showing improvement over time
✅ **Goal Analytics**: Completion rates, category breakdowns, streaks
✅ **Quick Moments**: Sentiment analysis, time-of-day patterns
✅ **Motivation Insights**: Achievements, improvements, recommendations
✅ **Achievement Badges**: Goal completion, consistency streaks, positivity
✅ **Personalized Recommendations**: Based on actual patterns in the data

## Troubleshooting

### Data Not Showing
1. Check that you're using the correct userId
2. Verify the analytics screen is using the right database tables
3. Look for error messages in debug console

### Performance Issues
- The seeder generates a lot of data (200+ database entries)
- First load of analytics might take a moment
- Subsequent loads should be fast due to caching

### Clearing Data
```dart
await V4SeederRunner.clearAnalyticsData(userId);
```

## Database Tables Used

- `daily_entries`: Wellbeing and health metrics
- `user_goals`: Goal tracking and completion
- `interactive_moments`: Quick emotional moments

## Development Notes

- Seeder only runs in debug mode for safety
- Uses fixed random seed (42) for consistent test data
- Realistic patterns based on research in positive psychology
- Data designed to showcase all analytics features effectively

---

*Last updated: January 2025*