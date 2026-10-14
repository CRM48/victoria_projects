const data = [
  {html_name: "deaths", name: "Overall", header: "Causes of Death in New Zealand"},
  {html_name: "yearly_deaths", name: "Yearly", header: "Yearly Death Rates"}
]


const options = d3.select("#options_container")
  .selectAll("div")
  .data(data)
  .enter()
  .append("div")
  .attr("class", "option_object")
  .on("click", function(event, d){
    window.location.href = `../views/${d.html_name}.html`;
  });

options.append("span")
  .text(d => d.name)
  .attr("class", "option_text")