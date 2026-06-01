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
  fontFamily~ : String,
  fontSize~ : Double,
  fill~ : String,
  textAnchor~ : String
) -> String {
  let escaped = xmlEscape(content)
  "<text x='\{x}' y='\{y}' font-family='\{fontFamily}' font-size='\{fontSize}' fill='\{fill}' text-anchor='\{textAnchor}'>\{escaped}</text>"
}

/// Generate the SVG document opening.
pub fn svgOpen(width~ : Double, height~ : Double, bg~ : String) -> String {
  "<svg xmlns='http://www.w3.org/2000/svg' width='\{width}' height='\{height}' viewBox='0 0 \{width} \{height}'>\n  <rect x='0' y='0' width='\{width}' height='\{height}' fill='\{bg}' />"
}

/// Generate the SVG document closing.
pub fn svgClose() -> String {
  "</svg>"
}
