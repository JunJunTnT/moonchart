/// Demonstrate layout engine: compute plot area and show dimensions.
fn main {
  let data = [
    @moonchart.DataPoint::new(0.0, 30.0),
    @moonchart.DataPoint::new(1.0, 70.0),
  ]
  let series = @moonchart.Series::bar("Demo", data)

  let opt = @moonchart.ChartOption::new(
    @moonchart.AxisOption::categories(["A", "B"]),
    @moonchart.AxisOption::linearY(),
    [series],
  )

  match @moonchart.computeLayout(opt) {
    Ok(layout) => {
      let mut svg = @moonchart.svgOpen(width=opt.width, height=opt.height, bg="white") + "\n"

      // Draw plot area boundary
      svg = svg + @moonchart.rect(
        x=layout.plot.left(), y=layout.plot.top(),
        w=layout.plot.w, h=layout.plot.h,
        fill="rgb(245,245,250)", stroke="rgb(0,122,184)", strokeWidth=2.0,
      ) + "\n"

      // Annotate dimensions
      svg = svg + @moonchart.text(x=opt.width / 2.0, y=25.0,
        content="Layout Engine v0.4 — Plot Area & Margins",
        fontFamily="sans-serif", fontSize=14.0, fill="rgb(0,0,0)", textAnchor="middle") + "\n"

      svg = svg + @moonchart.text(x=layout.plot.left() + layout.plot.w / 2.0, y=layout.plot.top() - 8.0,
        content="plot = \{layout.plot.w.to_string()}×\{layout.plot.h.to_string()}",
        fontFamily="sans-serif", fontSize=11.0, fill="rgb(0,122,184)", textAnchor="middle") + "\n"

      // Show margins
      svg = svg + @moonchart.text(x=layout.canvas.centerX(), y=layout.canvas.bottom() - 5.0,
        content="canvas = \{layout.canvas.w.to_string()}×\{layout.canvas.h.to_string()}",
        fontFamily="sans-serif", fontSize=10.0, fill="rgb(150,150,150)", textAnchor="middle") + "\n"

      // Left margin indicator
      svg = svg + @moonchart.line(x1=0.0, y1=layout.plot.top(), x2=layout.plot.left(), y2=layout.plot.top(), stroke="rgb(212,57,57)", strokeWidth=1.0) + "\n"
      svg = svg + @moonchart.text(x=layout.plot.left() / 2.0, y=layout.plot.top() - 10.0,
        content="margin", fontFamily="sans-serif", fontSize=9.0, fill="rgb(212,57,57)", textAnchor="middle") + "\n"

      // Auto-infer label example
      svg = svg + @moonchart.text(x=layout.plot.centerX(), y=layout.plot.centerY(),
        content="Plot Area",
        fontFamily="sans-serif", fontSize=24.0, fill="rgb(200,200,200)", textAnchor="middle") + "\n"

      // Category positions
      for i = 0; i < layout.xScale.count(); i = i + 1 {
        let cx = layout.plot.left() + layout.xScale.map(i.to_double())
        svg = svg + @moonchart.circle(cx=cx, cy=layout.plot.bottom(), r=4.0, fill="rgb(0,122,184)", stroke="none", strokeWidth=0.0) + "\n"
      }

      svg = svg + @moonchart.svgClose()
      println(svg)
    }
    Err(msg) => println("Layout error: \{msg}")
  }
}
