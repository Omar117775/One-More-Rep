# UI/UX Design System & Navigation Audit

## Brand Direction: One More Rep
- **Theme:** Dark-first Spartan warrior aesthetic.
- **Palette Hex Specification:**
  - Deep Black: `#080808`
  - Secondary Black: `#111111`
  - Dark Graphite: `#191919`
  - Metallic Gold: `#C6A15B`
  - Metallic Bronze: `#9B763B`
  - Warm White: `#F3F0E8`
  - Neutral Gray: `#929292`

---

## Navigation Redesign: Floating Rounded Dock

### Mobile (`width < 900px`)
- **Dock Appearance:** Floating rounded navigation dock detached from the bottom screen edge (`Padding` with `SafeArea`).
- **Surface & Material:** `AppColors.darkGraphite` (`#191919`) surface with 0.96 opacity.
- **Geometry:** 24px corner radius (`AppRadii.lg`) applied to all four corners.
- **Accents & Borders:** 1.2px metallic gold border with subtle ambient glow and drop shadow.
- **Destinations:** All 5 core sections preserved: Home, Train, Cardio, Progress, Settings.
- **Icon Motion:** Interactive `AnimatedIconSlot` transitions between resting and active states.

### Desktop / Tablet (`width >= 900px`)
- Transitions smoothly into an expanded `NavigationRail` with persistent view state preserved via `IndexedStack`.

---

## Internationalization & RTL
- Full support for English (LTR) and Arabic (RTL).
- Automatic text direction and component mirroring verified across all shell views.
