# MoonChart

**MoonChart** is an SVG charting library written in MoonBit. It produces vector graphics suitable for scientific and statistical plotting — bar charts, line charts, scatter plots, and box plots — with error bars, multi-series rendering, and extensive style controls. Output is an SVG string that can be saved to a file or rendered in a browser via WASM.

Package: `JunJunTvT/moonchart`
Repository: https://github.com/JunJunTvT/moonchart
License: Apache-2.0

## Installation

```bash
moon add JunJunTvT/moonchart
```

Then import it in your MoonBit source:

```moonbit
import "JunJunTvT/moonchart"
```

## Quick Start

A minimal bar chart with error bars:

```moonbit
fn main {
  let data = [
    DataPoint::withErrY(0.0, 45.0, 3.0),
    DataPoint::withErrY(1.0, 62.0, 2.5),
  ]

  let result = Chart::new()
    .title("Cell Viability")
    .xTicks([0.0, 1.0], ["Control", "Treated"])
    .xLabel("Condition")
    .yLabel("Viability (%)")
    .yRange(0.0, 100.0)
    .series(Series::bar("24h", data))
    .toSvg()

  match result {
    Ok(svg) => println(svg)
    Err(e) => println("Error: \{e}")
  }
}
```

## Chart Types

### Bar Chart

Rectangular bars with optional error bars, grouped or stacked positioning, and bar stroke styling.

```moonbit
let data = [
  DataPoint::withErrY(0.0, 45.0, 3.0),
  DataPoint::withErrY(1.0, 62.0, 2.5),
]

Series::bar("Group A", data)
  .withColor(Color::rgb(0, 122, 184))
  .withBarStroke(Color::rgb(0, 80, 140), 1.0)
```

### Line Chart

Connected points with configurable dash styles, point shapes, and point fill colors.

```moonbit
let data = [
  DataPoint::new(0.0, 100.0),
  DataPoint::new(1.0, 85.0),
  DataPoint::new(2.0, 72.0),
]

Series::line("Trend", data)
  .withColor(Color::rgb(212, 57, 57))
  .withPointSize(5.0)
  .withPointShape(Diamond)
  .withLineStyle(Dashed)
```

### Scatter Plot

Unconnected points with customizable shape, size, and fill color.

```moonbit
let data = [
  DataPoint::new(1.2, 2.1),
  DataPoint::new(2.3, 3.8),
  DataPoint::new(3.1, 5.2),
]

Series::scatter("Group X", data)
  .withColor(Color::rgb(0, 122, 184))
  .withPointSize(5.0)
  .withPointShape(Circle)
  .withPointFill(Color::rgb(255, 0, 0))
```

### Box Plot

Box-and-whisker plot with Q1/Q3 box, median line, whiskers to the furthest points within 1.5x IQR, and outlier markers.

```moonbit
let groups = [
  BoxGroup::new(0.0, "Control", [1.2, 2.1, 3.4, 2.8, 1.9, 2.5, 3.0, 2.3]),
  BoxGroup::new(1.0, "Treated", [0.8, 1.5, 2.9, 2.1, 1.3, 1.9, 2.4, 1.7]),
]

Series::boxplot("Expression", groups)
  .withColor(Color::rgb(0, 122, 184))
  .withShowOutliers(true)
```

### Mixed Charts

Series of different types can be combined in a single chart:

```moonbit
Chart::new()
  .series(Series::bar("Experiment", barData))
  .series(Series::line("Trend", trendData).withLineStyle(Dashed))
```

## Feature Matrix

Features below are **per-series** capabilities — attributes you set on individual `Series` objects via constructor modifiers.

| Feature | Bar | Line | Scatter | BoxPlot |
|---------|:---:|:----:|:-------:|:-------:|
| Error Bars (Y) | ✓ | ✓ | ✓ | — |
| Point Shapes (5 types) | — | ✓ | ✓ | — |
| Line Styles (4 types) | — | ✓ | — | — |
| Custom Color | ✓ | ✓ | ✓ | ✓ |
| Point Fill Color | — | ✓ | ✓ | — |
| Point Size | — | ✓ | ✓ | — |
| Bar Stroke | ✓ | — | — | — |
| Outlier Display | — | — | — | ✓ |
| Dodged Groups | ✓ | — | — | ✓ |

## Builder API Reference

### Chart Builder

All methods return a new `Chart` (immutable builder pattern).

