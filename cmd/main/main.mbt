/// Demonstrate legend, grid lines, and advanced styles.
fn main {
  let ctrl = [
    @moonchart.DataPoint::withErrY(0.0, 45.0, 3.0),
    @moonchart.DataPoint::withErrY(1.0, 62.0, 2.5),
    @moonchart.DataPoint::withErrY(2.0, 78.0, 4.0),
    @moonchart.DataPoint::withErrY(3.0, 91.0, 2.0),
  ]
  let trend = [
    @moonchart.DataPoint::new(0.0, 50.0),
    @moonchart.DataPoint::new(1.0, 65.0),
    @moonchart.DataPoint::new(2.0, 80.0),
    @moonchart.DataPoint::new(3.0, 95.0),
  ]

  let result = @moonchart.Chart::new()
    .title("Legend & Styles — v0.9")
    .xCategories(["Control", "Low Dose", "Med Dose", "High Dose"])
    .yLabel("Viability (%)")
    .yRange(0.0, 110.0)
    .yGrid(true)
    .legend(true, @moonchart.TopRight)
    .legendFontSize(11.0)
    .series(
      @moonchart.Series::bar("24h Viability", ctrl)
        .withBarStroke(@moonchart.Color::rgb(0, 80, 150), 1.0)
    )
    .series(
      @moonchart.Series::line("Trend", trend)
        .withColor(@moonchart.Color::rgb(212, 57, 57))
        .withLineStyle(@moonchart.Dashed)
        .withPointSize(3.0)
    )
    .toSvg()

  match result {
    Ok(svg) => println(svg)
    Err(msg) => println("Error: \{msg}")
  }
}
