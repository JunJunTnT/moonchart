// Scale system: maps data values to pixel coordinates.

/// Trait for coordinate mapping from data space to pixel space.
pub trait Scale {
  /// Map a data value to a pixel coordinate within [0, plotSize].
  map(Self, Double) -> Double
  /// Generate tick positions and labels for this scale.
  ticks(Self, Int) -> Array[(Double, String)]
  /// The size (width or height) of the plot area in pixels.
  plotSize(Self) -> Double
}

// ──── LinearScale ────

/// Linear numeric scale mapping [min, max] to [0, plotPixels].
pub struct LinearScale {
  min : Double
  max : Double
  plotPixels : Double
}

/// Create a linear scale.
pub fn LinearScale::new(min : Double, max : Double, plotPixels : Double) -> LinearScale {
  { min, max, plotPixels }
}

/// Map a data value to pixel position (linear interpolation).
pub fn LinearScale::map(self : LinearScale, value : Double) -> Double {
  (value - self.min) / (self.max - self.min) * self.plotPixels
}

/// Inverse map: pixel position to data value.
pub fn LinearScale::unmap(self : LinearScale, pixel : Double) -> Double {
  pixel / self.plotPixels * (self.max - self.min) + self.min
}

/// Generate nice tick positions using the 1/2/5×10^n algorithm.
pub fn LinearScale::ticks(self : LinearScale, desired : Int) -> Array[(Double, String)] {
  let range = self.max - self.min
  let roughStep = range / desired.to_double()
  // Snap to nice number: 1, 2, or 5 × 10^n
  let magnitude = pow10(orderOfMagnitude(roughStep))
  let ratio = roughStep / magnitude
  let niceStep = if ratio < 1.5 {
    magnitude
  } else if ratio < 3.0 {
    2.0 * magnitude
  } else if ratio < 7.0 {
    5.0 * magnitude
  } else {
    10.0 * magnitude
  }
  // Start at the first nice tick >= min
  let start = Double::ceil(self.min / niceStep) * niceStep
  // Generate ticks
  let ticks : Array[(Double, String)] = []
  let mut val = start
  while val <= self.max + niceStep * 0.5 {
    let pixel = self.map(val)
    let label = formatTick(val)
    ticks.push((pixel, label))
    val = val + niceStep
  }
  ticks
}

/// Return the plot size (width or height) in pixels.
pub fn LinearScale::plotSize(self : LinearScale) -> Double {
  self.plotPixels
}

// ──── LogScale ────

/// Logarithmic scale mapping [min, max] to [0, plotPixels].
pub struct LogScale {
  base : Double
  min : Double
  max : Double
  plotPixels : Double
}

/// Create a logarithmic scale.
pub fn LogScale::new(base : Double, min : Double, max : Double, plotPixels : Double) -> LogScale {
  { base, min, max, plotPixels }
}

/// Map data value to pixel using log mapping.
pub fn LogScale::map(self : LogScale, value : Double) -> Double {
  let logMin = logBase(self.base, self.min)
  let logMax = logBase(self.base, self.max)
  let logVal = logBase(self.base, value)
  (logVal - logMin) / (logMax - logMin) * self.plotPixels
}

/// Generate ticks at powers of the base.
pub fn LogScale::ticks(self : LogScale, _desired : Int) -> Array[(Double, String)] {
  let logMin = Double::ceil(logBase(self.base, self.min))
  let logMax = Double::floor(logBase(self.base, self.max))
  let ticks : Array[(Double, String)] = []
  let mut exp = logMin
  while exp <= logMax {
    let val = @math.pow(self.base, exp)
    if val >= self.min && val <= self.max {
      let pixel = self.map(val)
      let label = formatTick(val)
      ticks.push((pixel, label))
    }
    exp = exp + 1.0
  }
  ticks
}

/// Return the plot size (width or height) in pixels.
pub fn LogScale::plotSize(self : LogScale) -> Double {
  self.plotPixels
}

// ──── CategoryScale ────

/// Category/band scale: maps data x-values to band centers.
/// Supports explicit tick positions/labels and auto-inference.
pub struct CategoryScale {
  /// Tick positions in data coordinates.
  tickPositions : Array[Double]
  /// Tick labels for display.
  tickLabels : Array[String]
  /// Plot width in pixels.
  plotPixels : Double
  /// Band width (for bar/box dodging).
  bandWidth : Double
  /// Minimum data x value (for continuous mapping).
  dataMin : Double
  /// Maximum data x value (for continuous mapping).
  dataMax : Double
}

