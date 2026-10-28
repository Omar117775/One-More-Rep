# One More Rep — Design System and Localization Strategy

## Brand
- One More Rep, premium/professional, dark-first, international
- Preserve the existing logo and splash assets; do not replace user assets

## Design Tokens
- Centralize colors, typography, spacing, radii, elevation in theme
- Use reusable components, avoid hardcoded styles
- Support responsive layouts
- P5 implementation: `mobile/lib/design` contains the dark-first palette, Manrope typography, spacing/radius/elevation tokens, and `AppTheme`
- Shared cards, buttons, fields, states, charts, and navigation live in `mobile/lib/components`

## Localization
- Arabic RTL and English LTR support
- Use Flutter localization (arb) with proper directionality
- Store user locale in profile
- P5 implementation: typed EN/AR strings in `mobile/lib/localization`; language is selectable in Settings; RTL directionality is applied app-wide
- Charts remain LTR inside RTL layouts because numeric axes are direction-neutral

## Motion
- Motion must communicate state, not decorate every interaction
- Honor `MediaQuery.disableAnimations`
- P5 implementation: shell/screen transitions, chart animations, feedback states, and a state-driven Spartan companion
- No suitable Rive Spartan character asset exists; the P5 companion is Flutter `CustomPaint`. Rive/Lottie dependencies are not evidence of a licensed character asset

## Accessibility
- Follow accessibility best practices
- Support dynamic text sizing where possible
- Use meaningful labels/semantics and minimum 44dp touch targets
- Verify primary layouts do not clip or overflow in EN/LTR and AR/RTL
