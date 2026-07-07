// Blackbox tests for moonchart public API.

///|
/// Test DataPoint construction
test "DataPoint::new creates simple point" {
  let dp = DataPoint::new(1.0, 45.0)
  assert_eq(dp.x, 1.0)
  assert_eq(dp.y, 45.0)
  // Verify error fields start as None
  match dp.error_y {
    None => ()
    Some(_) => abort("expected None error_y")
  }
}

///|
test "DataPoint::withErrY creates point with error" {
  let dp = DataPoint::withErrY(0.0, 50.0, 3.0)
  assert_eq(dp.y, 50.0)
  match dp.error_y {
    Some(_) => ()
    None => abort("expected Some error_y")
  }
}

///|
/// Test ErrorValue methods
test "ErrorValue::Symmetric lo and hi" {
  let e = ErrorValue::Symmetric(5.0)
  assert_eq(e.lo(), -5.0)
  assert_eq(e.hi(), 5.0)
}

///|
test "ErrorValue::Asymmetric lo and hi" {
  let e = ErrorValue::Asymmetric(8.0, 12.0)
  assert_eq(e.lo(), 8.0)
  assert_eq(e.hi(), 12.0)
}

///|
/// Test Color
test "Color::rgb creates opaque color" {
  let c = Color::rgb(255, 128, 0)
  assert_eq(c.r, 255)
  assert_eq(c.g, 128)
  assert_eq(c.b, 0)
  assert_eq(c.a, 255)
}

///|
test "Color::toSvg produces rgb string" {
  let c = Color::rgb(10, 20, 30)
  assert_eq(c.toSvg(), "rgb(10,20,30)")
}

///|
test "Color::toHex produces hex string" {
  let c = Color::rgb(0xFF, 0xAB, 0x00)
  assert_eq(c.toHex(), "#FFAB00")
}

///|
/// Test ChartOption defaults
test "ChartOption::new fills defaults" {
  let xAxis = AxisOption::defaultX()
  let yAxis = AxisOption::linearY()
  let opt = ChartOption::new(xAxis, yAxis, [])
  assert_eq(opt.width, 600.0)
  assert_eq(opt.height, 400.0)
  assert_eq(opt.legend, false)
}

///|
/// Test Series construction
test "Series::bar creates bar series" {
  let data = [DataPoint::new(0.0, 10.0), DataPoint::new(1.0, 20.0)]
  let s = Series::bar("Test", data)
  assert_eq(s.name, "Test")
  assert_eq(s.lineWidth, 2.0)
  assert_eq(s.pointSize, 4.0)
}

///|
test "Series::withColor overrides color" {
  let data = [DataPoint::new(0.0, 5.0)]
  let s = Series::bar("Colored", data).withColor(Color::rgb(255, 0, 0))
  match s.color {
    Some(c) => assert_eq(c.r, 255)
    None => abort("expected Some color")
  }
}

///|
/// Test BoxGroup
test "BoxGroup::new creates group with x coordinate" {
  let bg = BoxGroup::new(1.5, "Test", [1.0, 2.0, 3.0])
  assert_eq(bg.x, 1.5)
  assert_eq(bg.label, "Test")
  assert_eq(bg.values.length(), 3)
}

///|
/// Test Font defaults
test "Font::default creates 12px sans-serif" {
  let f = Font::default()
  assert_eq(f.family, "sans-serif")
  assert_eq(f.size, 12.0)
  assert_eq(f.bold, false)
}

///|
/// Test LinearScale
test "LinearScale::map at midpoint" {
  let scale = LinearScale::new(0.0, 100.0, 500.0)
  assert_eq(scale.map(50.0), 250.0)
}

///|
test "LinearScale::map at min and max" {
  let scale = LinearScale::new(0.0, 100.0, 500.0)
  assert_eq(scale.map(0.0), 0.0)
  assert_eq(scale.map(100.0), 500.0)
}

///|
test "LinearScale::ticks produces labels" {
  let scale = LinearScale::new(0.0, 100.0, 500.0)
  let ticks = scale.ticks(5)
  assert_eq(ticks.length() > 0, true)
}

///|
/// Test CategoryScale with explicit positions
test "CategoryScale::map with positions" {
  let scale = CategoryScale::new(
    [0.0, 1.0, 2.0, 3.0],
    ["A", "B", "C", "D"],
    400.0,
  )
  // map uses linear interpolation between dataMin and dataMax
  let pos = scale.map(1.0)
  assert_eq(pos > 0.0, true)
}

