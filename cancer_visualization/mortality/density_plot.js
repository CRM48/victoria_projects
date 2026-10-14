function drawDensityPlot(cancerType) {
    d3.csv("data/combined_cancer_deaths.csv").then(function (deathData) {
        deathData.forEach(function (d) {
            d.Year = +d.Year;
            d[`${cancerType}-male`] = +d[`${cancerType}-male`];
            d[`${cancerType}-female`] = +d[`${cancerType}-female`];
        });

        const margin = { top: 20, right: 40, bottom: 60, left: 60 };
        const width = 710 - margin.left - margin.right;
        const height = 482 - margin.top - margin.bottom;

        d3.select(".svg-right").selectAll("*").remove();

        const svgRight = d3.select(".svg-right")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom + 227)
            .append("g")
            .attr("transform", `translate(${margin.left},${margin.top})`);

        svgRight.append("text")
            .attr("x", width / 2)
            .attr("y", margin.top - 10)
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .attr("fill", "#333")
            .attr("font-weight", "bold")
            .text(cancerType);

        const x = d3.scaleLinear()
            .domain(d3.extent(deathData, d => d.Year))
            .range([0, width]);

        const y = d3.scaleLinear()
            .domain([0, d3.max(deathData, d => Math.max(d[`${cancerType}-male`], d[`${cancerType}-female`]))])
            .range([height, 0]);

        svgRight.append("text")
            .attr("text-anchor", "middle")
            .attr("x", width / 2)
            .attr("y", height + 40)
            .text("Year")
            .style("font-size", "15px")
            .attr("font-weight", "bold");

        svgRight.append("text")
            .attr("text-anchor", "middle")
            .attr("transform", "rotate(-90)")
            .attr("x", -height / 2)
            .attr("y", -40)
            .text("Rate")
            .style("font-size", "15px")
            .attr("font-weight", "bold");

        const maleDeaths = deathData.map(d => ({ Year: d.Year, value: d[`${cancerType}-male`] }));
        const femaleDeaths = deathData.map(d => ({ Year: d.Year, value: d[`${cancerType}-female`] }));

        const densityArea = d3.area()
            .x(d => x(d.Year))
            .y0(height)
            .y1(d => y(d.value));

        function animatePath(path, data) {
            path.datum(data)
                .attr("d", densityArea)
                .attr("opacity", 0)
                .transition()
                .duration(1200)
                .ease(d3.easeLinear)
                .attr("opacity", 0.5)
                .attrTween("d", function () {
                    const interpolator = d3.interpolateArray(
                        data.map(d => ({ Year: x.domain()[0], value: d.value })),
                        data
                    );
                    return t => densityArea(interpolator(t));
                });
        }

        animatePath(
            svgRight.append("path")
                .attr("class", "male-density")
                .attr("fill", "#4A90E2")
                .attr("stroke", "#1A4D80")
                .attr("stroke-width", 1.5),
            maleDeaths
        );

        animatePath(
            svgRight.append("path")
                .attr("class", "female-density")
                .attr("fill", "#FF69B4")
                .attr("stroke", "#B03060")
                .attr("stroke-width", 1.5),
            femaleDeaths
        );

        svgRight.append("g")
            .attr("transform", `translate(0,${height})`)
            .call(d3.axisBottom(x).ticks(10));

        svgRight.append("g")
            .call(d3.axisLeft(y));

        // Legend
        const legend = svgRight.append("g")
            .attr("transform", `translate(0,${height + margin.bottom - 30})`);

        const legendData = [
            { label: "Male", color: "#4A90E2", yOffset: 0 },
            { label: "Female", color: "#FF69B4", yOffset: 30 }
        ];

        legendData.forEach((item, i) => {
            legend.append("rect")
                .attr("x", 540)
                .attr("y", item.yOffset)
                .attr("width", 20)
                .attr("height", 20)
                .attr("fill", item.color);

            legend.append("text")
                .attr("x", 570)
                .attr("y", item.yOffset + 13)
                .attr("font-size", "12px")
                .attr("fill", item.color)
                .text(item.label);
        });

        // Table logic
        const groupedData = groupByInterval(deathData, cancerType);
        drawTable(svgRight, groupedData, width, height);
    });

    function groupByInterval(data, cancerType, interval = 12) {
        let grouped = [], totalMale = 0, totalFemale = 0;
        let startYear = Math.floor(d3.min(data, d => d.Year) / interval) * interval;

        for (let year = startYear; year <= d3.max(data, d => d.Year); year += interval) {
            const rangeData = data.filter(d => d.Year >= year && d.Year < year + interval);
            const male = d3.sum(rangeData, d => d[`${cancerType}-male`]);
            const female = d3.sum(rangeData, d => d[`${cancerType}-female`]);

            totalMale += male;
            totalFemale += female;

            grouped.push({ interval: `${year}-${year + interval - 1}`, male, female });
        }

        grouped.push({ interval: "Total", male: totalMale, female: totalFemale });
        return grouped;
    }

    function drawTable(svg, groupedData, width, height) {
        let tableGroup = svg.append("g")
            .attr("transform", `translate(${width / 2 - 200}, ${height + 50})`);
        let rowHeight = 25;
        let colWidth = [130, 130, 130];

        tableGroup.append("rect")
            .attr("width", colWidth.reduce((a, b) => a + b, 0))
            .attr("height", (groupedData.length + 1) * rowHeight + 5)
            .attr("fill", "none")
            .attr("stroke", "#333")
            .attr("stroke-width", 1)
            .attr("rx", 5)
            .attr("ry", 5);

        let headerGroup = tableGroup.append("g");

        headerGroup.append("rect")
            .attr("width", colWidth.reduce((a, b) => a + b, 0))
            .attr("height", rowHeight)
            .attr("fill", "#4A90E2")
            .attr("rx", 4)
            .attr("ry", 4);

        let headers = ["Year", "Male Deaths", "Female Deaths"];
        headers.forEach((text, i) => {
            let centerX = colWidth.slice(0, i).reduce((a, b) => a + b, 0) + colWidth[i] / 2;
            headerGroup.append("text")
                .text(text)
                .attr("x", centerX)
                .attr("y", rowHeight / 2)
                .attr("dy", ".35em")
                .attr("fill", "white")
                .attr("font-weight", "bold")
                .attr("font-size", "14px")
                .attr("text-anchor", "middle")
                .style("font-family", "Arial, sans-serif");
        });

        groupedData.forEach((d, i) => {
            let rowY = (i + 1) * rowHeight;
            let isTotalRow = d.interval === "Total";

            tableGroup.append("rect")
                .attr("x", 0)
                .attr("y", rowY)
                .attr("width", colWidth.reduce((a, b) => a + b, 0))
                .attr("height", 29)
                .attr("font-size", isTotalRow ? "14px" : "14px")
                .attr("rx", isTotalRow ? 5 : 0)
                .attr("ry", isTotalRow ? 5 : 0)
                .attr("fill", isTotalRow ? "#B0C4DE" : i % 2 === 0 ? "#f9f9f9" : "#e6e6e6")

            let intervalLabel = (d.interval === "2016-2027" || d.interval === "2016–2027") ? "2016–2017" : d.interval;
            let rowValues = [intervalLabel, d.male, d.female];
            rowValues.forEach((value, j) => {
                let centerX = colWidth.slice(0, j).reduce((a, b) => a + b, 0) + colWidth[j] / 2;
                tableGroup.append("text")
                    .text(value)
                    .attr("x", centerX)
                    .attr("y", rowY + rowHeight / 2)
                    .attr("dy", ".35em")
                    .attr("fill", isTotalRow ? "black" : "#333")
                    .attr("font-weight", isTotalRow ? "bold" : "normal")
                    .attr("font-size", isTotalRow ? "14px" : "13px")
                    .attr("text-anchor", "middle")
                    .style("font-family", "Arial, sans-serif");;
            });
        });
    }
}
