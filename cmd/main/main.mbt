/// Demonstrate axes + theme: first chart with axes, ticks, and title.
fn main {
  let result = @moonchart.Chart::new()
    .title("Theme & Axes — v0.5")
    .xCategories(["Jan", "Feb", "Mar", "Apr", "May", "Jun"])
    .yLabel("Value (units)")
    .yRange(0.0, 100.0)
    .size(600.0, 400.0)
    .toSvg()

  match result {
    Ok(svg) => println(svg)
    Err(msg) => println("Error: \{msg}")
  }
}
