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

pub fn LogScale::plotSize(self : LogScale) -> Double {
  self.plotPixels
}

// ──── CategoryScale ────

/// Categorical scale mapping indices to band centers.
pub struct CategoryScale {
  categories : Array[String]
  plotPixels : Double
  bandWidth : Double
}

/// Create a category scale.
pub fn CategoryScale::new(categories : Array[String], plotPixels : Double) -> CategoryScale {
  let bandWidth = plotPixels / categories.length().to_double()
  { categories, plotPixels, bandWidth }
}

/// Map a category index to the center of its band.
pub fn CategoryScale::map(self : CategoryScale, index : Double) -> Double {
  index * self.bandWidth + self.bandWidth / 2.0
}

/// Get the band width (for bar width calculations).
pub fn CategoryScale::getBandWidth(self : CategoryScale) -> Double {
  self.bandWidth
}

/// Number of categories.
pub fn CategoryScale::count(self : CategoryScale) -> Int {
  self.categories.length()
}

/// Get category label by index.
pub fn CategoryScale::label(self : CategoryScale, index : Int) -> String {
  self.categories[index]
}

/// Generate tick marks at category centers.
pub fn CategoryScale::ticks(self : CategoryScale, _desired : Int) -> Array[(Double, String)] {
  let ticks : Array[(Double, String)] = []
  for i = 0; i < self.categories.length(); i = i + 1 {
    let pixel = self.map(i.to_double())
    let label = self.categories[i]
    ticks.push((pixel, label))
  }
  ticks
}

pub fn CategoryScale::plotSize(self : CategoryScale) -> Double {
  self.plotPixels
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
