# moonchart

**moonchart** is a statistical chart SVG generation library for MoonBit. Designed for scientific plotting — bar charts, line charts, scatter plots, box plots, with error bars, multi-series rendering, and extensive style controls. Zero runtime dependencies, works on wasm-gc/js/native targets.

## Installation

```bash
moon add JunJunTvT/moonchart
```

## Quick Start

```moonbit
fn main {
  let data = [
    DataPoint::withErrY(0.0, 45.0, 3.0),
    DataPoint::withErrY(1.0, 62.0, 2.5),
    DataPoint::withErrY(2.0, 78.0, 4.0),
  ]

  Chart::new()
    .title("Cell Viability")
    .xCategories(["Ctrl", "Low", "High"])
    .yLabel("Viability (%)")
    .yRange(0.0, 100.0)
    .series(Series::bar("24h", data))
    .save("output.svg")
}
```

## Chart Types

### Bar Chart

```moonbit
Series::bar("Group A", data)
  .withColor(Color::rgb(0, 122, 184))
  .withBarStroke(Color::rgb(0, 80, 140), 1.0)  // border
```

### Line Chart

```moonbit
Series::line("Trend", data)
  .withColor(Color::rgb(212, 57, 57))
  .withPointSize(5.0)
  .withPointShape(Diamond)        // Circle | Square | Triangle | Diamond | Cross
  .withLineStyle(Dashed)          // Solid | Dashed | Dotted | DashDot
```

### Scatter Plot

```moonbit
Series::scatter("Group X", points)
  .withPointSize(4.0)
  .withPointFill(Color::rgb(255, 0, 0))
```

### Box Plot

```moonbit
let groups = [
  BoxGroup::new("Control",   [1.2, 2.1, 3.4, 2.8, ...]),
  BoxGroup::new("Treatment", [0.8, 1.5, 2.9, 2.1, ...]),
]

Series::boxplot("Expression", groups)
  .withColor(Color::rgb(0, 122, 184))
  .withShowOutliers(true)       // toggle outlier points
```

### Mixed Charts

```moonbit
Chart::new()
  .series(Series::bar("Experiment", barData))
  .series(Series::line("Trend", trendData).withLineStyle(Dashed))
```

## Data Types

### DataPoint

```moonbit
DataPoint::new(x, y)                       // simple point
DataPoint::withErrY(x, y, err)             // symmetric ± error
DataPoint::withAsymErrY(x, y, lo, hi)      // asymmetric error
```

### BoxGroup

```moonbit
BoxGroup::new("Label", [raw_values...])     // raw data for box plot
```

## Builder API

| Method | Description |
|---|---|
| `.title(text)` | Chart title |
| `.xCategories(labels)` | X axis categories |
| `.xLabel(text)` | X axis label |
| `.yLabel(text)` | Y axis label |
| `.yRange(min, max)` | Y axis range |
| `.size(w, h)` | Canvas dimensions |
| `.series(s)` | Add a data series |
| `.save(filename)` | Render and save to file |
| `.toSvg()` | Render to SVG string |
| `.toOption()` | Export `ChartOption` for advanced use |

### Axis & Tick

| Method | Default | Description |
|---|---|---|
| `.tickFontSize(size)` | 11 | Tick label font size |
| `.labelFontSize(size)` | 13 | Axis title font size |
| `.yGrid(show)` | false | Y-axis grid lines |
| `.xGrid(show)` | false | X-axis grid lines |

### Bar & Box Width

| Method | Default | Description |
|---|---|---|
| `.barWidthRatio(r)` | 0.7 | Bar/box width as fraction of band |
| `.barGap(g)` | 0.0 | Gap between bars/boxes (fraction of width) |

### Legend

| Method | Description |
|---|---|
| `.legend(show, position)` | Toggle and position (TopLeft/TopRight/BottomCenter/...) |
| `.legendFontSize(size)` | Legend font size (default 12) |

### Error Bars

```moonbit
Series::bar("data", data)
  .withErrorColor(Some(Color::rgb(180, 30, 30)))  // color (None = inherit series)
  .withErrorLineWidth(2.0)                          // line width
  .withErrorCapWidth(8.0)                           // cap width
```

### Point Shape & Line Style

```moonbit
// PointShape: Circle | Square | Triangle | Diamond | Cross
// LineStyle:  Solid | Dashed | Dotted | DashDot

Series::line("data", data)
  .withPointShape(Diamond)
  .withPointFill(Color::rgb(255, 0, 0))
  .withLineStyle(Dashed)
```

### Bar Stroke

```moonbit
Series::bar("data", data)
  .withBarStroke(Color::rgb(0, 80, 140), 1.0)  // (color, width)
```

## Static API

```moonbit
render(opt: ChartOption) -> Result[String, String]
saveSvg(filename: String, svg: String) -> Result[Unit, String]
```

## Color Palette

Default 6-color colorblind-friendly: blue → orange → green → red → purple → brown. Override per-series with `.withColor(Color::rgb(r, g, b))`.

## License

Apache-2.0
