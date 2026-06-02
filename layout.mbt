// Layout engine: computes plot area, scales, and positioning.
// Uses Result type for error handling.

/// A rectangle in pixel space.
pub struct Rect {
  x : Double
  y : Double
  w : Double
  h : Double
}

/// Left edge.
pub fn Rect::left(self : Rect) -> Double {
  self.x
}

/// Right edge.
pub fn Rect::right(self : Rect) -> Double {
  self.x + self.w
}

/// Top edge.
pub fn Rect::top(self : Rect) -> Double {
  self.y
}

/// Bottom edge.
pub fn Rect::bottom(self : Rect) -> Double {
  self.y + self.h
}

/// Center X.
pub fn Rect::centerX(self : Rect) -> Double {
  self.x + self.w / 2.0
}

/// Center Y.
pub fn Rect::centerY(self : Rect) -> Double {
  self.y + self.h / 2.0
}

/// Layout result: everything renderers need.
pub struct Layout {
  /// The chart canvas rectangle (full SVG viewport).
  canvas : Rect
  /// The plot area rectangle (inside margins, where data is drawn).
  plot : Rect
  /// X-axis scale.
  xScale : CategoryScale
  /// Y-axis scale.
  yScale : LinearScale
  /// Bar dodge offsets for each series (indexed by series position).
  dodgeOffsets : Array[Double]
  /// Bar width (for bar charts).
  barWidth : Double
}

/// Compute the layout from a ChartOption.
/// Returns Result: Ok(Layout) on success, Err(message) on failure.
pub fn computeLayout(opt : ChartOption) -> Result[Layout, String] {
  // Build canvas rect
  let canvas = Rect::{ x: 0.0, y: 0.0, w: opt.width, h: opt.height }

  // Determine plot area with dynamic margins (user margin acts as minimum)
  let plotLeft = max(opt.margin.left, opt.yAxis.tickFontSize * 4.0 + opt.yAxis.labelFontSize + 10.0)
  let plotRight = opt.width - opt.margin.right
  let plotTop = max(opt.margin.top, opt.titleFont.size + 10.0)
  let plotBottom = opt.height - max(opt.margin.bottom, opt.xAxis.tickFontSize + opt.xAxis.labelFontSize + 16.0)
  let plotW = plotRight - plotLeft
  let plotH = plotBottom - plotTop

  if plotW <= 0.0 || plotH <= 0.0 {
    return Err("Plot area too small: width=\{plotW.to_string()}, height=\{plotH.to_string()}")
  }

  let plot = Rect::{ x: plotLeft, y: plotTop, w: plotW, h: plotH }

  // Build x scale from xAxis, with auto-inference from data
  let xLabels = match opt.xAxis.kind {
    Categories(labels) => {
      if labels.length() > 0 {
        labels
      } else {
        // Empty categories: auto-infer from data
        autoInferXLabels(opt.series)
      }
    }
    Linear(_, _) => autoInferXLabels(opt.series)
    _ => autoInferXLabels(opt.series)
  }
  // Division-by-zero protection: ensure at least 1 category
  let safeLabels = if xLabels.length() == 0 {
    ["0"]
  } else {
    xLabels
  }
  let xScale = CategoryScale::new(safeLabels, plotW)

  // Build y scale from yAxis
  let yScale = match opt.yAxis.kind {
    Linear(min, max) => LinearScale::new(min, max, plotH)
    _ => LinearScale::new(0.0, 100.0, plotH)
  }

  // Compute dodge offsets — for Bar and BoxPlot series
  let nDodged = countDodgedSeries(opt.series)
  let barWidth = if nDodged > 0 {
    xScale.getBandWidth() * opt.barWidthRatio / max(nDodged.to_double(), 1.0)
  } else {
    0.0
  }

  // Pre-compute dodge offsets
  let dodgeValues : Array[Double] = []
  if nDodged > 1 {
    let step = barWidth * (1.0 + opt.barGap)
    let totalWidth = barWidth * nDodged.to_double() + barWidth * opt.barGap * (nDodged.to_double() - 1.0)
    let startOffset = -totalWidth / 2.0 + barWidth / 2.0
    for i = 0; i < nDodged; i = i + 1 {
      dodgeValues.push(startOffset + i.to_double() * step)
    }
  } else if nDodged == 1 {
    dodgeValues.push(0.0)
  }

  // Map dodge offsets to all series: Bar/BoxPlot get offsets, others get 0.0
  let dodgeOffsets : Array[Double] = []
  let mut dodgeIdx = 0
  for i = 0; i < opt.series.length(); i = i + 1 {
    match opt.series[i].chartType {
      Bar => {
        dodgeOffsets.push(dodgeValues[dodgeIdx])
        dodgeIdx = dodgeIdx + 1
      }
      BoxPlot => {
        dodgeOffsets.push(dodgeValues[dodgeIdx])
        dodgeIdx = dodgeIdx + 1
      }
      _ => dodgeOffsets.push(0.0)
    }
  }

  Ok({
    canvas,
    plot,
    xScale,
    yScale,
    dodgeOffsets,
    barWidth,
  })
}

/// Auto-infer X axis labels from all series data.
/// Scans all DataPoint.x values, finds the integer range, and generates string labels.
fn autoInferXLabels(series : Array[Series]) -> Array[String] {
  if series.length() == 0 {
    return []
  }
  // Find min and max X across all series
  let mut minX = 0.0
  let mut maxX = 0.0
  let mut first = true
  for i = 0; i < series.length(); i = i + 1 {
    for j = 0; j < series[i].data.length(); j = j + 1 {
      let x = series[i].data[j].x
      if first {
        minX = x
        maxX = x
        first = false
      } else {
        if x < minX { minX = x }
        if x > maxX { maxX = x }
      }
    }
  }
  if first {
    return ["0"]
  }
  // Generate labels from minX to maxX (integer steps)
  let labels : Array[String] = []
  let start = minX.round()
  let end = maxX.round()
  let mut v = start
  while v <= end {
    labels.push(v.to_string())
    v = v + 1.0
  }
  labels
}

/// Max of two Double values (no Prelude max for Double).
fn max(a : Double, b : Double) -> Double {
  if a > b { a } else { b }
}

/// Count Bar and BoxPlot series (for dodge calculation).
fn countDodgedSeries(series : Array[Series]) -> Int {
  let mut count = 0
  for i = 0; i < series.length(); i = i + 1 {
    match series[i].chartType {
      Bar => count = count + 1
      BoxPlot => count = count + 1
      _ => ()
    }
  }
  count
}
