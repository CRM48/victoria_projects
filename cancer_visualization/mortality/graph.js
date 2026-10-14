function drawCancerGraph(data, cancerTypes, cancerColors, svgContainer) {
    var margin = { top: 20, right: 40, bottom: 250, left: 60 },
        width = 740 - margin.left - margin.right,
        height = 400;

    var svg = d3.select(svgContainer)
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom + 40)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var x = d3.scaleLinear().domain(d3.extent(data, d => d.Year)).range([0, width]);
    var y = d3.scaleLinear()
        .domain([0, d3.max(data, d => Math.max(...cancerTypes.map(type => d[type])))])
        .range([height, 0]);

    svg.append("g").attr("transform", "translate(0," + height + ")").call(d3.axisBottom(x).ticks(10));
    svg.append("g").call(d3.axisLeft(y));

    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("x", width / 2)
        .attr("y", height + 40)
        .text("Year")
        .style("font-size", "15px")
        .attr("font-weight", "bold");

    svg.append("text")
        .attr("text-anchor", "middle")
        .attr("transform", "rotate(-90)")
        .attr("x", -height / 2)
        .attr("y", -40)
        .text("Rate")
        .style("font-size", "15px")
        .attr("font-weight", "bold");

    var colorScale = d => cancerColors[d];;

    var line = d3.line()
        .x(d => x(d.Year))
        .y(d => y(d.value))
        .curve(d3.curveMonotoneX);;

    var pathGroup = svg.selectAll(".line-group")
        .data(cancerTypes)
        .enter().append("g")
        .attr("class", "line-group");

    var paths = pathGroup.append("path")
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", d => colorScale(d))
        .attr("stroke-width", 3)
        .attr("stroke-dasharray", function () { return this.getTotalLength(); })
        .attr("stroke-dashoffset", function () { return this.getTotalLength(); });

    var slider = d3.select(".container").append("input")
        .attr("id", "slider")
        .attr("type", "range")
        .attr("min", d3.min(data, d => d.Year))
        .attr("max", d3.max(data, d => d.Year))
        .attr("step", 1)
        .on("input", function () {
            var selectedYear = +this.value;
            updateChart(selectedYear);
        });

    slider.on("input", function () {
        var selectedYear = +this.value;
        updateChart(selectedYear);
        yearIndex = years.indexOf(selectedYear);
    });

    var playing = true;
    var yearIndex = 0;
    var years = data.map(d => d.Year);

    function animateLines() {
        paths.transition()
            .duration(3000)
            .ease(d3.easeCubicInOut)
            .attr("stroke-dashoffset", 0)
            .on("end", function () {
                if (playing) playAnimation();
            });
    }

    function updateChart(year) {
        var filteredData = data.filter(d => d.Year <= year);
        paths.transition()
            .duration(300)
            .ease(d3.easeCubicInOut)
            .attr("d", function (type) {
                return line(filteredData.map(d => ({ Year: d.Year, value: d[type] })));
            });
    }

    let interval;

    function playAnimation() {
        if (interval) clearInterval(interval);

        interval = setInterval(() => {
            if (!playing) {
                clearInterval(interval);
            }

            if (yearIndex < years.length) {
                slider.property("value", years[yearIndex]);
                updateChart(years[yearIndex]);
                yearIndex++;
            } else {
                yearIndex = 0;
                playAnimation();
            }
        }, 100);
    }

    var button = d3.select("#playPauseButton")
        .style("position", "absolute")

    function togglePlayPause() {
        playing = !playing;
        if (playing) {
            button.text("⏸");
            playAnimation();
        } else {
            button.text("▶");
        }
    }
    button.on("click", togglePlayPause);

    animateLines();
    playAnimation();

    var legend = svg.selectAll(".legend")
        .data(cancerTypes)
        .enter().append("g")
        .attr("class", "legend")
        .attr("transform", function (d, i) {
            var row = Math.floor(i);
            var xPos = (i % 1) * 120;
            var yPos = height + 60 + row * 30;
            return "translate(" + xPos + "," + yPos + ")";
        });

    legend.append("rect")
        .attr("y", 22)
        .attr("width", 15)
        .attr("height", 15)
        .style("fill", d => colorScale(d))

    legend.append("text")
        .attr("x", 20)
        .attr("y", 30)
        .attr("dy", ".35em")
        .style("text-anchor", "start")
        .text(d => d);


    // Add a tooltip to display data on hover
    var tooltip = d3.select("body")
        .append("div")
        .attr("class", "tooltip")

    // Create the lines for each cancer type
    paths
        .attr("d", function (type) {
            return line(data.map(d => ({ Year: d.Year, value: d[type] })));
        })
        .on("mouseover", function (event, d) {
            d3.select(this)
                .style("cursor", "pointer")
                .attr("stroke-width", 5)
                .attr("stroke", d3.color(cancerColors[d]).brighter(1))
                .attr("filter", "url(#glow)");

            var mouseCoords = d3.pointer(event);
            var xValue = x.invert(mouseCoords[0]);

            var closestYear = years.reduce((prev, curr) => {
                return Math.abs(curr - xValue) < Math.abs(prev - xValue) ? curr : prev;
            });

            var cancerDeathValue = data.find(d => d.Year === closestYear)[d];

            tooltip.style("visibility", "visible")
                .html(`${d}<br>Year: ${closestYear}<br>Deaths: ${cancerDeathValue}`);
        })
        .on("mousemove", function (event) {
            tooltip.style("top", (event.pageY - 20) + "px")
                .style("left", (event.pageX + 20) + "px");
        })
        .on("mouseout", function (event, d) {
            d3.select(this)
                .attr("stroke-width", 3)
                .attr("stroke", cancerColors[d])
                .attr("filter", null)
                .style("cursor", "default");

            tooltip.style("visibility", "hidden");
        });

    paths.on("click", function (event, d) {
        var cancerType = d;
        d3.select(".container").classed("shifted", true);
        d3.select(".svg-right").selectAll("*").remove();
        drawDensityPlot(cancerType);
    });
}
