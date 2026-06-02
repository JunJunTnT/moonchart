// Line chart rendering with point shape and line style support.

/// Render a line series into SVG.
pub fn renderLine(layout : Layout, opt : ChartOption, seriesIndex : Int) -> String {
  let series = opt.series[seriesIndex]
  let color = match series.color {
    Some(c) => c
    None => seriesColor(seriesIndex)
  }
  let stroke = color.toSvg()
  let lineWidth = series.lineWidth
  let pointSize = series.pointSize
  let plot = layout.plot
  let mut svg = ""

  // Sort data points by x for clean line
  let sorted = series.data.copy()
  for i = 0; i < sorted.length(); i = i + 1 {
    for j = i + 1; j < sorted.length(); j = j + 1 {
      if sorted[i].x > sorted[j].x {
        let tmp = sorted[i]
        sorted[i] = sorted[j]
        sorted[j] = tmp
      }
    }
  }

  // Build points string for polyline
  let pts : Array[(Double, Double)] = []
  for i = 0; i < sorted.length(); i = i + 1 {
    let dp = sorted[i]
    let px = plot.left() + layout.xScale.map(dp.x)
    let py = plot.bottom() - layout.yScale.map(dp.y)
    pts.push((px, py))
  }

  if pts.length() >= 2 {
    let ptsStr = formatPoints(pts)
    let dash = lineDashAttr(series.lineStyle)
    svg = svg + "<polyline points='\{ptsStr}' stroke='\{stroke}' stroke-width='\{lineWidth}' fill='none' stroke-linejoin='round' stroke-linecap='round'\{dash} />" + "\n"
  }

  // Draw data point markers
  if pointSize > 0.0 {
    let ptFill = match series.pointFill {
      Some(c) => c.toSvg()
      None => color.toSvg()
    }
    for i = 0; i < sorted.length(); i = i + 1 {
      let dp = sorted[i]
      let cx = plot.left() + layout.xScale.map(dp.x)
      let cy = plot.bottom() - layout.yScale.map(dp.y)
      svg = svg + pointMarker(cx, cy, pointSize, series.pointShape, ptFill) + "\n"
    }
  }

  svg
}

/// Get stroke-dasharray attribute for a line style.
fn lineDashAttr(style : LineStyle) -> String {
  match style {
    Solid => ""
    Dashed => " stroke-dasharray='8,4'"
    Dotted => " stroke-dasharray='2,3'"
    DashDot => " stroke-dasharray='8,4,1,4'"
  }
}

/// Render a single point marker in the given shape.
fn pointMarker(cx : Double, cy : Double, size : Double, shape : PointShape, fill : String) -> String {
  let hs = size
  match shape {
    Circle => circle(cx= cx, cy= cy, r= size, fill= fill, stroke= "white", strokeWidth= 0.5)
    Square => rect(x= cx - hs, y= cy - hs, w= size * 2.0, h= size * 2.0, fill= fill, stroke= "white", strokeWidth= 0.5)
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
      line(x1= cx - arm, y1= cy - arm, x2= cx + arm, y2= cy + arm, stroke= fill, strokeWidth= 1.5) +
      line(x1= cx - arm, y1= cy + arm, x2= cx + arm, y2= cy - arm, stroke= fill, strokeWidth= 1.5)
    }
  }
}

/// Format a sequence of (x, y) points into a polyline points string.
fn formatPoints(pts : Array[(Double, Double)]) -> String {
  let parts : Array[String] = []
  for i = 0; i < pts.length(); i = i + 1 {
    let (px, py) = pts[i]
    parts.push("\{px},\{py}")
  }
  let mut result = ""
  for i = 0; i < parts.length(); i = i + 1 {
    if i == 0 {
      result = parts[i]
    } else {
      result = result + " " + parts[i]
    }
  }
  result
}
