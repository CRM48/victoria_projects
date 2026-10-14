function drawGenderChart(data, cancerName) {
  d3.selectAll(".tooltip").remove();

  // change the corresponding words on the page
  // // cancer name on the line
  document.getElementById("rateCancerName").textContent =
    cancerName + " Cancer";
  document.getElementById("rateCancerName").style.visibility = "visible";

  // main part of draw gender lines
  const genders = Array.from(new Set(data.map((d) => d.gender)));
  const years = Array.from(new Set(data.map((d) => +d.year))).sort();

  const x = d3.scalePoint().domain(years).range([0, chartWidth]).padding(0.5);
  const y = d3
    .scaleLinear()
    .domain([0, d3.max(data, (d) => +d.rate) * 1.1])
    .range([chartHeight, 0]);

  const xScale = d3
    .scaleLinear()
    .domain(d3.extent(years))
    .range([0, chartWidth]);

  const yScale = d3
    .scaleLinear()
    .domain([0, d3.max(data, (d) => d.rate) * 1.1])
    .range([chartHeight, 0]);

  const xAxis = d3
    .axisBottom(xScale)
    .ticks(years.length / 5)
    .tickFormat(d3.format("d"));
  const yAxis = d3.axisLeft(yScale);

  chartGroup
    .append("g")
    .attr("class", "x-axis")
    .attr("transform", `translate(0, ${chartHeight})`)
    .call(xAxis);
  chartGroup.append("g").call(d3.axisLeft(y));

  const genderColors = { Male: "#3FA9F5", Female: "#FF7BAC", ALL: "#8d99ae" };

  genders.forEach((gender) => {
    const genderValues = data
      .filter((d) => d.gender === gender)
      .map((d) => ({ year: +d.year, rate: +d.rate }));

    const genderLine = d3
      .line()
      .x((d) => x(d.year))
      .y((d) => y(d.rate))
      .curve(d3.curveMonotoneX);

    chartGroup
      .append("path")
      .datum(genderValues)
      .attr("fill", "none")
      .attr("stroke", genderColors[gender])
      .attr("stroke-width", 2)
      .attr("d", genderLine)
      .style("cursor", "pointer")
      .on("mouseover", function (event, d) {
        d3.select(this)
          .raise() // bring to front
          .transition()
          .duration(10)
          .attr("stroke-width", 4)
          .attr("opacity", 1);

        tooltip.transition().style("opacity", 0.8); //tips appear
        tooltip
          .html(`<strong>${gender}</strong>`)
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 28 + "px");

        clearTimeout(tooltipTimeout);
      })

      .on("mouseout", function (event, d) {
        d3.select(this)
          .transition()
          .duration(10)
          .attr("stroke-width", 2)
          .attr("opacity", 0.7);

        tooltipTimeout = setTimeout(() => {
          tooltip.transition().duration(200).style("opacity", 0);
        }, 2000); // Hide time
      });
  });

  const tooltip = d3 // give tip to every line
    .select("body")
    .append("div")
    .attr("class", "tooltip")
    .style("position", "absolute")
    .style("padding", "6px")
    .style("background", "rgba(0, 0, 0, 0.7)")
    .style("color", "#fff")
    .style("border-radius", "5px")
    .style("pointer-events", "none")
    .style("opacity", 0);
}
