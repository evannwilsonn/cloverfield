---
name: Cloverfield
description: A traffic-management-center wall for watching the Cloverleaf pipeline from outside.
colors:
  caltrans-orange: "#ff8a1f"
  caltrans-orange-ink: "#1a0f02"
  signal-live: "#3fcf86"
  signal-no-picture: "#e8b04a"
  signal-offline: "#ff6b57"
  offline-frame: "#5a231c"
  wall-black: "#0a0c0d"
  bezel-graphite: "#131719"
  tile-frame: "#1d2326"
  dark-screen: "#0e1112"
  seam: "#2a3236"
  seam-strong: "#3a454a"
  ink: "#e8edef"
  ink-secondary: "#b6c0c5"
  ink-muted: "#86939a"
  selection: "#2a4a3a"
typography:
  display:
    fontFamily: "Barlow Semi Condensed, Barlow, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(56px, 8vw, 104px)"
    fontWeight: 800
    lineHeight: 0.85
    letterSpacing: "-0.01em"
  headline:
    fontFamily: "Barlow Semi Condensed, Barlow, ui-sans-serif, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1
    letterSpacing: "0.02em"
  title:
    fontFamily: "Barlow Semi Condensed, Barlow, ui-sans-serif, system-ui, sans-serif"
    fontSize: "17px"
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: "0.01em"
  body:
    fontFamily: "Barlow, ui-sans-serif, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Barlow Semi Condensed, Barlow, ui-sans-serif, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 700
    letterSpacing: "0.08em"
  state-word:
    fontFamily: "Barlow Semi Condensed, Barlow, ui-sans-serif, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 800
    letterSpacing: "0.08em"
  field-label:
    fontFamily: "Barlow Semi Condensed, Barlow, ui-sans-serif, system-ui, sans-serif"
    fontSize: "11.5px"
    fontWeight: 600
    letterSpacing: "0.06em"
  readout:
    fontFamily: "JetBrains Mono, ui-monospace, SFMono-Regular, Menlo, monospace"
    fontSize: "20px"
    fontWeight: 700
    fontFeature: "tnum"
  readout-small:
    fontFamily: "JetBrains Mono, ui-monospace, SFMono-Regular, Menlo, monospace"
    fontSize: "12.5px"
    fontWeight: 500
rounded:
  none: "0px"
  badge: "2px"
  lamp: "50%"
spacing:
  tape-gap: "1px"
  tile-gap: "6px"
  panel-gap: "10px"
  panel-inset: "14px"
  verdict-inset: "16px"
components:
  panel:
    backgroundColor: "{colors.bezel-graphite}"
    rounded: "{rounded.none}"
  panel-heading:
    textColor: "{colors.ink-muted}"
    typography: "{typography.label}"
    padding: "10px 14px"
  incident-band-critical:
    backgroundColor: "{colors.caltrans-orange}"
    textColor: "{colors.caltrans-orange-ink}"
    rounded: "{rounded.badge}"
    padding: "4px 9px"
  incident-band-warning:
    textColor: "{colors.caltrans-orange}"
    rounded: "{rounded.badge}"
    padding: "4px 9px"
  camera-tile:
    backgroundColor: "{colors.tile-frame}"
    rounded: "{rounded.none}"
    padding: "10px 11px"
  camera-tile-dark:
    backgroundColor: "{colors.dark-screen}"
  capture-tape:
    height: "9px"
  detail-strip:
    backgroundColor: "{colors.tile-frame}"
    padding: "12px 14px"
  slot-tag:
    typography: "{typography.state-word}"
    padding: "2px 8px"
  meter:
    backgroundColor: "{colors.tile-frame}"
    width: "120px"
    height: "10px"
---

# Design System: Cloverfield

## Overview

**Creative North Star: "The Caltrans TMC Wall"**

Cloverfield is the video wall of a traffic-management center: a near-black wall, graphite bezels holding each board, a grid of camera tiles, and a verdict you can read across the room. The page is dense and set at operator distance. Headings work like highway signs, numbers read like clocks, and colour belongs to signals, never to decoration. The world is dark-first. The daylight variant is the same wall with the lights on: identical structure, retuned values.

The core idea is that **state is carried by form, and a word always goes with it**. A live feed has a solid frame, a feed with no picture is hatched, an offline feed is struck through, and a live feed that is too dark to use gets a darker screen. Each of these forms also prints its state word ("Live", "No picture", "Offline", "Live · dark"). Nothing that fails is taken off the wall. A missed schedule slot stays on the board, struck through, and a rule that is not firing still shows its live reading against its threshold.

Depth comes only from tonal layering: wall, then bezel, then frame. Every edge is square, divided by 1px seams.

**Key Characteristics:**
- Dark control-room wall with tonal steps (wall, bezel, frame) and 1px seams; no shadows.
- Barlow Semi Condensed for sign-like labels, Barlow for prose, JetBrains Mono for every clock, count and reading.
- Caltrans orange is reserved for incidents and for operator attention (focus, selection, limits).
- Green, amber and red appear only as signal states, and each is paired with a form and a word.
- Failures persist on the wall, voided rather than removed.

