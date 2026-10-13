

// Load the CSV data
d3.csv("../data/Historical_Mortality.csv").then(function(data) {    
    // Convert the year and number of deaths to Integers
    data.forEach(d => {
        d["Year"] = Number(d["Year"]);
        d["Number of Deaths"] = Number(d["Number of Deaths"]);
    });

    // 2021 and 2022 omitted a lot of data so I decided to filter it out
    data = data.filter(d => d["Year"] !== 2021 && d["Year"] !== 2022);

    // Create a mapping of years to their corresponding data (and get an array containing every year)
    const yearData = d3.group(data, d => d["Year"]);
    const yearKeys = Array.from(yearData.keys());

    // Create a mapping of Causes of death to their corresponding data (and get the keys)
    const causes = d3.group(data, d => d["Causes of Death"])
    const causeKeys = Array.from(causes.keys());

    // default and initial year
    year = 2020;

    // This adds a new field to each year/cause called normalised deaths which is the number of deaths per 1000 people for each cause
    yearData.forEach(year => {
        const totalDeaths = d3.sum(year, d => d["Number of Deaths"]);
        year.forEach(d => d.normalisedDeaths = Math.round((d["Number of Deaths"] / totalDeaths) * 1000));
        const currentSum = d3.sum(year, d => d.normalisedDeaths);
        const diff = 1000 - currentSum;
        for (let i = 0; i < Math.abs(diff); i++) {
            if (diff > 0) {
                year[i].normalisedDeaths += 1;
            } else {
                year[i].normalisedDeaths -= 1;
            }
        }
    });
    
    // Set up the SVG canvas dimensions
    const width = 800, height = 400;
    const circleRadius = 5;
    const xCircles = 50, yCircles = 20;
    const xSpacing = (width - 2 * circleRadius) / xCircles;
    const ySpacing = (height - 2 * circleRadius) / yCircles;
    const marginX = 8;
    const marginY = 8;
    

    // Create the year select container
    const info_block = d3.select("#graphs_container")
        .append("div")
        .attr("id", "info_block")
        .attr("class", "object")
        .style("height", `${height}px`)
        .style("width", "250px");

    // Add the selection to the container
    const select = d3.select("#info_block")
        .append("select")
        .attr("id", "yearSelect")
        .attr("size", yearKeys.length);

    // Create the options for the selection (all years) with default year (1948)
    select.selectAll("option")
        .data(yearKeys.reverse())
        .enter()
        .append("option")
        .attr("class", "yearOptions")
        .attr("value", d => d)
        .text(d => d)
        .attr("selected", d => d == year ? "selected" : null);

    // When a year is selected, output 1000 circles, coloured to represent the proportion of each cause
    select.on("change", function() {
        year = d3.select(this).property("value");
        causetuples = yearData.get(parseInt(year)).map((d, i) => [d["Causes of Death"], d.normalisedDeaths, d3.schemeCategory10[i % 10]]).sort((a,b) => b[1] - a[1]);
        count = 0;
        causeOption = 0;
        total = causetuples[causeOption][1];
        color = causetuples[causeOption][2];

        svg.selectAll("circle").remove();
        for (let i = 0; i < yCircles; i++) {
            for (let j = 0; j < xCircles; j++) {
                if(count >= total){
                    causeOption++;
                    total += causetuples[causeOption][1];
                    color = causetuples[causeOption][2];
                }
                svg.append("circle")
                    .attr("cx", j * xSpacing + circleRadius + marginX)
                    .attr("cy", i * ySpacing + circleRadius + marginY)
                    .attr("r", circleRadius)
                    .attr("class", `circle-${causetuples[causeOption][0].replace(/\s+/g, '-')}`) // sanitize class name
                    .attr("fill", color);
                count++;
            }
          }
      });


    // This is the svg object with which to append the circles to
    const svg = d3.select("#graphs_container").append("svg")
        .attr("id", "people")
        .attr("width", width)
        .attr("height", height)
        .attr("class", "object")
        .attr("viewBox", `0 0 ${width} ${height}`)
        .attr("preserveAspectRatio", "none")
        .style("z-index", "2");

    // Set up the default (1948) proportion
    select.dispatch('change');

    // The final block containing the legend
    const legend_block = d3.select("#graphs_container")
        .append("div")
        .attr("id", "legend_block")
        .attr("class", "object")
        .style("height", `${height}px`)
        .style("width", "250px");

    // Create a percent object (initially with dislay = none)
    d3.select("#graphs_container")
        .append("div")
        .attr("id", "percent")
        .text("base");

    // Sets the parameters for each legend entry
    legend_block.selectAll("div")
        .data(causeKeys)
        .enter()
        .append("div")
        .attr("class", "legend-entry")
        .each(function(d, i) {
            const color = d3.schemeCategory10[i % 10];
            const container = d3.select(this);

            // Sets teh colour
            container.style("background-color", color);

            // Sets the label as the cause
            container.append("label")
                .style("user-select", "none")
                .text(d)
                .attr("class", "legend_text")
                .attr("id", `legend-${i}`);
            
            // When hovering over an entry, show the percent it represents for that year, and darken every other entry
            container.on("mouseover", function() {
                d3.selectAll("circle")
                    .transition()
                    .duration(200)
                    .style("opacity", 0.2);
                d3.selectAll(`.circle-${d.replace(/\s+/g, '-')}`)
                    .transition()
                    .duration(200)
                    .style("opacity", 1);
                d3.select("#percent")
                    .text(`${yearData.get(parseInt(year)).find(cause => cause["Causes of Death"] == d).normalisedDeaths/10}%`)
                    .style("display", "inline");
            })
            .on("mouseout", function() {
                d3.selectAll("circle")
                    .transition()
                    .duration(200)
                    .style("opacity", 1);
                d3.select("#percent")
                    .style("display", "none");
            });
        });
});
