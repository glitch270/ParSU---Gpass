# Task 5: Style Guide (PARSU-GPass)

## 1. Design tokens (these go in `style.css`)

```css
:root {
  --color-primary: #0b3d5c;   /* buttons, links, headings */
  --color-bg: #f5f7fa;        /* page background */
  --color-text: #12263a;      /* body text */
  --color-success: #23683f;
  --color-error: #a8352a;
  --font-heading: "Poppins", Arial, sans-serif;
  --font-body: "Inter", Arial, sans-serif;
  --radius: 8px;
}
```

## 2. Colors and contrast

| Token | Hex | Used for | Contrast |
|-------|-----|----------|----------|
| `--color-primary` | `#0b3d5c` | Primary buttons, links, headings, table header | White text on it: 11.4:1 |
| `--color-bg` | `#f5f7fa` | Page background | n/a |
| `--color-text` | `#12263a` | Body text | On the page background: about 14:1 |
| `--color-success` | `#23683f` | Success message, "Approved" badge | White text on it: 6.7:1 |
| `--color-error` | `#a8352a` | Error message, error border, Delete | On white: 6.5:1 |
| White | `#ffffff` | Cards, table, inputs | n/a |

All text and background pairs pass WCAG AA (4.5:1 or higher). Color is never the only signal: errors also have a message and an icon, and badges have a text label.

## 3. Typography

| Item | Font | Size and weight |
|------|------|-----------------|
| Page title (h1) | Poppins (`--font-heading`) | 28px, 600 |
| Section heading (h2) | Poppins | 20px, 600 |
| Body, inputs, table | Inter (`--font-body`) | 16px, 400, line-height 1.5 |
| Labels, buttons | Inter | 14px, 600 |
| Hints, captions | Inter | 13px, 400 |

Load both from Google Fonts. Arial is the fallback.

## 4. Spacing and shape

| Item | Value |
|------|-------|
| Spacing scale | 8px, 16px, 24px, 32px |
| Radius | `--radius` (8px) on buttons, inputs, cards |
| Card | White, 1px border `#d9dee5`, padding 24px |
| Gap between form fields | 16px |
| Max content width | 1100px, centered, with 24px side padding on phone |

## 5. Components

| Component | Look |
|-----------|------|
| Primary button | `--color-primary` background, white text, 8px radius, padding 10px 20px. Hover: slightly darker |
| Secondary button | White background, primary border and text |
| Delete button | White background, `--color-error` border and text |
| Input | White, 1px gray border, 8px radius, padding 10px 12px. Focus: 2px primary outline |
| Input error | `--color-error` border, message under the field with a "!" icon |
| Success message | `--color-success` text on a light green tint, with a check icon |
| Table | Primary-colored header row with white text, 1px row dividers |
| Status badge | Pill shape with a text label (Approved in success color, Declined in error color) |

## 6. Layout and responsive rules

| Width | Behavior |
|-------|----------|
| 769px and up | Header on top, sidebar on the left, table shows all columns |
| 768px and below | Sidebar becomes a menu button, one column |
| 390px (phone test) | The table becomes stacked cards (see `05-list-phone-390`), buttons go full width |

Layout uses `flex` and `grid`, with one `@media (max-width: 768px)` block.
