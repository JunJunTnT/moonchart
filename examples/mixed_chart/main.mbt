// Example: Mixed chart combining bar and line series on shared x-axis.
// Run: moon run examples/mixed_chart
fn main {
  let barData = [
    @moonchart.DataPoint::withErrY(0.0, 35.0, 4.0),
    @moonchart.DataPoint::withErrY(1.0, 52.0, 3.5),
    @moonchart.DataPoint::withErrY(2.0, 68.0, 5.0),
    @moonchart.DataPoint::withErrY(3.0, 82.0, 3.0),
  ]
  let trendData = [
    @moonchart.DataPoint::new(0.0, 20.0),
    @moonchart.DataPoint::new(1.0, 40.0),
    @moonchart.DataPoint::new(2.0, 60.0),
    @moonchart.DataPoint::new(3.0, 80.0),
  ]

  let svg = @moonchart.Chart::new()
    .title("Expression Levels with Trend")
    .xTicks([0.0, 1.0, 2.0, 3.0], ["0h", "6h", "12h", "24h"])
    .xLabel("Time Point")
    .yLabel("Expression (fold change)")
    .yRange(0.0, 100.0)
    .yGrid(true)
    .series(@moonchart.Series::bar("mRNA Level", barData))
    .series(
      @moonchart.Series::line("Expected Trend", trendData)
        .withColor(@moonchart.Color::rgb(212, 57, 57))
        .withPointSize(3.0)
    )
    .toSvg()

  match svg {
    Ok(s) => println(s)
    Err(e) => println("Error: \{e}")
  }
}
