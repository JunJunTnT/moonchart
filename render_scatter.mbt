// Scatter chart rendering.

///|
/// Render a scatter series into SVG from the given layout, chart options, and series index.
pub fn renderScatter(
  layout : Layout,
  opt : ChartOption,
  seriesIndex : Int,
) -> String {
  let series = opt.series[seriesIndex]
  let color = match series.color {
    Some(c) => c
    None => seriesColor(seriesIndex)
  }
  let pointSize = series.pointSize
  let plot = layout.plot
  let mut svg = ""

  let ptFill = match series.pointFill {
    Some(c) => c.toSvg()
    None => color.toSvg()
  }

  for i = 0; i < series.data.length(); i = i + 1 {
    let dp = series.data[i]
    let cx = plot.left() + layout.xScale.map(dp.x)
    let cy = plot.bottom() - layout.yScale.map(dp.y)
    svg = svg + pointMarker(cx, cy, pointSize, series.pointShape, ptFill) + "\n"
  }

  svg
}

///|
/// Render a single point marker at (cx, cy) with the given size, shape, and fill color.
fn pointMarker(
  cx : Double,
  cy : Double,
  size : Double,
  shape : PointShape,
  fill : String,
) -> String {
  let hs = size
  match shape {
    Circle => circle(cx~, cy~, r=size, fill~, stroke="white", strokeWidth=0.5)
    Square =>
      rect(
        x=cx - hs,
        y=cy - hs,
        w=size * 2.0,
        h=size * 2.0,
        fill~,
        stroke="white",
        strokeWidth=0.5,
      )
    Triangle => {
      let p1 = "\{cx},\{cy - hs * 1.3}"
      let p2 = "\{cx - hs},\{cy + hs}"
      let p3 = "\{cx + hs},\{cy + hs}"
      "<polygon points='\{p1} \{p2} \{p3}' fill='\{fill}' stroke='white' stroke-width='0.5' />"
    }
    Diamond => {
      let top = "\{cx},\{cy - hs}"
      let right = "\{cx + hs},\{cy}"
      let bottom = "\{cx},\{cy + hs}"
      let left = "\{cx - hs},\{cy}"
      "<polygon points='\{top} \{right} \{bottom} \{left}' fill='\{fill}' stroke='white' stroke-width='0.5' />"
    }
    Cross => {
      let arm = hs * 0.7
      line(
        x1=cx - arm,
        y1=cy - arm,
        x2=cx + arm,
        y2=cy + arm,
        stroke=fill,
        strokeWidth=1.5,
      ) +
      line(
        x1=cx - arm,
        y1=cy + arm,
        x2=cx + arm,
        y2=cy - arm,
        stroke=fill,
        strokeWidth=1.5,
      )
    }
  }
}
