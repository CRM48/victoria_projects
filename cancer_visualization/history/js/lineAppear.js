const chartSvg = d3.select("#lineChart");
const chartWidth = +chartSvg.attr("width") - 100;
const chartHeight = +chartSvg.attr("height") - 60;
const chartMargin = { top: 5, right: 0, bottom: 40, left: 22 };

const chartGroup = chartSvg
  .append("g")
  .attr("transform", `translate(${chartMargin.left}, ${chartMargin.top})`);

const lineDuration = 35000; // line appearance
let tooltipTimeout;

window.onload = lineProduce(lineDuration); // open page and load this function

function lineProduce(lineDuration) {
  d3.csv("data/cancerRate.csv").then((data) => {
    data.forEach((d) => {
      d.year = +d.year;
      d.rate = +d.rate;
    });

    const cancerTypes = Array.from(new Set(data.map((d) => d.cancer)));
    const yearValues = Array.from(new Set(data.map((d) => d.year))).sort(
      (a, b) => a - b
    );

    const lineDataArray = cancerTypes.map((cancer, index) => ({
      cancer: cancer,
      values: data
        .filter((d) => d.cancer === cancer)
        .sort((a, b) => a.year - b.year)
        .map((d) => ({ year: d.year, rate: d.rate })),
    }));

    const xScale = d3
      .scaleLinear()
      .domain(d3.extent(yearValues))
      .range([0, chartWidth]);

    const yScale = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d) => d.rate) * 1.1])
      .range([chartHeight, 0]);

    const xAxis = d3
      .axisBottom(xScale)
      .ticks(yearValues.length / 5)
      .tickFormat(d3.format("d"));
    const yAxis = d3.axisLeft(yScale);

    chartGroup
      .append("g")
      .attr("class", "x-axis")
      .attr("transform", `translate(0, ${chartHeight})`)
      .call(xAxis);

    chartGroup.append("g").attr("class", "y-axis").call(yAxis);

    const linePathGenerator = d3
      .line()
      .x((d) => xScale(d.year))
      .y((d) => yScale(d.rate))
      .curve(d3.curveMonotoneX);

    const lineGroups = chartGroup
      .selectAll(".line-group")
      .data(lineDataArray)
      .enter()
      .append("g")
      .attr("class", "line-group");

    lineGroups // background line
      .append("path")
      .attr("class", "line-animated")
      .attr("fill", "none")
      .attr("stroke", (d) => colorMap[d.cancer] || "#ccc")
      .attr("stroke-width", 2)
      .attr("opacity", 0.7)
      .style("cursor", "pointer")
      .attr("d", (d) => linePathGenerator(d.values))
      .on("click", function (event, d) {
        const cancerName = d.cancer;

        loadGenderData(cancerName);

        changeAll(cancerName);
      })
      .each(function () {
        const pathLength = this.getTotalLength();
        d3.select(this)
          .attr("stroke-dasharray", `${pathLength} ${pathLength}`)
          .attr("stroke-dashoffset", pathLength)
          .transition()
          .duration(lineDuration)
          .ease(d3.easeLinear)
          .attr("stroke-dashoffset", 0);
      });

    lineGroups // line for interactive effect, overlap with last to avoid line stop generation if moving-over happens during generating
      .append("path")
      .attr("class", "line-interactive")
      .attr("fill", "none")
      .attr("stroke", "#ccc")
      .attr("stroke-width", 3)
      .attr("opacity", 0) // hidden
      .attr("d", (d) => linePathGenerator(d.values))
      .style("cursor", "pointer")
      .on("mouseover", function (event, d) {
        d3.select(this.parentNode)
          .select(".line-animated")
          .raise()
          .attr("stroke-width", 5)
          .attr("opacity", 1);

        tooltip.transition().style("opacity", 0.8);
        tooltip
          .html(`<strong>${d.cancer}</strong>`)
          .style("left", event.pageX + 10 + "px")
          .style("top", event.pageY - 28 + "px");

        clearTimeout(tooltipTimeout);
      })
      .on("mouseout", function (event, d) {
        d3.select(this.parentNode)
          .select(".line-animated")
          .attr("stroke-width", 2)
          .attr("opacity", 0.7);

        tooltipTimeout = setTimeout(() => {
          tooltip.transition().duration(200).style("opacity", 0);
        }, 2500); // Hide time
      })
      .on("click", function (event, d) {
        const cancerName = d.cancer;

        loadGenderData(cancerName);

        changeAll(cancerName);
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

    function loadGenderData(cancerName) {
      // generate gender rate lines
      d3.select("#backButton").style("display", "block");

      chartGroup.selectAll("*").remove();

      d3.csv("data/genderRate.csv").then((genderData) => {
        const filtered = genderData.filter((d) => d.cancer === cancerName);
        drawGenderChart(filtered, cancerName);
      });
    }

    d3.select("#backButton").on("click", function () {
      // the actions for backbutton
      d3.select("#backButton").style("display", "none");

      chartGroup.selectAll("*").remove();
      chartSvg.select("text").remove();

      lineDuration = 2000;
      lineProduce(lineDuration);

      document.getElementById("rateCancerName").style.visibility = "hidden";

      resetNumbers();

      resetWiki();

      resetWikiSection();
    });
  });
}
