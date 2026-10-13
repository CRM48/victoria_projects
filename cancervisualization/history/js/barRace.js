// Original barchasing codes learned and used from SimpleCodingTutorials @Github: https://github.com/SimpleCodingTutorials/Tutorials/tree/main/bar%20chart%20race

const width = 700;
const height = 500;
const margin = { top: 22, right: 0, bottom: 0, left: 0 };
let updateInterval = 500;

const svg = d3
  .select("#barChasing")
  .append("svg")
  .attr("width", width)
  .attr("height", height);

svg
  .append("rect")
  .attr("width", width)
  .attr("height", height)
  .attr("fill", "white");

const x = d3.scaleLinear().range([margin.left, width - margin.right - 50]);
const y = d3
  .scaleBand()
  .range([margin.top, height - margin.bottom])
  .padding(0.1);

const verticalGridLines = svg.append("g").attr("class", "grid-lines");
const gridLineLabels = svg.append("g").attr("class", "grid-label");

const parseDate = d3.timeParse("%Y-%m-%d");

// loading CSV
d3.csv("data/cancerNumber.csv").then((rawData) => {
  let processedData = rawData;
  if (rawData.columns.length == 3) processedData = processCSV(rawData);
  else
    processedData = processedData.map((entry) => {
      const [oldKey, ...otherKeys] = Object.keys(entry);
      const { [oldKey]: oldValue, ...rest } = entry;
      return { Date: oldValue, ...rest };
    });

  const categories = Object.keys(processedData[0]).filter(
    (key) => key !== "Date"
  );

  let flatData = processedData.flatMap((d) =>
    categories.map((cat) => ({
      date: parseDate(d.Date) || d.Date,
      name: cat,
      value: +d[cat] || 0,
    }))
  );
  flatData = flatData.sort((a, b) => a.date - b.date);
  let groupedData = d3.groups(flatData, (d) => d.date);

  x.domain([0, d3.max(flatData, (d) => d.value)]);
  y.domain(categories);

  if (groupedData.length > 1 && isValidFullDate(groupedData[0][0])) {
    const firstDate = new Date(groupedData[0][0]);
    const secondDate = new Date(groupedData[1][0]);
    const diff = Math.abs(secondDate - firstDate);

    const oneDay = 24 * 60 * 60 * 1000;
    const oneMonth = 30 * oneDay;

    if (diff < oneDay) {
      formatDate = d3.timeFormat("%H:%M:%S");
    } else if (diff < oneMonth) {
      formatDate = d3.timeFormat("%d %b %Y");
    } else {
      formatDate = d3.timeFormat("%b %Y");
    }
  } else {
    formatDate = (d) => d;
  }

  const dateText = svg // Dynamic Year style
    .append("text")
    .attr("x", width - margin.right - 12)
    .attr("y", height - margin.bottom - 15)
    .attr("text-anchor", "end")
    .attr("font-size", "42px")
    .attr("font-weight", "bold")
    .style("fill", "#5e5f61");

  function update(data) {
    data = data.sort((a, b) => b.value - a.value).slice(0, 16);
    y.domain(data.map((d) => d.name));

    const transition = d3
      .transition()
      .duration(updateInterval)
      .ease(d3.easeLinear);

    svg // bar animation and event
      .selectAll(".bar")
      .data(data, (d) => d.name)
      .join(
        (enter) =>
          enter
            .append("rect")
            .attr("class", "bar")
            .attr("x", margin.left)
            .attr("y", (d) => y(d.name))
            .attr("height", y.bandwidth())
            .attr("width", 0)
            .style("fill", (d) => colorMap[d.name] || "#ccc") // color defines in global JS
            .style("opacity", 0.8)
            .call((enter) =>
              enter
                .transition(transition)
                .attr("width", (d) => x(d.value) - margin.left)
            ),
        (update) =>
          update.call((update) =>
            update
              .transition(transition)
              .attr("y", (d) => y(d.name))
              .attr("height", y.bandwidth())
              .attr("width", (d) => x(d.value) - margin.left)
          ),
        (exit) =>
          exit.call((exit) =>
            exit
              .transition(transition)
              .attr("width", 0)
              .attr("y", height)
              .remove()
          )
      )

      .style("cursor", "pointer")

      .on("mouseover", function (event, d) {
        d3.select(this) // add hover effect
          .style("filter", "drop-shadow(4px 4px 6px rgba(19, 18, 18, 0.9))")
          .attr("opacity", 1);
      })

      .on("mouseout", function (event, d) {
        d3.select(this)
          .style("filter", null) // Remove hover effect
          .attr("opacity", 0.8);
      })

      .on("click", function (event, d) {
        const cancerName = d.name;

        d3.select("#backButton").style("display", "block");

        changeAll(cancerName);
      });

    svg // cancer name animation and style
      .selectAll(".label")
      .data(data, (d) => d.name)
      .join(
        (enter) =>
          enter
            .append("text")
            .attr("class", "label")
            .attr("y", (d) => y(d.name) + y.bandwidth() / 2)
            .attr("x", 5)
            .attr("dy", "0.35em")
            .text((d) => d.name)
            .style("font-size", "12px")
            .style("font-weight", "bold")
            .style("fill", "#fff"),

        (update) =>
          update.call((update) =>
            update
              .transition(transition)
              .attr("y", (d) => y(d.name) + y.bandwidth() / 2)
          ),
        (exit) =>
          exit.call((exit) =>
            exit
              .transition(transition)
              .attr("y", height + 10)
              .remove()
          )
      )
      .style("cursor", "pointer")

      .on("mouseover", function (event, d) {
        d3.select(this).attr("opacity", 0.8);
      })

      .on("click", function (event, d) {
        const cancerName = d.name;

        d3.select("#backButton").style("display", "block");

        changeAll(cancerName);
      })

      .on("mouseout", function (event, d) {
        d3.select(this).attr("opacity", 1);
      });

    svg // the dynamic number in each year
      .selectAll(".value")
      .data(data, (d) => d.name)
      .join(
        (enter) =>
          enter
            .append("text")
            .attr("class", "value")
            .attr("y", (d) => y(d.name) + y.bandwidth() / 2)
            .attr("x", (d) => x(d.value) + 5)
            .attr("dy", "0.35em")
            .attr("text-anchor", "start")
            .text((d) => d.value.toFixed(0))
            .style("font-size", "14px")
            .style("fill", "#5e5f61"),
        (update) =>
          update
            .transition(transition)
            .attr("y", (d) => y(d.name) + y.bandwidth() / 2)
            .attr("x", (d) => x(d.value) + 5)
            .text((d) => d.value.toFixed(0))
      );
  }

  let index = 0;
  d3.interval(() => {
    // background setting
    if (index < groupedData.length) {
      const currentData = groupedData[index];
      const maxValue = d3.max(currentData[1], (d) => d.value) + 1;
      x.domain([0, maxValue]);

      verticalGridLines
        .selectAll("line")
        .data(x.ticks(5))
        .join(
          (enter) =>
            enter
              .append("line")
              .attr("x1", (d) => x(d))
              .attr("x2", (d) => x(d))
              .attr("y1", margin.top)
              .attr("y2", height - margin.bottom)
              .style("stroke", "lightgray")
              .style("stroke-width", 1),
          (update) =>
            update.call((update) =>
              update
                .transition()
                .duration(updateInterval)
                .ease(d3.easeLinear)
                .attr("x1", (d) => x(d))
                .attr("x2", (d) => x(d))
            ),
          (exit) => exit.remove()
        );

      verticalGridLines
        .selectAll(".grid-label")
        .data(x.ticks(5))
        .join(
          (enter) =>
            enter
              .append("text")
              .attr("class", "grid-label")
              .attr("x", (d) => x(d))
              .attr("y", margin.top - 10)
              .attr("text-anchor", "middle")
              .style("font-size", "12px")
              .style("fill", "gray")
              .text((d) => d),
          (update) =>
            update.call((update) =>
              update
                .transition()
                .duration(updateInterval)
                .ease(d3.easeLinear)
                .attr("x", (d) => x(d))
                .text((d) => d)
            ),
          (exit) => exit.remove()
        );

      update(currentData[1]);
      dateText.text(formatDate(currentData[0]));
      index++;
    }
  }, updateInterval);
});

function processCSV(csvData) {
  const [dateColumn, categoryColumn, valueColumn] = Object.keys(csvData[0]);
  const uniqueCategories = Array.from(
    new Set(csvData.map((d) => d[categoryColumn]))
  );

  return d3
    .groups(csvData, (d) => d[dateColumn])
    .map(([date, records]) => {
      const entry = { Date: date };
      uniqueCategories.forEach((category) => {
        const record = records.find((r) => r[categoryColumn] === category);
        entry[category] = record ? +record[valueColumn] : 0;
      });
      return entry;
    });
}

function isValidFullDate(date) {
  return !/^\d{4}$/.test(date) && !isNaN(new Date(date).getTime());
}
