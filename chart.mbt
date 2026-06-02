// Chart builder API and main rendering orchestrator.

/// Chart builder wraps a ChartOption and provides chainable methods.
pub struct Chart {
  option : ChartOption
}

/// Create a new chart. Chart type is determined per-series via Series::bar/line/scatter.
pub fn Chart::new() -> Chart {
  let xAxis = AxisOption::defaultX()
  let yAxis = AxisOption::linearY()
  let series : Array[Series] = []
  let option = ChartOption::new(xAxis, yAxis, series)
  { option, }
}

/// Deprecated: use Chart::new() instead. Chart type is per-series.
pub fn Chart::bar() -> Chart {
  Chart::new()
}

/// Deprecated: use Chart::new() instead. Chart type is per-series.
pub fn Chart::line() -> Chart {
  Chart::new()
}

/// Deprecated: use Chart::new() instead. Chart type is per-series.
pub fn Chart::scatter() -> Chart {
  Chart::new()
}

/// Set chart title.
pub fn Chart::title(self : Chart, t : String) -> Chart {
  { ..self, option: { ..self.option, title: Some(t) } }
}

/// Set chart width and height.
pub fn Chart::size(self : Chart, w : Double, h : Double) -> Chart {
  { ..self, option: { ..self.option, width: w, height: h } }
}

/// Set width only.
pub fn Chart::width(self : Chart, w : Double) -> Chart {
  { ..self, option: { ..self.option, width: w } }
}

/// Set height only.
pub fn Chart::height(self : Chart, h : Double) -> Chart {
  { ..self, option: { ..self.option, height: h } }
}

/// Set X axis label.
pub fn Chart::xLabel(self : Chart, label : String) -> Chart {
  let xAxis = self.option.xAxis.withLabel(label)
  { ..self, option: { ..self.option, xAxis } }
}

/// Set Y axis label.
pub fn Chart::yLabel(self : Chart, label : String) -> Chart {
  let yAxis = self.option.yAxis.withLabel(label)
  { ..self, option: { ..self.option, yAxis } }
}

/// Set X axis tick positions and labels.
/// `positions` — data coordinate for each tick.
/// `labels` — display label for each tick (must match positions length).
/// When positions is empty, ticks are auto-inferred from data.
pub fn Chart::xTicks(self : Chart, positions : Array[Double], labels : Array[String]) -> Chart {
  let xAxis = { ..self.option.xAxis, tickPositions: positions, tickLabels: labels }
  { ..self, option: { ..self.option, xAxis } }
}

/// Set Y axis range.
pub fn Chart::yRange(self : Chart, min : Double, max : Double) -> Chart {
  let yAxis = { ..self.option.yAxis, kind: Linear(min, max) }
  { ..self, option: { ..self.option, yAxis } }
}

/// Set tick font size for both axes.
pub fn Chart::tickFontSize(self : Chart, size : Double) -> Chart {
  let xAxis = { ..self.option.xAxis, tickFontSize: size }
  let yAxis = { ..self.option.yAxis, tickFontSize: size }
  { ..self, option: { ..self.option, xAxis, yAxis } }
}

/// Set axis label (title) font size for both axes.
pub fn Chart::labelFontSize(self : Chart, size : Double) -> Chart {
  let xAxis = { ..self.option.xAxis, labelFontSize: size }
  let yAxis = { ..self.option.yAxis, labelFontSize: size }
  { ..self, option: { ..self.option, xAxis, yAxis } }
}

/// Enable Y-axis grid lines with default color.
pub fn Chart::yGrid(self : Chart, show : Bool) -> Chart {
  let yAxis = { ..self.option.yAxis, gridLine: show }
  { ..self, option: { ..self.option, yAxis } }
}

/// Enable X-axis grid lines with default color.
pub fn Chart::xGrid(self : Chart, show : Bool) -> Chart {
  let xAxis = { ..self.option.xAxis, gridLine: show }
  { ..self, option: { ..self.option, xAxis } }
}

