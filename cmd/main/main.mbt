/// Demonstrate scale system: map data values to pixels and generate ticks.
fn main {
  let scale = @moonchart.LinearScale::new(0.0, 100.0, 400.0)
  let ticks = scale.ticks(5)

  let mut svg = @moonchart.svgOpen(width=500.0, height=300.0, bg="white") + "\n"

  // Title
  svg = svg + @moonchart.text(
    x=250.0, y=30.0,
    content="Scale System v0.3 — LinearScale 0-100 → 0-400px",
    fontFamily="sans-serif", fontSize=14.0, fill="rgb(0,0,0)", textAnchor="middle",
  ) + "\n"

  // Visualize ticks as lines
  for i = 0; i < ticks.length(); i = i + 1 {
    let (pixel, label) = ticks[i]
    svg = svg + @moonchart.line(
      x1=50.0 + pixel, y1=60.0,
      x2=50.0 + pixel, y2=250.0,
      stroke="rgb(200,200,200)", strokeWidth=1.0,
    ) + "\n"
    svg = svg + @moonchart.text(
      x=50.0 + pixel, y=270.0,
      content=label, fontFamily="sans-serif", fontSize=11.0, fill="rgb(60,60,60)", textAnchor="middle",
    ) + "\n"
  }

  // Category scale example
  let catScale = @moonchart.CategoryScale::new(["A", "B", "C", "D"], 400.0)
  for i = 0; i < 4; i = i + 1 {
    let cx = 50.0 + catScale.map(i.to_double())
    svg = svg + @moonchart.circle(cx=cx, cy=150.0, r=15.0, fill="rgb(0,122,184)", stroke="none", strokeWidth=0.0) + "\n"
    svg = svg + @moonchart.text(
      x=cx, y=200.0,
      content=catScale.label(i), fontFamily="sans-serif", fontSize=12.0, fill="rgb(0,0,0)", textAnchor="middle",
    ) + "\n"
  }

  // Show a mark at 50% position
  let mid = scale.map(50.0)
  svg = svg + @moonchart.rect(x=50.0 + mid - 2.0, y=60.0, w=4.0, h=190.0, fill="rgb(212,57,57)", stroke="none", strokeWidth=0.0) + "\n"
  svg = svg + @moonchart.text(
    x=50.0 + mid, y=290.0,
    content="50.0", fontFamily="sans-serif", fontSize=10.0, fill="rgb(212,57,57)", textAnchor="middle",
  ) + "\n"

  svg = svg + @moonchart.svgClose()
  println(svg)
}