/// Create a category scale from tick positions and labels.
/// When positions is empty, auto-inference is used (handled by layout).
pub fn CategoryScale::new(
  tickPositions : Array[Double],
  tickLabels : Array[String],
  plotPixels : Double
) -> CategoryScale {
  let n = tickPositions.length()
  // Compute band width based on minimum gap between adjacent positions.
  // This correctly handles non-uniform tick spacing.
  let bandWidth = if n <= 1 {
    plotPixels
  } else {
    let mut minGap = tickPositions[1] - tickPositions[0]
    for i = 1; i < n - 1; i = i + 1 {
      let gap = tickPositions[i + 1] - tickPositions[i]
      if gap < minGap {
        minGap = gap
      }
    }
    if minGap <= 0.0 {
      minGap = 1.0
    }
    // Convert min data gap to pixel space via linear scaling
    let dataRange = tickPositions[n - 1] - tickPositions[0]
    if dataRange > 0.0 {
      minGap / dataRange * plotPixels
    } else {
      plotPixels
    }
  }
  let (dataMin, dataMax) = if n == 0 {
    (0.0, 1.0)
  } else if n == 1 {
    (tickPositions[0] - 0.5, tickPositions[0] + 0.5)
  } else {
    let halfStep = (tickPositions[n - 1] - tickPositions[0]) / (n.to_double() - 1.0) / 2.0
    (tickPositions[0] - halfStep, tickPositions[n - 1] + halfStep)
  }
  { tickPositions, tickLabels, plotPixels, bandWidth, dataMin, dataMax }
}

/// Map a data value to pixel using linear interpolation.
pub fn CategoryScale::map(self : CategoryScale, value : Double) -> Double {
  let range = self.dataMax - self.dataMin
  if range == 0.0 {
    self.plotPixels / 2.0
  } else {
    (value - self.dataMin) / range * self.plotPixels
  }
}

/// Inverse map: pixel position to data value.
pub fn CategoryScale::unmap(self : CategoryScale, pixel : Double) -> Double {
  let range = self.dataMax - self.dataMin
  if range == 0.0 {
    self.dataMin
  } else {
    pixel / self.plotPixels * range + self.dataMin
  }
}

/// Find the band center pixel for a data value.
/// Uses data-coordinate mapping to correctly handle non-uniform tick spacing.
pub fn CategoryScale::bandCenter(self : CategoryScale, value : Double) -> Double {
  self.map(value)
}

/// Get the band width (for bar width calculations).
pub fn CategoryScale::getBandWidth(self : CategoryScale) -> Double {
  self.bandWidth
}

/// Number of tick positions.
pub fn CategoryScale::count(self : CategoryScale) -> Int {
  self.tickPositions.length()
}

/// Get tick label by index.
pub fn CategoryScale::label(self : CategoryScale, index : Int) -> String {
  if index >= 0 && index < self.tickLabels.length() {
    self.tickLabels[index]
  } else {
    ""
  }
}

/// Get tick position by index.
pub fn CategoryScale::position(self : CategoryScale, index : Int) -> Double {
  if index >= 0 && index < self.tickPositions.length() {
    self.tickPositions[index]
  } else {
    0.0
  }
}

/// Generate tick marks at data-coordinate positions.
/// Tick positions are mapped via data-coordinate interpolation (not index-based).
pub fn CategoryScale::ticks(self : CategoryScale, _desired : Int) -> Array[(Double, String)] {
  let n = self.tickPositions.length()
  if n == 0 {
    return []
  }
  let ticks : Array[(Double, String)] = []
  for i = 0; i < n; i = i + 1 {
    let pixel = self.map(self.tickPositions[i])
    let label = if i < self.tickLabels.length() { self.tickLabels[i] } else { self.tickPositions[i].to_string() }
    ticks.push((pixel, label))
  }
  ticks
}

/// Return the plot size (width or height) in pixels.
pub fn CategoryScale::plotSize(self : CategoryScale) -> Double {
  self.plotPixels
}

/// Get min/max data range for the category scale.
pub fn CategoryScale::dataRange(self : CategoryScale) -> (Double, Double) {
  (self.dataMin, self.dataMax)
}

// ──── Helper functions ────

/// Compute log with arbitrary base: log_base(x) = ln(x) / ln(base).
fn logBase(base : Double, x : Double) -> Double {
  @math.ln(x) / @math.ln(base)
}

/// 10 raised to power n using math.pow.
fn pow10(n : Double) -> Double {
  @math.pow(10.0, n)
}

/// Order of magnitude (floor of log10).
fn orderOfMagnitude(x : Double) -> Double {
  Double::floor(@math.log10(x))
}

/// Format a tick value to a nice string (avoid trailing zeros).
fn formatTick(value : Double) -> String {
  if value == Double::round(value) {
    Double::round(value).to_string()
  } else {
    value.to_string()
  }
}
