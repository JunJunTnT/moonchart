// Box plot statistics: computes five-number summary from raw data.

///|
/// Statistics for a single box plot: min, Q1, median, Q3, max, IQR, fences, whiskers, and outliers.
pub(all) struct BoxStats {
  min : Double
  q1 : Double
  median : Double
  q3 : Double
  max : Double
  iqr : Double
  lowerFence : Double
  upperFence : Double
  whiskerLow : Double
  whiskerHigh : Double
  outliers : Array[Double]
}

///|
/// Compute box plot statistics (five-number summary, IQR, fences, whiskers, outliers) from an array of values.
pub fn computeBoxStats(values : Array[Double]) -> BoxStats {
  let sorted = values.copy()
  // Sort ascending
  for i = 0; i < sorted.length(); i = i + 1 {
    for j = i + 1; j < sorted.length(); j = j + 1 {
      if sorted[i] > sorted[j] {
        let tmp = sorted[i]
        sorted[i] = sorted[j]
        sorted[j] = tmp
      }
    }
  }

  let n = sorted.length()
  let min = sorted[0]
  let max = sorted[n - 1]
  let median = percentile(sorted, 0.5)
  let q1 = percentile(sorted, 0.25)
  let q3 = percentile(sorted, 0.75)
  let iqr = q3 - q1
  let lowerFence = q1 - 1.5 * iqr
  let upperFence = q3 + 1.5 * iqr

  // Find whiskers (closest values within fences)
  let mut whiskerLow = min
  let mut whiskerHigh = max
  for i = 0; i < n; i = i + 1 {
    if sorted[i] >= lowerFence {
      whiskerLow = sorted[i]
      break
    }
  }
  let mut i = n - 1
  while i >= 0 {
    if sorted[i] <= upperFence {
      whiskerHigh = sorted[i]
      break
    }
    i = i - 1
  }

  // Collect outliers
  let outliers : Array[Double] = []
  for i = 0; i < n; i = i + 1 {
    if sorted[i] < lowerFence || sorted[i] > upperFence {
      outliers.push(sorted[i])
    }
  }

  {
    min,
    q1,
    median,
    q3,
    max,
    iqr,
    lowerFence,
    upperFence,
    whiskerLow,
    whiskerHigh,
    outliers,
  }
}

// Compute a percentile using linear interpolation between neighboring sorted elements.

///|
fn percentile(sorted : Array[Double], p : Double) -> Double {
  let n = sorted.length()
  let idx = p * (n.to_double() - 1.0)
  let lo = idx.floor().to_int()
  let hi = idx.ceil().to_int()
  if lo == hi {
    sorted[lo]
  } else {
    let frac = idx - lo.to_double()
    sorted[lo] + frac * (sorted[hi] - sorted[lo])
  }
}
