///|
fn main {
  let data = [
    @moonchart.DataPoint::withErrY(0.0, 45.0, 3.0),
    @moonchart.DataPoint::withAsymErrY(1.0, 62.0, 2.5, 7.5),
  ]

  let result = @moonchart.Chart::new()
    .title("Cell Viability")
    .xTicks([0.0, 1.0], ["Control", "Treated"])
    .xLabel("Condition")
    .yLabel("Viability (%)")
    .yRange(0.0, 100.0)
    .barWidthRatio(0.4)
    .series(@moonchart.Series::bar("24h", data))
    .toSvg()

  match result {
    Ok(svg) => println(svg)
    Err(e) => println("Error: \{e}")
  }
}
