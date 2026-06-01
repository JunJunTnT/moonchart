/// Minimal example: output a hardcoded SVG with basic shapes.
fn main {
  let mut svg = @moonchart.svgOpen(width=400.0, height=300.0, bg="white") + "\n"
  // A blue rectangle
  svg = svg + @moonchart.rect(x=50.0, y=50.0, w=300.0, h=200.0, fill="rgb(0,122,184)", stroke="none", strokeWidth=0.0) + "\n"
  // A red circle
  svg = svg + @moonchart.circle(cx=200.0, cy=150.0, r=40.0, fill="rgb(212,57,57)", stroke="white", strokeWidth=2.0) + "\n"
  // Text label
  svg = svg + @moonchart.text(x=200.0, y=280.0, content="Moonchart v0.1", fontFamily="sans-serif", fontSize=16.0, fill="rgb(0,0,0)", textAnchor="middle") + "\n"
  svg = svg + @moonchart.svgClose()

  println(svg)
}