///|
test "CategoryScale::bandCenter finds band" {
  let scale = CategoryScale::new(
    [0.0, 1.0, 2.0, 3.0],
    ["A", "B", "C", "D"],
    400.0,
  )
  // bandWidth = 400/4 = 100, bandCenter(0) = 50
  let bc = scale.bandCenter(0.0)
  assert_eq(bc > 0.0, true)
  assert_eq(bc < 200.0, true) // should be near 50
}

///|
test "CategoryScale::ticks returns labels" {
  let scale = CategoryScale::new([0.0, 1.0], ["X", "Y"], 200.0)
  let ticks = scale.ticks(2)
  assert_eq(ticks.length(), 2)
  let (_, label1) = ticks[1]
  assert_eq(label1, "Y")
}

///|
/// Test SVG helpers
test "xmlEscape escapes special chars" {
  assert_eq(xmlEscape("<>&"), "&lt;&gt;&amp;")
  assert_eq(xmlEscape("hello"), "hello")
}

///|
test "svgOpen produces valid svg root" {
  let svg = svgOpen(width=100.0, height=50.0, bg="white")
  assert_eq(svg.contains("xmlns='http://www.w3.org/2000/svg'"), true)
  assert_eq(svg.contains("width='100'"), true)
}

///|
test "rect produces valid rect element" {
  let r = rect(
    x=10.0,
    y=20.0,
    w=100.0,
    h=50.0,
    fill="red",
    stroke="none",
    strokeWidth=0.0,
  )
  assert_eq(r.contains("<rect"), true)
  assert_eq(r.contains("fill='red'"), true)
}

///|
/// Test layout computation
test "computeLayout with valid option returns Ok" {
  let opt = ChartOption::new(AxisOption::defaultX(), AxisOption::linearY(), [
    Series::bar("S1", [DataPoint::new(0.0, 10.0)]),
  ])
  match computeLayout(opt) {
    Ok(layout) => {
      assert_eq(layout.plot.w > 0.0, true)
      assert_eq(layout.plot.h > 0.0, true)
    }
    Err(_) => abort("expected Ok layout")
  }
}

///|
/// Test render produces valid SVG
test "Chart::render produces complete SVG with xTicks" {
  let opt = ChartOption::new(AxisOption::defaultX(), AxisOption::linearY(), [
    Series::bar("S1", [DataPoint::new(0.0, 30.0), DataPoint::new(1.0, 70.0)]),
  ])
  match render(opt) {
    Ok(svg) => {
      assert_eq(svg.contains("<svg"), true)
      assert_eq(svg.contains("</svg>"), true)
    }
    Err(msg) => abort("render failed: \{msg}")
  }
}

///|
/// Test bar chart with error bars
test "render includes error bars when specified" {
  let data = [
    DataPoint::withErrY(0.0, 50.0, 5.0),
    DataPoint::withErrY(1.0, 70.0, 3.0),
  ]
  let opt = ChartOption::new(AxisOption::defaultX(), AxisOption::linearY(), [
    Series::bar("S1", data),
  ])
  match render(opt) {
    Ok(svg) => assert_eq(svg.contains("<line"), true)
    Err(msg) => abort("render with errors failed: \{msg}")
  }
}

///|
/// Test Chart builder API with xTicks
test "Chart::bar builder produces complete SVG" {
  let data = [DataPoint::new(0.0, 30.0), DataPoint::new(1.0, 70.0)]
  let result = Chart::bar()
    .title("Test")
    .xTicks([0.0, 1.0], ["A", "B"])
    .xLabel("Categories")
    .yLabel("Value")
    .yRange(0.0, 100.0)
    .series(Series::bar("Test", data))
    .toSvg()
  match result {
    Ok(svg) => {
      assert_eq(svg.contains("Test"), true)
      assert_eq(svg.contains("<svg"), true)
    }
    Err(msg) => abort("Chart builder failed: \{msg}")
  }
}

///|
/// Test xLabel is preserved with xTicks
test "Chart::xLabel works with xTicks for bar charts" {
  let data = [DataPoint::new(0.0, 30.0), DataPoint::new(1.0, 70.0)]
  let result = Chart::new()
    .xLabel("My X Axis")
    .xTicks([0.0, 1.0], ["A", "B"])
    .yLabel("Value")
    .series(Series::bar("Test", data))
    .toSvg()
  match result {
    Ok(svg) =>
      // xLabel should be in the SVG
      assert_eq(svg.contains("My X Axis"), true)
    Err(msg) => abort("xLabel test failed: \{msg}")
  }
}

///|
/// Test BoxGroup with x coordinate
test "BoxGroup::new creates valid box group" {
  let bg = BoxGroup::new(2.0, "TestGroup", [1.0, 2.0, 3.0, 4.0, 5.0])
  assert_eq(bg.x, 2.0)
  assert_eq(bg.label, "TestGroup")
}