## Colors

The neutrals are cool graphite with a faint blue cast (hue about 229°). The only saturated colours are the three signal colours and Caltrans orange. Every token has a light-mode value, recorded in the sidecar.

### Primary
- **Caltrans Orange** (caltrans-orange): the incident colour. A critical incident gets a solid badge with Caltrans Orange Ink text, and a warning gets a 2px inset outline. Orange also marks operator attention: the 2px focus ring, the outline on a selected tile, the border of the detail strip, and the dashed 15-minute limit line in the run-time chart.
- **Caltrans Orange Ink** (caltrans-orange-ink): text on a solid orange badge.

### Secondary
- **Signal Live** (signal-live): live frames, the "Live"/"Clear"/"Met" words, healthy verdicts, met-objective meters, and successful capture segments.
- **Signal No-Picture** (signal-no-picture): no-picture frames and their hatching, "Late" slot tags, and the degraded verdict.
- **Signal Offline** (signal-offline): the offline strike line, "Missed"/"Offline" words, the down verdict, missed-objective meters, and failed steps.
- **Offline Frame** (offline-frame): the dimmed frame around an offline tile, so the strike line does the talking.

### Neutral
- **Wall Black** (wall-black): the page background.
- **Bezel Graphite** (bezel-graphite): panels, the header bar, the camera-wall housing, and the key.
- **Tile Frame** (tile-frame): camera tiles, the detail strip, meter tracks, and swatches.
- **Dark Screen** (dark-screen): the screen of a live-but-dark tile.
- **Seam** (seam): 1px dividers and panel borders, and empty tape cells.
- **Seam Strong** (seam-strong): scrollbar, link underlines, pending tag outlines, the install segment, and no-data meters.
- **Ink / Ink Secondary / Ink Muted** (ink, ink-secondary, ink-muted): primary text, supporting text, and labels/timestamps.
- **Selection** (selection): the text-selection fill.

### Named Rules
**The Signal-Only Rule.** Green, amber and red never decorate. Each one means a state, and that state is always also shown by a form (frame, hatch, strike, outline, meter tick) and a word.

**The Orange Means Attention Rule.** Caltrans orange marks things that need an operator: a firing incident, a focused or selected element, or a limit line. It never marks a healthy state.

## Typography

**Display Font:** Barlow Semi Condensed (with Barlow, system sans)
**Body Font:** Barlow (with system sans)
**Label/Mono Font:** JetBrains Mono (with ui-monospace, Menlo)

**Character:** The condensed Barlow is the California highway-sign face, used heavy and uppercase so it reads like a sign. Prose is plain Barlow. Any value that changes over time is set in mono, so readouts line up and look measured.

### Hierarchy
- **Display** (800, clamp(56px, 8vw, 104px), 0.85, uppercase): the verdict word only, with the round lamp in front of it.
- **Headline** (800, 22px, 1, uppercase, 0.02em): the wall name in the header bar.
- **Title** (600, 17px, 1.3): incident messages and detail-strip titles. Tile names use 700 at 16px/1.15 (14.5px on phones), and objective names use 600 at 15px.
- **Body** (400, 15px, 1.5): the verdict reason (16px, max 52ch), supporting lines (13–14px, ink-secondary/muted), and the footer (max 90ch).
- **Label** (700, 13px, 0.08em, uppercase, ink-muted): panel headings. A mono sub-readout sits right-aligned in the same bar.
- **State word** (800, 14px, 0.08em, uppercase): tile state words. At 11.5–13px the same style is used for severity badges, slot tags, "Clear" and objective results.
- **Field label** (600, 11.5px, 0.06em, uppercase, ink-muted): dt labels in facts, the detail strip and table headers.
- **Readout** (mono 700, 20px, tabular): headline facts. Detail values use 17px.
- **Readout small** (mono 500, 12–14px): clocks, "since" stamps, uptime, rule readings, slot times and chart axes.

### Named Rules
**The Clock Is Mono Rule.** Every time, count, percentage and threshold is set in JetBrains Mono. A number set in Barlow is a defect.

## Layout

The wall is centred with a 1400px max width. Its inline padding is clamp(12px, 2.4vw, 28px). Boards are separated by a 10px gap. Below the header bar, the top row places the verdict panel and the incident board in a 5fr/7fr split, and the lower rows reuse that split. Inside a panel, content sits 14px from the edges. Rows are separated by 1px seams, not whitespace.

The camera wall is a grid housed in a bezel, with 6px padding and 6px gutters. It runs 5 columns, dropping to 4 below 1100px, 3 below 900px (where the split rows also stack) and 2 below 560px. Tiles keep a 16:8 screen. The detail strip opens across the full row, directly after the selected tile's row, so the wall never reflows around it.

