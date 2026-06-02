// Chart builder API and main rendering orchestrator.

/// Chart builder wraps a ChartOption and provides chainable methods.
pub struct Chart {
  option : ChartOption
}

/// Create a new chart.
pub fn Chart::new() -> Chart {
  let xAxis = AxisOption::categories([])
  let yAxis = AxisOption::linearY()
  let series : Array[Series] = []
  let option = ChartOption::new(xAxis, yAxis, series)
  { option, }
}

/// Set chart title.
pub fn Chart::title(self : Chart, t : String) -> Chart {
  { ..self, option: { ..self.option, title: Some(t) } }
}

/// Set chart width and height.
pub fn Chart::size(self : Chart, w : Double, h : Double) -> Chart {
  { ..self, option: { ..self.option, width: w, height: h } }
}

/// Set X axis categories.
pub fn Chart::xCategories(self : Chart, labels : Array[String]) -> Chart {
  let xAxis = AxisOption::categories(labels)
  { ..self, option: { ..self.option, xAxis } }
}

/// Set Y axis range.
pub fn Chart::yRange(self : Chart, min : Double, max : Double) -> Chart {
  let yAxis = { ..self.option.yAxis, kind: Linear(min, max) }
  { ..self, option: { ..self.option, yAxis } }
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

/// Add a series to the chart.
pub fn Chart::series(self : Chart, s : Series) -> Chart {
  let newSeries = self.option.series.copy()
  newSeries.push(s)
  let legend = newSeries.length() > 1
  { ..self, option: { ..self.option, series: newSeries, legend } }
}

/// Render the chart to an SVG string.
pub fn Chart::toSvg(self : Chart) -> Result[String, String] {
  render(self.option)
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

  svg = svg + svgClose()

  Ok(svg)
}
