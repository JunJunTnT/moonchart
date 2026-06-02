/// Demonstrate bar chart: first complete data chart with bars.
fn main {
  let ctrl = [
    @moonchart.DataPoint::new(0.0, 45.0),
    @moonchart.DataPoint::new(1.0, 62.0),
    @moonchart.DataPoint::new(2.0, 78.0),
    @moonchart.DataPoint::new(3.0, 91.0),
  ]
  let treat = [
    @moonchart.DataPoint::new(0.0, 38.0),
    @moonchart.DataPoint::new(1.0, 55.0),
    @moonchart.DataPoint::new(2.0, 70.0),
    @moonchart.DataPoint::new(3.0, 85.0),
  ]

  let result = @moonchart.Chart::new()
    .title("Bar Chart — v0.6")
    .xCategories(["Control", "Low Dose", "Med Dose", "High Dose"])
    .yLabel("Viability (%)")
    .yRange(0.0, 100.0)
    .series(@moonchart.Series::bar("24h", ctrl))
    .series(@moonchart.Series::bar("48h", treat))
    .toSvg()

  match result {
    Ok(svg) => println(svg)
    Err(msg) => println("Error: \{msg}")
  }
}