At phone width the four facts become a 2×2 grid, the incident "since" stamp drops under the message, rule readings wrap under their names, and the objectives table becomes stacked rows of name, result and meter.

## Elevation & Depth

The wall is flat. Depth comes from three tonal steps: wall black, then bezel graphite, then tile frame, each bounded by a 1px seam. There are no drop shadows. Inset box-shadows are used only as square frames: the 2px state frames on tiles and swatches, the 1.5px outlines on slot tags, the 2px warning badge outline, and the 1px meter track.

### Named Rules
**The Bezel Not Shadow Rule.** To lift something, put it in a bezel or frame one tonal step up. Do not cast a shadow.

## Shapes

All corners are square (0). The 2px radius is used only on the severity badge and the focus ring. Fully round shapes are kept for the verdict lamp. Shapes carry state: a solid 2px frame means live, a 135° hatch (7px gap, 2px stripe, signal colour at 22%) means no picture, a single diagonal strike at 50% opacity means offline, and a struck-through slot time means missed.

## Components

### Panels
- **Shape:** Square bezel-graphite box with a 1px seam border.
- **Heading:** A label-style bar (10px 14px) with a seam under it and a mono sub-readout on the right ("1 firing", "every 30 min", "bar = last 7 days · tick = target").

### Verdict Panel
The verdict word in Display, coloured by state, with a round lamp in front that blinks (1.6s, two-step) only when the state is down. Below it is the one-line reason, and below that is a four-cell facts strip (field label, mono readout, small mono qualifier) divided by seams.

### Incident Board
- **Band:** One message per band: severity badge, title-weight message with a body sub-line, and a mono "since" stamp on the right.
- **Critical:** Solid Caltrans orange badge with orange-ink text. **Warning:** Transparent badge with a 2px inset orange outline.
- **Not firing:** Below the bands, under a "Not firing" label, every quiet rule gets a row: a green "Clear" word, the rule name, and its live mono reading against its threshold. An empty board shows a calm sentence saying why empty means healthy.

### Camera Tile (signature)
- **Structure:** A button with a 16:8 screen holding camera ID · route (mono, muted), an on-screen clock top-right, the place name (Title) and a state row (state word on the left, mono 24h uptime on the right). Under the screen runs the capture tape.
- **States:** Live has a 2px live frame. Live-but-dark has the live frame on a dark-screen fill. No picture has a 2px amber frame and amber hatching. Offline has a dim red frame and a diagonal strike, with text knocked out on frame-coloured patches so it stays legible over the line.
- **Hover / Focus:** The screen lightens by mixing 6% ink into the frame. Focus uses the global orange ring, offset inward by 2px. When selected, the tile gets a 2px orange outline and opens the detail strip.
- **Order:** Worst first, by 24h uptime.

### Capture Tape
Forty-eight 9px cells with 1px gaps, oldest on the left and newest on the right. Each cell is coloured by that capture's state. Live-but-dark cells are the live colour mixed 45% into the frame, and slots with no capture use the seam colour.

### Detail Strip
A full-row frame panel with a 1px orange border, in a 6-column grid (3 below 900px, 2 below 560px). It shows the camera name, mono corridor and capture count, then field-label/readout pairs. It opens in place and closes when the same tile is selected again.

### Schedule Board
Mono rows: slot time (5.5ch), a plain-language outcome, and an outlined tag (On time, Late, Missed, Due, Manual). Missed slots stay on the board, with a 2px red strike through their time.

### Objectives Meter
A 120×10px frame track with a 1px seam inset. The fill shows the 7-day value in the state colour, and a 2px ink tick, extending 4px past the track, marks the target. Meters line up in their own column.

### Key
A bezel strip under the wall with an 18×12px swatch for each tile state. Each swatch repeats the tile's frame, hatch or strike, alongside a written definition.

## Do's and Don'ts

### Do:
- **Do** show every state with a form and a word together: solid frame "Live", hatch "No picture", strike "Offline", dark screen "Live · dark".
- **Do** keep failures on the wall. Strike missed slots through and list quiet rules with their reading and threshold ("fires at 3").
- **Do** set every clock, count and threshold in JetBrains Mono with tabular figures.
- **Do** add depth with wall → bezel → frame tonal steps and 1px seams.
- **Do** keep Caltrans orange for incidents and operator attention (focus ring, selection, limit lines).
- **Do** retune values for daylight from the light token set rather than inventing new ones, and keep the dark wall as the primary world.
- **Do** respect reduced motion. The down-lamp blink is the only animation, and it stops under prefers-reduced-motion.

### Don't:
- **Don't** use green, amber or red as the only carrier of a state, or as decoration.
- **Don't** remove or hide a failed item to tidy the wall. Void it in place.
- **Don't** round panels or tiles. Corners stay square, and 2px is only for the severity badge and the focus ring.
- **Don't** cast drop shadows. Use inset rings only as square frames.
- **Don't** use Caltrans orange for healthy or neutral states.
- **Don't** treat hatching as decoration elsewhere. The 135° hatch means "no picture".
