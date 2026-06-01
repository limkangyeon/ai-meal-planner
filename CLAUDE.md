# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                       # Install dependencies
flutter run                           # Run app in debug mode
flutter analyze                       # Lint (analysis_options.yaml)
flutter pub run build_runner build    # Regenerate Hive adapters and other generated code
flutter build apk                     # Release APK
flutter build aab                     # Release App Bundle
```

There are currently no test files. When tests are added, run them with `flutter test` or `flutter test test/path/to_test.dart` for a single file.

## Required Setup

Before running the app:
1. Create a `.env` file (see `.env.example`):
   ```
   GEMINI_API_KEY=<from ai.google.dev>
   COUPANG_PARTNER_CODE=<Coupang affiliate code>
   ```
2. Place `google-services.json` (Android) at `android/app/google-services.json`. See `docs/FIREBASE_SETUP.md` for the full Firebase setup guide.

## Architecture

This is a Flutter mobile app with a Provider-based layered architecture:

```
Screens → Providers → Services → Firebase / External APIs
              ↓
           Models
```

**Layers:**
- `lib/models/` — Pure data classes with JSON serialization. `UserProfile`, `MealPlan`, `DailyMealPlan`, `Meal`, `Ingredient`, `NutritionInfo`. Barrel exported via `models.dart`.
- `lib/providers/` — `ChangeNotifier` classes that hold app state and orchestrate business logic. Three providers: `UserProvider` (auth + profile), `MealPlanProvider` (CRUD + AI generation), `ShoppingListProvider` (ingredient aggregation). All registered in `main.dart` via `MultiProvider`.
- `lib/services/` — External integrations only. `GeminiService` calls the Gemini REST API to generate meal plans; `CoupangPartnersService` builds affiliate links and tracks clicks via `SharedPreferences`.
- `lib/screens/` — UI only. Screens read/dispatch via `Provider.of` or `context.watch`. Organized by feature: `auth/`, `onboarding/`, `home/`, `meal_plan/`, `shopping/`, `community/`, `profile/`.
- `lib/widgets/` — Reusable components. `MealCard`, `NutritionChart`, `CoupangWidgets`, etc.
- `lib/utils/` — `AppRouter` (GoRouter + ShellRoute for bottom tab nav), `AppTheme` (light/dark), `helpers.dart`.

## Key Data Flows

**Auth flow:** `SplashScreen` → checks `UserProvider.isLoggedIn` → login/signup → Firestore profile load → if `onboardingCompleted == false` → onboarding → home.

**Meal generation:** `MealGenerationScreen` → `MealPlanProvider.generateMealPlan()` → `GeminiService.generateMealPlan()` builds a detailed prompt from `UserProfile` (diet goal, allergies, meals/day, budget, difficulty) → POST to Gemini 2.5 Flash-Lite REST endpoint → parse JSON response → save to Firestore `mealPlans/{planId}` → update local state with progress callbacks.

**Shopping list:** `ShoppingListProvider` reads ingredients from the current `MealPlan`, deduplicates/merges quantities, groups by category, and optionally attaches Coupang affiliate links per ingredient.

## Firestore Schema

```
users/{userId}            — profile, preferences, onboardingCompleted
mealPlans/{planId}        — userId, dailyPlans[], ingredients[], isShared, likes
sharedMealPlans/{planId}  — same shape as mealPlans, public to all authenticated users
ratings/{ratingId}        — userId, mealId, rating, comment
```

Security rules: users read/write only their own data; `sharedMealPlans` is readable by any authenticated user; ratings are writable only by the author.

## External APIs

- **Google Gemini 2.5 Flash-Lite** — `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent`. Temperature 0.7, max tokens 8192, response MIME `application/json`.
- **Coupang Partners** — `https://link.coupang.com/a/{partnerCode}`. Affiliate links for shopping list items; requires a legal disclosure notice (공정거래위원회 guideline) whenever links are displayed.

## Code Generation

Hive models use `build_runner`. After modifying any Hive-annotated class, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
Generated files (`*.g.dart`) are excluded from linting in `analysis_options.yaml`.