/// Set bar width ratio (0.0~1.0). Fraction of band width occupied by bars. Default: 0.7.
pub fn Chart::barWidthRatio(self : Chart, ratio : Double) -> Chart {
  { ..self, option: { ..self.option, barWidthRatio: ratio } }
}

/// Set bar gap ratio (0.0~1.0). Gap between bars in a group, as fraction of bar width. Default: 0.0.
pub fn Chart::barGap(self : Chart, gap : Double) -> Chart {
  { ..self, option: { ..self.option, barGap: gap } }
}

/// Set legend font size.
pub fn Chart::legendFontSize(self : Chart, size : Double) -> Chart {
  { ..self, option: { ..self.option, legendFontSize: size } }
}

/// Set legend visibility and position.
pub fn Chart::legend(self : Chart, show : Bool, position : Position) -> Chart {
  { ..self, option: { ..self.option, legend: show, legendPosition: position } }
}

/// Add a series to the chart.
pub fn Chart::series(self : Chart, s : Series) -> Chart {
  let newSeries = self.option.series.copy()
  newSeries.push(s)
  let legend = newSeries.length() > 1
  { ..self, option: { ..self.option, series: newSeries, legend } }
}

/// Add multiple series at once.
pub fn Chart::addSeries(self : Chart, ss : Array[Series]) -> Chart {
  let mut chart = self
  for i = 0; i < ss.length(); i = i + 1 {
    chart = chart.series(ss[i])
  }
  chart
}

/// Set chart margins.
pub fn Chart::margin(self : Chart, top : Double, right : Double, bottom : Double, left : Double) -> Chart {
  { ..self, option: { ..self.option, margin: { top, right, bottom, left } } }
}

/// Set chart background color.
pub fn Chart::background(self : Chart, color : Color) -> Chart {
  { ..self, option: { ..self.option, background: color } }
}

/// Set font family for all text elements.
pub fn Chart::fontFamily(self : Chart, family : String) -> Chart {
  { ..self, option: { ..self.option, fontFamily: family } }
}

/// Export the internal ChartOption (escape hatch for advanced users).
pub fn Chart::toOption(self : Chart) -> ChartOption {
  self.option
}

/// Render the chart to an SVG string.
/// Returns Result with the SVG string on success, error message on failure.
pub fn Chart::toSvg(self : Chart) -> Result[String, String] {
  render(self.option)
}

/// Render the chart and save to a file (native target only).
/// Returns Ok(()) on success, Err(message) on failure.
pub fn Chart::save(self : Chart, filename : String) -> Result[Unit, String] {
  match self.toSvg() {
    Ok(svg) => saveSvg(filename, svg)
    Err(e) => Err(e)
  }
}

/// Render a ChartOption directly to SVG (static entry point).
pub fn render(opt : ChartOption) -> Result[String, String] {
  // Compute layout
  let layout = match computeLayout(opt) {
    Ok(l) => l
    Err(msg) => return Err(msg)
  }

  let bg = opt.background.toSvg()
  let mut svg = svgOpen(width= opt.width, height= opt.height, bg= bg) + "\n"

  // Render title
  svg = svg + renderTitle(opt) + "\n"

  // Render axes
  svg = svg + renderYAxis(layout, opt) + "\n"
  svg = svg + renderXAxis(layout, opt) + "\n"

  // Render each series
  for i = 0; i < opt.series.length(); i = i + 1 {
    let s = opt.series[i]
    match s.chartType {
      Bar => {
        svg = svg + renderBars(layout, opt, i) + "\n"
      }
      Line => {
        svg = svg + renderLine(layout, opt, i) + "\n"
      }
      Scatter => {
        svg = svg + renderScatter(layout, opt, i) + "\n"
      }
      BoxPlot => {
        svg = svg + renderBoxplot(layout, opt, i) + "\n"
      }
    }
    // Render error bars on top
    svg = svg + renderErrorBars(layout, opt, i) + "\n"
  }

  // Render legend
  svg = svg + renderLegend(layout, opt) + "\n"

  svg = svg + svgClose()

  Ok(svg)
}
