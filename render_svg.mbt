// Low-level SVG string generation helpers.

/// Escape XML special characters in text content.
pub fn xmlEscape(s : String) -> String {
  s
    .replace(old= "&", new= "&amp;")
    .replace(old= "<", new= "&lt;")
    .replace(old= ">", new= "&gt;")
    .replace(old= "\"", new= "&quot;")
    .replace(old= "'", new= "&apos;")
}

/// Generate an SVG rect element.
pub fn rect(
  x~ : Double,
  y~ : Double,
  w~ : Double,
  h~ : Double,
  fill~ : String,
  stroke~ : String,
  strokeWidth~ : Double
) -> String {
  "<rect x='\{x}' y='\{y}' width='\{w}' height='\{h}' fill='\{fill}' stroke='\{stroke}' stroke-width='\{strokeWidth}' />"
}

/// Generate an SVG line element.
pub fn line(
  x1~ : Double,
  y1~ : Double,
  x2~ : Double,
  y2~ : Double,
  stroke~ : String,
  strokeWidth~ : Double
) -> String {
  "<line x1='\{x1}' y1='\{y1}' x2='\{x2}' y2='\{y2}' stroke='\{stroke}' stroke-width='\{strokeWidth}' />"
}

/// Generate an SVG circle element.
pub fn circle(
  cx~ : Double,
  cy~ : Double,
  r~ : Double,
  fill~ : String,
  stroke~ : String,
  strokeWidth~ : Double
) -> String {
  "<circle cx='\{cx}' cy='\{cy}' r='\{r}' fill='\{fill}' stroke='\{stroke}' stroke-width='\{strokeWidth}' />"
}

/// Generate an SVG text element.
pub fn text(
  x~ : Double,
  y~ : Double,
  content~ : String,
  font~ : Font,
  textAnchor~ : String
) -> String {
  let escaped = xmlEscape(content)
  "<text x='\{x}' y='\{y}' \{font.svgAttrs()} text-anchor='\{textAnchor}'>\{escaped}</text>"
}

/// Generate a rotated SVG text element (for Y axis labels).
pub fn rotatedText(
  x~ : Double,
  y~ : Double,
  content~ : String,
  font~ : Font
) -> String {
  let escaped = xmlEscape(content)
  "<text x='\{x}' y='\{y}' \{font.svgAttrs()} text-anchor='middle' transform='rotate(-90,\{x},\{y})'>\{escaped}</text>"
}

/// Generate the SVG document opening.
pub fn svgOpen(width~ : Double, height~ : Double, bg~ : String) -> String {
  "<svg xmlns='http://www.w3.org/2000/svg' width='\{width}' height='\{height}' viewBox='0 0 \{width} \{height}'>\n  <rect x='0' y='0' width='\{width}' height='\{height}' fill='\{bg}' />"
}

/// Generate the SVG document closing.
pub fn svgClose() -> String {
  "</svg>"
}

/// Generate an SVG polyline element for line charts.
pub fn polyline(
  points~ : String,
  stroke~ : String,
  strokeWidth~ : Double,
  fill~ : String
) -> String {
  "<polyline points='\{points}' stroke='\{stroke}' stroke-width='\{strokeWidth}' fill='\{fill}' stroke-linejoin='round' stroke-linecap='round' />"
}

/// Format a sequence of (x, y) points into a polyline points string.
pub fn formatPoints(pts : Array[(Double, Double)]) -> String {
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

/// Save an SVG string to a file in the current directory.
/// Uses @fs.write_string_to_file from moonbitlang/x.
/// Returns Ok(()) on success, Err(message) on failure.
pub fn saveSvg(filename : String, svg : String) -> Result[Unit, String] {
  try {
    @fs.write_string_to_file(filename, svg)
    Ok(())
  } catch {
    _ => Err("Failed to write file: \{filename}")
  }
}
