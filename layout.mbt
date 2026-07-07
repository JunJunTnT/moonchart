// Layout engine: computes plot area, scales, and positioning.
// Uses Result type for error handling.

///|
/// A rectangle in pixel space.
pub struct Rect {
  x : Double
  y : Double
  w : Double
  h : Double
}

///|
/// Left edge.
pub fn Rect::left(self : Rect) -> Double {
  self.x
}

///|
/// Right edge.
pub fn Rect::right(self : Rect) -> Double {
  self.x + self.w
}

///|
/// Top edge.
pub fn Rect::top(self : Rect) -> Double {
  self.y
}

///|
/// Bottom edge.
pub fn Rect::bottom(self : Rect) -> Double {
  self.y + self.h
}

///|
/// Center X.
pub fn Rect::centerX(self : Rect) -> Double {
  self.x + self.w / 2.0
}

///|
/// Center Y.
pub fn Rect::centerY(self : Rect) -> Double {
  self.y + self.h / 2.0
}

///|
/// Layout result: everything renderers need.
pub struct Layout {
  /// The chart canvas rectangle (full SVG viewport).
  canvas : Rect
  /// The plot area rectangle (inside margins, where data is drawn).
  plot : Rect
  /// X-axis scale (category/band scale).
  xScale : CategoryScale
  /// Y-axis scale.
  yScale : LinearScale
  /// Bar dodge offsets for each series (indexed by series position).
  dodgeOffsets : Array[Double]
  /// Bar width (for bar charts).
  barWidth : Double
}

///|
/// Compute the layout from a ChartOption.
/// Returns Result: Ok(Layout) on success, Err(message) on failure.
pub fn computeLayout(opt : ChartOption) -> Result[Layout, String] {
  // Build canvas rect
  let canvas = Rect::{ x: 0.0, y: 0.0, w: opt.width, h: opt.height }

  // Determine plot area with dynamic margins (user margin acts as minimum)
  let plotLeft = max(
    opt.margin.left,
    opt.yAxis.tickFontSize * 4.0 + opt.yAxis.labelFontSize + 10.0,
  )
  let plotRight = opt.width - opt.margin.right
  // Top margin: account for title
  let titleMargin = match opt.title {
    Some(_) => opt.titleFont.size + 16.0
    None => 10.0
  }
  let plotTop = max(opt.margin.top, titleMargin)
  // Bottom margin: account for x-axis ticks and label
  let xTickSpace = opt.xAxis.tickFontSize + 8.0
  let xLabelSpace = match opt.xAxis.label {
    Some(_) => opt.xAxis.labelFontSize + 4.0
    None => 0.0
  }
  let plotBottom = opt.height -
    max(opt.margin.bottom, xTickSpace + xLabelSpace + 10.0)
  let plotW = plotRight - plotLeft
  let plotH = plotBottom - plotTop

  if plotW <= 0.0 || plotH <= 0.0 {
    return Err(
      "Plot area too small: width=\{plotW.to_string()}, height=\{plotH.to_string()}",
    )
  }

  let plot = Rect::{ x: plotLeft, y: plotTop, w: plotW, h: plotH }

  // Build x-axis tick positions and labels
  let (xTicks, xLabels) = buildXTicks(opt)

  // Build x scale
  let xScale = CategoryScale::new(xTicks, xLabels, plotW)

  // Build y scale from yAxis
  let Linear(yMin, yMax) = opt.yAxis.kind
  let yScale = LinearScale::new(yMin, yMax, plotH)

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
    let totalWidth = barWidth * nDodged.to_double() +
      barWidth * opt.barGap * (nDodged.to_double() - 1.0)
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

  Ok({ canvas, plot, xScale, yScale, dodgeOffsets, barWidth })
}

///|
/// Build X-axis tick positions and labels from options or auto-inference.
fn buildXTicks(opt : ChartOption) -> (Array[Double], Array[String]) {
  // Use explicit ticks if provided
  if opt.xAxis.tickPositions.length() > 0 {
    let positions = opt.xAxis.tickPositions
    let labels = if opt.xAxis.tickLabels.length() == positions.length() {
      opt.xAxis.tickLabels
    } else {
      // Generate default labels from positions
      let gen : Array[String] = []
      for i = 0; i < positions.length(); i = i + 1 {
        gen.push(formatPosLabel(positions[i]))
      }
      gen
    }
    return (positions, labels)
  }

  // Auto-infer from series data
  autoInferXTicks(opt.series)
}

///|
/// Auto-infer X tick positions and labels from all series data.
fn autoInferXTicks(series : Array[Series]) -> (Array[Double], Array[String]) {
  if series.length() == 0 {
    return ([], [])
  }

  // Collect all unique x values from series data and box groups
  let xVals : Array[Double] = []
  for i = 0; i < series.length(); i = i + 1 {
    // Data points
    for j = 0; j < series[i].data.length(); j = j + 1 {
      let x = series[i].data[j].x
      if !containsD(xVals, x) {
        xVals.push(x)
      }
    }
    // Box groups
    for j = 0; j < series[i].boxGroups.length(); j = j + 1 {
      let x = series[i].boxGroups[j].x
      if !containsD(xVals, x) {
        xVals.push(x)
      }
    }
  }

  if xVals.length() == 0 {
    return ([0.0], ["0"])
  }

  // Sort x values
  sortDoubles(xVals)

  // Generate labels from positions
  let labels : Array[String] = []
  for i = 0; i < xVals.length(); i = i + 1 {
    labels.push(formatPosLabel(xVals[i]))
  }

  (xVals, labels)
}

///|
/// Check if array contains a double (approximate equality).
fn containsD(arr : Array[Double], val : Double) -> Bool {
  for i = 0; i < arr.length(); i = i + 1 {
    if (arr[i] - val).abs() < 0.0000000001 {
      return true
    }
  }
  false
}

///|
/// Sort an array of doubles (bubble sort for small arrays).
fn sortDoubles(arr : Array[Double]) -> Unit {
  for i = 0; i < arr.length(); i = i + 1 {
    for j = i + 1; j < arr.length(); j = j + 1 {
      if arr[i] > arr[j] {
        let tmp : Double = arr[i]
        arr[i] = arr[j]
        arr[j] = tmp
      }
    }
  }
}

///|
/// Format a position value to a label string.
fn formatPosLabel(value : Double) -> String {
  if value == Double::round(value) {
    Double::round(value).to_string()
  } else {
    value.to_string()
  }
}

///|
/// Max of two Double values (no Prelude max for Double).
fn max(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
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
