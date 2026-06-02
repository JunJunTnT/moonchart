<<<<<<< HEAD
/// Minimal example: output a hardcoded SVG with basic shapes.
fn main {
  let mut svg = @moonchart.svgOpen(width=400.0, height=300.0, bg="white") + "\n"
  // A blue rectangle
  svg = svg + @moonchart.rect(x=50.0, y=50.0, w=300.0, h=200.0, fill="rgb(0,122,184)", stroke="none", strokeWidth=0.0) + "\n"
  // A red circle
  svg = svg + @moonchart.circle(cx=200.0, cy=150.0, r=40.0, fill="rgb(212,57,57)", stroke="white", strokeWidth=2.0) + "\n"
  // Text label
  svg = svg + @moonchart.text(x=200.0, y=280.0, content="Moonchart v0.1", fontFamily="sans-serif", fontSize=16.0, fill="rgb(0,0,0)", textAnchor="middle") + "\n"
=======
/// Demonstrate data model types: construct data points and print info.
fn main {
  let red = @moonchart.Color::rgb(212, 57, 57)
  let blue = @moonchart.Color::rgb(0, 122, 184)

  // Build data points with errors
  let data = [
    @moonchart.DataPoint::withErrY(0.0, 45.0, 3.0),
    @moonchart.DataPoint::withErrY(1.0, 62.0, 2.5),
    @moonchart.DataPoint::new(2.0, 78.0),
  ]

  // Build a series
  let series = @moonchart.Series::bar("Sample", data).withColor(blue)

  // Build axis options
  let xAxis = @moonchart.AxisOption::categories(["A", "B", "C"])
  let yAxis = @moonchart.AxisOption::linearY()

  // Build ChartOption
  let opt = @moonchart.ChartOption::new(xAxis, yAxis, [series])

  // Output a simple SVG with the color from our data model
  let mut svg = @moonchart.svgOpen(width=400.0, height=200.0, bg="white") + "\n"
  svg = svg + @moonchart.text(
    x=200.0, y=50.0,
    content="Data Model v0.2",
    fontFamily="sans-serif", fontSize=16.0, fill=red.toSvg(), textAnchor="middle",
  ) + "\n"
  svg = svg + @moonchart.text(
    x=200.0, y=80.0,
    content="Series: \{series.name}, Points: \{data.length().to_string()}",
    fontFamily="sans-serif", fontSize=12.0, fill="rgb(0,0,0)", textAnchor="middle",
  ) + "\n"
  svg = svg + @moonchart.text(
    x=200.0, y=110.0,
    content="Size: \{opt.width.to_string()}x\{opt.height.to_string()}",
    fontFamily="sans-serif", fontSize=12.0, fill="rgb(0,0,0)", textAnchor="middle",
  ) + "\n"
  svg = svg + @moonchart.circle(cx=70.0, cy=150.0, r=10.0, fill=blue.toSvg(), stroke="none", strokeWidth=0.0) + "\n"
  svg = svg + @moonchart.circle(cx=200.0, cy=150.0, r=10.0, fill=red.toSvg(), stroke="none", strokeWidth=0.0) + "\n"
  svg = svg + @moonchart.rect(x=300.0, y=140.0, w=20.0, h=20.0, fill=blue.toHex(), stroke="none", strokeWidth=0.0) + "\n"
>>>>>>> facf8f3 (update data model)
  svg = svg + @moonchart.svgClose()

  println(svg)
}
