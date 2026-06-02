/// Demonstrate error bars on bar chart.
fn main {
  let ctrl = [
    @moonchart.DataPoint::withErrY(0.0, 45.0, 3.0),
    @moonchart.DataPoint::withErrY(1.0, 62.0, 2.5),
    @moonchart.DataPoint::withErrY(2.0, 78.0, 4.0),
    @moonchart.DataPoint::withErrY(3.0, 91.0, 2.0),
  ]
  let treat = [
    @moonchart.DataPoint::withErrY(0.0, 38.0, 2.0),
    @moonchart.DataPoint::withErrY(1.0, 55.0, 3.0),
    @moonchart.DataPoint::withErrY(2.0, 70.0, 3.5),
    @moonchart.DataPoint::withErrY(3.0, 85.0, 2.5),
  ]

  let result = @moonchart.Chart::new()
    .title("Error Bars — v0.8")
    .xCategories(["Control", "Low Dose", "Med Dose", "High Dose"])
    .yLabel("Viability (%)")
    .yRange(0.0, 100.0)
    .series(@moonchart.Series::bar("24h", ctrl))
    .series(@moonchart.Series::bar("48h", treat)
      .withErrorColor(Some(@moonchart.Color::rgb(180, 0, 0))))
    .toSvg()

  match result {
    Ok(svg) => println(svg)
    Err(msg) => println("Error: \{msg}")
  }
}
