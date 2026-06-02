/// Demonstrate box plot with file output — complete moonchart v0.10.
fn main {
  let mRNA_ctrl = @moonchart.BoxGroup::new("Control", [
    1.2, 2.1, 3.4, 2.8, 1.9, 2.5, 3.0, 2.3, 1.8, 2.7,
    3.2, 2.0, 2.9, 1.5, 3.8, 2.6, 3.1, 1.7, 4.2, 2.4, 6.5,
  ])
  let mRNA_treat = @moonchart.BoxGroup::new("Treatment", [
    0.8, 1.5, 2.9, 2.1, 1.3, 1.9, 2.4, 1.7, 3.5, 2.0,
    2.8, 1.6, 2.2, 1.1, 3.0, 1.8, 2.5, 0.9, 3.3, 1.4,
  ])
  let protein_ctrl = @moonchart.BoxGroup::new("Control", [
    0.5, 0.8, 1.2, 0.9, 0.6, 1.0, 1.1, 0.7, 0.4, 0.9,
    1.3, 0.8, 1.0, 0.5, 1.5, 0.9, 1.2, 0.6, 1.5, 0.8, 3.8,
  ])
  let protein_treat = @moonchart.BoxGroup::new("Treatment", [
    0.3, 0.6, 1.0, 0.7, 0.4, 0.8, 0.9, 0.5, 1.2, 0.7,
    0.9, 0.5, 0.8, 0.3, 1.1, 0.6, 0.9, 0.4, 1.3, 0.5,
  ])

  let result = @moonchart.Chart::new()
    .title("Box Plot & File Output — v0.10")
    .xCategories(["Control", "Treatment"])
    .yLabel("Expression Level")
    .yRange(0.0, 5.0)
    .yGrid(true)
    .barWidthRatio(0.4)
    .barGap(0.5)
    .legend(true, @moonchart.TopRight)
    .legendFontSize(12.0)
    .series(
      @moonchart.Series::boxplot("mRNA", [mRNA_ctrl, mRNA_treat])
        .withColor(@moonchart.Color::rgb(0, 122, 184))
        .withShowOutliers(true)
    )
    .series(
      @moonchart.Series::boxplot("Protein", [protein_ctrl, protein_treat])
        .withColor(@moonchart.Color::rgb(212, 57, 57))
        .withShowOutliers(false)
    )
    .save("boxplot.svg")

  match result {
    Ok(_) => println("Saved to boxplot.svg")
    Err(msg) => println("Error: \{msg}")
  }
}
