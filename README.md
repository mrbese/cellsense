# CellSense ⚡🔋

**A personal home battery ROI calculator.**

Calculate payback periods for popular home battery systems based on your utility, rate plan, and energy profile. Compare Tesla Powerwall 3, Enphase IQ 5P, Pila Mesh, and Base Power side-by-side. *Optimized for California NEM 3.0, New England ConnectedSolutions, and ERCOT VPP programs.*

![CellSense Screenshot](https://raw.githubusercontent.com/wiki/placeholder/cellsense-hero.png)

## Features

- **16 Utilities** — PG&E, SCE, SDG&E, Con Edison, Eversource, and more
- **32 Rate Plans** — TOU schedules with peak/off-peak/super-off-peak tiers
- **4 Battery Systems** — Purchase vs. lease models with real specs & pricing
- **NEM 3.0 Support** — California net billing export rate calculations
- **VPP Earnings** — ELRP, ConnectedSolutions, ERCOT, and more
- **Show the Math** — Expandable formula breakdowns on every card
- **Charts** — Canvas-based payback timeline, savings donut, 10-year cumulative

## Quick Start

```bash
# No build step needed — just serve the files
python3 -m http.server 8765
# or
npx serve .
```

Open [http://localhost:8765](http://localhost:8765)

## How It Works

1. **Select your utility** and rate plan
2. **Enter your monthly bill** and home specs
3. **Set your priorities** — backup value, VPP participation, tax credits
4. **Compare results** — 4 battery systems with payback periods, annual savings, and 10-year net benefit

## Tech Stack

- **Zero dependencies** — Pure HTML, CSS, JavaScript (ES modules)
- **Dark glassmorphism UI** — Inter font, gradient accents, backdrop-blur cards
- **Canvas charts** — No charting library needed
- **Responsive** — Mobile-first, works on all screen sizes

## Rate Data

Rate data is accurate as of Q1 2026 and sourced from published utility tariffs. To update rates, edit the files in `js/data/`.

## License

This project is licensed under the [PolyForm Noncommercial License 1.0.0](LICENSE.md). It is free for noncommercial use; commercial use requires the author's permission.
