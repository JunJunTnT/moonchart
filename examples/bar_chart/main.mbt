// Example: Grouped bar chart with error bars.
// Run: moon run examples/bar_chart
fn main {
  let ctrlData = [
    @moonchart.DataPoint::withErrY(0.0, 45.0, 3.0),
    @moonchart.DataPoint::withErrY(1.0, 62.0, 2.5),
    @moonchart.DataPoint::withErrY(2.0, 78.0, 4.0),
    @moonchart.DataPoint::withErrY(3.0, 91.0, 2.0),
  ]
  let treatData = [
    @moonchart.DataPoint::withErrY(0.0, 38.0, 2.0),
    @moonchart.DataPoint::withErrY(1.0, 55.0, 3.0),
    @moonchart.DataPoint::withErrY(2.0, 70.0, 3.5),
    @moonchart.DataPoint::withErrY(3.0, 85.0, 2.5),
  ]

  let svg = @moonchart.Chart::new()
    .title("Cell Viability After Treatment")
    .xTicks([0.0, 1.0, 2.0, 3.0], ["Control", "Low Dose", "Med Dose", "High Dose"])
    .xLabel("Treatment Group")
    .yLabel("Viability (%)")
    .yRange(0.0, 100.0)
    .series(@moonchart.Series::bar("24h", ctrlData))
    .series(@moonchart.Series::bar("48h", treatData))
    .save("bar_chart.svg")

  match svg {
    Ok(s) => println(s)
    Err(e) => println("Error: \{e}")
  }
}
