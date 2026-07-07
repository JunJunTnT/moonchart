// Example: Scatter plot with custom point shapes and auto-inferred x-axis ticks.
// Run: moon run examples/scatter_chart

///|
fn main {
  let groupA = [
    @moonchart.DataPoint::new(1.2, 2.1),
    @moonchart.DataPoint::new(2.3, 3.8),
    @moonchart.DataPoint::new(3.1, 5.2),
    @moonchart.DataPoint::new(4.5, 7.0),
    @moonchart.DataPoint::new(5.0, 9.3),
    @moonchart.DataPoint::new(6.2, 11.5),
    @moonchart.DataPoint::new(7.1, 14.0),
    @moonchart.DataPoint::new(8.3, 16.2),
  ]
  let groupB = [
    @moonchart.DataPoint::new(1.0, 3.0),
    @moonchart.DataPoint::new(2.0, 5.2),
    @moonchart.DataPoint::new(3.3, 6.8),
    @moonchart.DataPoint::new(4.0, 8.5),
    @moonchart.DataPoint::new(5.5, 10.0),
    @moonchart.DataPoint::new(6.8, 13.0),
    @moonchart.DataPoint::new(7.5, 15.5),
    @moonchart.DataPoint::new(8.0, 17.8),
  ]

  // Auto-infer x-axis ticks from data; use custom point shapes and colors
  let svg = @moonchart.Chart::new()
    .title("Correlation Analysis")
    .xLabel("Variable X")
    .yLabel("Variable Y")
    .yRange(0.0, 20.0)
    .series(
      @moonchart.Series::scatter("Group A", groupA)
      .withColor(@moonchart.Color::rgb(0, 122, 184))
      .withPointShape(@moonchart.Circle)
      .withPointSize(5.0),
    )
    .series(
      @moonchart.Series::scatter("Group B", groupB)
      .withColor(@moonchart.Color::rgb(212, 57, 57))
      .withPointShape(@moonchart.Triangle)
      .withPointSize(5.0),
    )
    .legend(true, @moonchart.TopLeft)
    // .size(500.0, 400.0)
    .save("scatter_chart.svg")

  match svg {
    Ok(s) => println(s)
    Err(e) => println("Error: \{e}")
  }
}
