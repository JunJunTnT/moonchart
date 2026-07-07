// Example: Multi-series line chart with point markers and custom colors.
// Run: moon run examples/line_chart

///|
fn main {
  let seriesA = [
    @moonchart.DataPoint::new(0.0, 100.0),
    @moonchart.DataPoint::new(1.0, 85.0),
    @moonchart.DataPoint::new(2.0, 72.0),
    @moonchart.DataPoint::new(3.0, 58.0),
    @moonchart.DataPoint::new(4.0, 40.0),
    @moonchart.DataPoint::new(5.0, 25.0),
  ]
  let seriesB = [
    @moonchart.DataPoint::new(0.0, 95.0),
    @moonchart.DataPoint::new(1.0, 80.0),
    @moonchart.DataPoint::new(2.0, 65.0),
    @moonchart.DataPoint::new(3.0, 50.0),
    @moonchart.DataPoint::new(4.0, 35.0),
    @moonchart.DataPoint::new(5.0, 18.0),
  ]

  let svg = @moonchart.Chart::new()
    .title("Drug Concentration Over Time")
    .xTicks([0.0, 1.0, 2.0, 3.0, 4.0, 5.0], ["0h", "1h", "2h", "3h", "4h", "5h"])
    .xLabel("Time")
    .yLabel("Concentration (ng/mL)")
    .yRange(0.0, 110.0)
    .series(
      @moonchart.Series::line("Drug A", seriesA).withColor(
        @moonchart.Color::rgb(0, 122, 184),
      ),
    )
    .series(
      @moonchart.Series::line("Drug B", seriesB).withColor(
        @moonchart.Color::rgb(212, 57, 57),
      ),
    )
    .save("line_chart.svg")

  match svg {
    Ok(s) => println(s)
    Err(e) => println("Error: \{e}")
  }
}
