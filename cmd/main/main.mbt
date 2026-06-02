/// Demonstrate line + scatter charts with shapes and styles.
fn main {
  let lineData = [
    @moonchart.DataPoint::new(0.0, 100.0),
    @moonchart.DataPoint::new(1.0, 85.0),
    @moonchart.DataPoint::new(2.0, 72.0),
    @moonchart.DataPoint::new(3.0, 58.0),
    @moonchart.DataPoint::new(4.0, 40.0),
    @moonchart.DataPoint::new(5.0, 25.0),
  ]
  let scatterData = [
    @moonchart.DataPoint::new(1.2, 90.0),
    @moonchart.DataPoint::new(2.3, 75.0),
    @moonchart.DataPoint::new(3.1, 60.0),
    @moonchart.DataPoint::new(4.5, 45.0),
    @moonchart.DataPoint::new(5.0, 30.0),
  ]

  let result = @moonchart.Chart::new()
    .title("Line & Scatter — v0.7")
    .xLabel("Time (hours)")
    .yLabel("Concentration (ng/mL)")
    .yRange(0.0, 110.0)
    .series(
      @moonchart.Series::line("Drug A", lineData)
        .withColor(@moonchart.Color::rgb(0, 122, 184))
        .withPointShape(@moonchart.Diamond)
    )
    .series(
      @moonchart.Series::scatter("Observed", scatterData)
        .withColor(@moonchart.Color::rgb(212, 57, 57))
        .withPointSize(5.0)
    )
    .toSvg()

  match result {
    Ok(svg) => println(svg)
    Err(msg) => println("Error: \{msg}")
  }
}
