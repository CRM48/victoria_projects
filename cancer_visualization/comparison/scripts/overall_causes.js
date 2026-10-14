d3.csv("../data/Historical_Mortality.csv").then(function(data) {
    
    // Convert the year and number of deaths to Integers
    data.forEach(d => {
        d["Year"] = Number(d["Year"]);
        d["Number of Deaths"] = Number(d["Number of Deaths"]);
    });

     // Create a mapping of Causes of death to their corresponding data (and get each cause in an array)
    const causes = d3.group(data, d => d["Causes of Death"])
    const causeKeys = Array.from(causes.keys());
    
    // Set up the SVG canvas dimensions
    const width = 800, height = 400;
    const margin = {top: 20, right: 30, bottom: 40, left: 60};

    // Add the initial svg component to the container
    const svg = d3.select("#graphs_container").append("svg")
        .attr("width", width)
        .attr("height", height)
        .attr("class", "object")
        .attr("viewBox", `0 0 ${width} ${height}`)
        .attr("preserveAspectRatio", "none")
        .style("z-index", "2");

    // Set up scales for the x axis (Year) and y axis (Death count)
    const x = d3.scaleLinear()
        .domain([d3.min(data, d => d.Year), d3.max(data, d => d.Year)])
        .range([margin.left, width - margin.right]);

    const y = d3.scaleLinear()
        .domain([0, d3.max(data, d => d["Number of Deaths"])])
        .range([height - margin.bottom, margin.top]);


    // Set up the axes
    const xAxis = svg.append("g")
        .attr("transform", `translate(0,${height - margin.bottom})`)
        .call(d3.axisBottom(x).ticks(10));

    const yAxis = svg.append("g")
        .attr("transform", `translate(${margin.left}, 0)`)
        .call(d3.axisLeft(y).ticks(10));

    // Add labels to axes
    svg.append("text")
        .attr("transform", `translate(${width / 2},${height - 10})`)
        .style("text-anchor", "middle")
        .text("Year");

    svg.append("text")
        .attr("transform", `translate(15,${height / 2}) rotate(-90)`)
        .style("text-anchor", "middle")
        .text("Number of Deaths");

    // Define the line function for drawing each cause
    const line = d3.line()
        .x(d => x(d.Year))
        .y(d => y(d["Number of Deaths"]))
        .curve(d3.curveMonotoneX);

    // Create a line for each cause of death
    svg.selectAll(".line")
        .data(causes)
        .enter().append("path")
        .attr("class", "line")
        .attr("id", (d, i) => `line-${i}`)
        .attr("d", d => line(d[1]))
        .attr("stroke", (d, i) => d3.schemeCategory10[i % 10])
        .style("fill", "none")
        .attr("stroke-width", 2);

    // Add a block to display the legend (on left as row-reverse flex is used)
    const legend_block = d3.select("#graphs_container")
        .append("div")
        .attr("id", "legend_block")
        .attr("class", "object")
        .style("height", `${height}px`)
        .style("width", "250px");

    // Add each cause of death to the legend (coloured in the same order as their corresponding lines)
    legend_block.selectAll("div")
        .data(causeKeys)
        .enter()
        .append("div")
        .attr("class", "legend-entry")
        .style("cursor", "pointer")
        .each(function(d, i) {
            const color = d3.schemeCategory10[i % 10];
            const container = d3.select(this);
            // Set the colour
            container.style("background-color", color);

            // Set the text
            container.append("label")
                .style("user-select", "none")
                .text(d)
                .attr("class", "legend_text")
                .attr("id", `legend-${i}`)
            
            // When clicked, hide the line, and turn the legend entry to a blank colour
            container.on("click", function(event, d){
                    d3.select("#info_block")
                    .text(d);
                    const line = d3.select(`#line-${i}`);
                    line.style("display", line.style("display") == "none" ? "inline" : "none");
                    container.style("background-color", container.style("background-color") == "gainsboro" ? color : "gainsboro");

                });
            
            // When hovering over, widen the line the entry corresponds to    
            container.on("mouseover", function() {
                d3.select(`#line-${i}`)
                .transition()
                .duration(200)
                .attr("stroke-width", 5);
            })
            .on("mouseout", function() {
                d3.select(`#line-${i}`)
                .transition()
                .duration(200)
                .attr("stroke-width", 2);
            });
        });
});
