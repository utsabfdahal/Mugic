# Design System Specification: Luminous Precision

## 1. Overview & Creative North Star
**Creative North Star: "The Digital Atelier"**

This design system rejects the "boxed-in" nature of traditional web interfaces in favor of a high-end editorial experience. It is inspired by the precision of architectural drafting and the airy openness of a modern art gallery. 

To move beyond a "template" look, we utilize **Intentional Asymmetry** and **Tonal Depth**. By avoiding rigid grids and embracing generous white space (negative space as a functional element), we create a signature aesthetic that feels curated rather than generated. We prioritize legibility and "breathing room," ensuring every element on the screen feels light, intentional, and premium.

---

## 2. Colors: The Palette of Light
Our color strategy is built on the interplay of pure whites and soft neutrals, punctuated by a high-contrast Indigo.

### The Palette
*   **Surface (Base):** `#FFFFFF` (Pure White). The canvas must remain pristine.
*   **Primary (Indigo):** `#4648d4`. This is our "Action" color. It provides a sophisticated pop against the light surfaces.
*   **Surface Containers:** Use `surface_container_low` (#f3f3f4) and `surface_container` (#eeeeee) to define functional zones.

### The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders to section off the UI. 
Traditional lines create visual noise. Instead, define boundaries through background color shifts. A `surface_container_low` section sitting on a `surface` background creates a clear but soft boundary that feels significantly more modern and high-end than a stroked box.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the following tiers to create depth:
1.  **Level 0 (Base):** `surface` (#f9f9f9)
2.  **Level 1 (Sectioning):** `surface_container_low` (#f3f3f4)
3.  **Level 2 (Cards/Interactions):** `surface_container_lowest` (#ffffff) – This creates a "lifted" effect when placed on Level 1.

### The "Glass & Gradient" Rule
For floating elements (Modals, Popovers), use **Glassmorphism**. Apply `surface_container_lowest` at 80% opacity with a `24px` backdrop blur. 
*   **Signature Textures:** For primary CTAs, do not use flat hex codes. Apply a subtle linear gradient from `primary` (#4648d4) to `primary_container` (#6063ee) at a 135° angle to add "visual soul."

---

## 3. Typography: Editorial Authority
We use a dual-font system to balance character with readability.

*   **Display & Headlines (Manrope):** This geometric sans-serif provides a technical yet friendly "Arc-style" aesthetic. Use `display-lg` (3.5rem) with tighter letter-spacing (-0.02em) for an authoritative, editorial feel.
*   **Body & Titles (Inter):** The industry standard for legibility. 
    *   **Body-lg:** Use for long-form content to ensure the "airy" feel isn't lost in dense text.
    *   **Label-sm:** Reserved for utility metadata, always in `on_surface_variant` (#464554).

---

## 4. Elevation & Depth: Tonal Layering
In this system, shadows are a last resort, not a default.

### The Layering Principle
Achieve depth by stacking tiers. Place a `surface_container_lowest` (#ffffff) card on top of a `surface_container_low` (#f3f3f4) background. The contrast is enough to define the shape without a single pixel of border or shadow.

### Ambient Shadows
When an element must "float" (e.g., a dropdown or a floating action button):
*   **Shadow Blur:** Minimum `32px` to `64px`.
*   **Shadow Opacity:** 4% to 8%.
*   **Shadow Tint:** Use a tinted version of `on_surface` (Dark Charcoal) rather than pure black to keep the light "clean."

### The "Ghost Border" Fallback
If accessibility requirements demand a container boundary, use a **Ghost Border**:
*   **Token:** `outline_variant` (#c7c4d7)
*   **Opacity:** Set to 20%. This provides a hint of a container without breaking the minimal aesthetic.

---

## 5. Components: Precision Primitives

### Buttons
*   **Primary:** Indigo gradient (`primary` to `primary_container`). Roundedness: `full` (9999px) for that modern, pill-shaped aesthetic.
*   **Secondary:** `surface_container_high` background with `on_surface` text. No border.
*   **Tertiary:** Pure text with `primary` color. High emphasis on hover (add a 5% opacity `primary` background-tint).

### Cards
*   **Constraint:** Forbid the use of divider lines.
*   **Strategy:** Use vertical whitespace (Spacing Scale `8` or `10`) to separate content blocks within a card. Use `surface_container_low` for nested metadata blocks.

### Input Fields
*   **State:** Default state is a `surface_container_low` fill. 
*   **Focus State:** Shift to `surface_container_lowest` (white) with a 1px `primary` Ghost Border. This creates a "lighting up" effect that feels responsive and premium.

### Signature Component: The "Floating Navigation"
Instead of a pinned top-bar, use a floating dock. Apply the **Glassmorphism Rule** (80% white + blur) and a `full` roundedness scale. This reinforces the "Arc-style" aesthetic and emphasizes the airy, spacious nature of the layout.

---

## 6. Do's and Don'ts

### Do
*   **Do** embrace extreme whitespace. If a section feels "finished," add one more level of spacing (e.g., move from `6` to `8` on the spacing scale).
*   **Do** use asymmetrical layouts. Offset text blocks from images to create a dynamic, editorial flow.
*   **Do** use `primary` (#4648d4) sparingly. It is a high-contrast tool for conversion, not a decoration.

### Don't
*   **Don't** use 100% opaque, high-contrast borders. This kills the "Luminous" feel.
*   **Don't** use standard "drop shadows" with small blur radii. They look "cheap" and dated.
*   **Don't** crowd the edges of the screen. Maintain a minimum gutter of `8` (2.75rem) on all desktop layouts.