| Method | Default | Description |
|--------|---------|-------------|
| `Chart::new()` | | Create a new chart (chart type is per-series) |
| `.title(text)` | none | Chart title (centered at top) |
| `.size(w, h)` | 600 x 400 | Canvas dimensions in pixels |
| `.width(w)` | 600 | Canvas width only |
| `.height(h)` | 400 | Canvas height only |
| `.xLabel(text)` | none | X-axis label |
| `.yLabel(text)` | none | Y-axis label |
| `.xTicks(positions, labels)` | auto | X-axis tick positions and display labels |
| `.yRange(min, max)` | 0, 100 | Y-axis data range |
| `.tickFontSize(size)` | 11 | Tick label font size (both axes) |
| `.labelFontSize(size)` | 13 | Axis title font size (both axes) |
| `.yGrid(show)` | false | Y-axis grid lines |
| `.xGrid(show)` | false | X-axis grid lines |
| `.barWidthRatio(ratio)` | 0.7 | Bar/box width as fraction of band width (0.0-1.0) |
| `.barGap(gap)` | 0.0 | Gap between bars in a group, as fraction of bar width |
| `.legend(show, position)` | auto | Legend visibility and position |
| `.legendFontSize(size)` | 12 | Legend font size |
| `.margin(top, right, bottom, left)` | 40,20,40,50 | Margins around the plot area |
| `.background(color)` | white | Chart background color |
| `.fontFamily(family)` | sans-serif | Font family for all text elements |
| `.series(s)` | | Add a single data series |
| `.addSeries(ss)` | | Add multiple series at once |
| `.toSvg()` | | Render chart to an SVG string (`Result[String, String]`) |
| `.save(filename)` | | Render and write SVG to file (`Result[Unit, String]`) |
| `.toOption()` | | Export the internal `ChartOption` (escape hatch) |

### Series Constructors

| Constructor | Description |
|-------------|-------------|
| `Series::bar(name, data)` | Bar chart series |
| `Series::line(name, data)` | Line chart series |
| `Series::scatter(name, data)` | Scatter plot series |
| `Series::boxplot(name, groups)` | Box plot series |

### Series Modifiers

| Method | Default | Applies To | Description |
|--------|---------|------------|-------------|
| `.withColor(color)` | palette | all | Override series color |
| `.withLineWidth(w)` | 2.0 | line | Line stroke width |
| `.withPointSize(s)` | 4.0 | line, scatter | Data point marker radius |
| `.withPointShape(shape)` | Circle | line, scatter | Marker shape |
| `.withLineStyle(style)` | Solid | line | Line dash pattern |
| `.withPointFill(color)` | series color | line, scatter | Point fill color |
| `.withBarStroke(color, w)` | none | bar | Bar border color and width |
| `.withErrorColor(color)` | black | all with data | Error bar color (pass `None` to inherit series color) |
| `.withErrorLineWidth(w)` | 1.0 | all with data | Error bar line width |
| `.withErrorCapWidth(w)` | 6.0 | all with data | Error bar cap width |
| `.withShowOutliers(show)` | true | boxplot | Toggle outlier point display |

### Data Types

```moonbit
DataPoint::new(x, y)                         // Simple (x, y) point
DataPoint::withErrY(x, y, err)               // Symmetric error bar: y ± err
DataPoint::withAsymErrY(x, y, lo, hi)        // Asymmetric error bar: +hi, -lo

BoxGroup::new(x, label, values)              // Raw data for box plot
```

### Enums

**PointShape:** `Circle | Square | Triangle | Diamond | Cross`

**LineStyle:** `Solid | Dashed | Dotted | DashDot`

**Position:** `TopLeft | TopCenter | TopRight | BottomLeft | BottomCenter | BottomRight | Left | Right`

### Color

```moonbit
Color::rgb(r, g, b)       // Opaque color (alpha = 255)
Color::rgba(r, g, b, a)   // Color with alpha (0-255)
```

The default palette is a 6-color colorblind-friendly sequence: blue, orange, green, red, purple, brown. Override per-series with `.withColor()`.

### Axis Configuration

```moonbit
AxisOption::defaultX()     // Default X axis (auto-infer ticks from data)
AxisOption::linearY()      // Default linear Y axis [0, 100]
```

### Static API

```moonbit
render(opt : ChartOption) -> Result[String, String]     // Render a ChartOption to SVG
saveSvg(filename : String, svg : String) -> Result[Unit, String]  // Write SVG string to file
```

## WASM Usage

MoonChart can be compiled to WASM-GC for browser use. A dedicated WASM module is provided at `wasm/wasm_api.mbt` that exposes a single function:

```moonbit
pub fn render_chart(config_json : String) -> String
```

It accepts a JSON configuration string and returns an SVG string. The WASM package is configured in `wasm/moon.pkg.json` with `render_chart` as the exported function.

Build for WASM:

```bash
moon build --target wasm-gc
```

This enables rendering MoonChart graphics directly in the browser from JavaScript, with all chart types, error bars, and styling options available via a JSON-based API.

## License

Apache 2.0
