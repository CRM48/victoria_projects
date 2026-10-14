var globalCancerName = "";

function changeAll(globalCancerName) {
  // change the line rate
  loadGenderDatafromBar(globalCancerName);

  // change the number in the block
  changeNumbers(globalCancerName);

  // change the wiki human organ
  changeOrgans(globalCancerName);

  // change the wiki content
  loadWikiPart(globalCancerName);
}

function loadGenderDatafromBar(cancerName) {
  //change gender rate graph
  d3.select("#backButton").style("display", "block");

  chartGroup.selectAll("*").remove();
  chartSvg.select("text").remove();

  d3.csv("data/genderRate.csv").then((genderData) => {
    const filtered = genderData.filter((d) => d.cancer === cancerName);
    drawGenderChart(filtered, cancerName);
  });
}

function changeNumbers(globalCancerName) {
  // number change in gender blocks
  d3.csv("data/genderNumber.csv").then(function (data) {
    // define filter and start use in male 1948
    var filtered = data.find(
      (d) =>
        d.year === "1948" &&
        d.gender === "Male" &&
        d.cancer === globalCancerName
    );
    if (filtered) {
      document.getElementById("male1948").textContent =
        filtered.number + " in 1948";
    }

    // change filter and use on other three
    filtered = data.find(
      (d) =>
        d.year === "1948" &&
        d.gender === "Female" &&
        d.cancer === globalCancerName
    );
    if (filtered) {
      document.getElementById("female1948").textContent =
        filtered.number + " in 1948";
    }
    filtered = data.find(
      (d) =>
        d.year === "2017" &&
        d.gender === "Male" &&
        d.cancer === globalCancerName
    );
    if (filtered) {
      document.getElementById("male2017").textContent =
        filtered.number + " in 2017";
    }
    filtered = data.find(
      (d) =>
        d.year === "2017" &&
        d.gender === "Female" &&
        d.cancer === globalCancerName
    );
    if (filtered) {
      document.getElementById("female2017").textContent =
        filtered.number + " in 2017";
    }
  });
}

function resetNumbers() {
  document.getElementById("male1948").textContent = "2038 in 1948";
  document.getElementById("female1948").textContent = "1436 in 1948";
  document.getElementById("male2017").textContent = "13073 in 2017";
  document.getElementById("female2017").textContent = "11509 in 2017";
}

function changeOrgans(globalCancerName) {
  resetWikiSection();

  document.getElementById("humanBody").style.filter = "grayscale(100%)";
  document.getElementById(globalCancerName).style.visibility = "visible";
}

function loadWikiPart(globalCancerName) {
  // change the wiki words
  // Fetch the Json
  fetch("data/cancerWiki.json")
    .then((response) => response.json())
    .then((data) => {
      // Select the paragraph elements and update their content
      document.getElementById("wikiCancerName").textContent =
        globalCancerName + " Cancer";
      document.getElementById("wikiCancerBrife").textContent =
        data[globalCancerName].content;

      const causes = data[globalCancerName].causes;
      causes.forEach((cause, index) => {
        const causeElement1 = document.getElementById(`factor${index}1`);
        const causeElement2 = document.getElementById(`factor${index}2`);
        if (causeElement2) {
          causeElement1.textContent = "• " + cause.causesName;
          causeElement2.textContent = " " + cause.causesContent;
        }
      });
    })
    .catch((error) => console.error("Error loading JSON data:", error));
}

// Store original HTML when page loads for reset human image
const originalWikiSection = document
  .getElementById("humanImage")
  .cloneNode(true);

function resetWikiSection() {
  const parent = document.getElementById("humanImage").parentNode;
  const oldSection = document.getElementById("humanImage");

  parent.replaceChild(originalWikiSection.cloneNode(true), oldSection);
}

function resetWiki() {
  // reset wiki to cancer
  globalCancerName = "Cancer";
  // Fetch the JSON data
  fetch("data/cancerWiki.json")
    .then((response) => response.json())
    .then((data) => {
      document.getElementById("wikiCancerName").textContent = globalCancerName;
      document.getElementById("wikiCancerBrife").textContent =
        data[globalCancerName].content;

      const causes = data[globalCancerName].causes;
      causes.forEach((cause, index) => {
        const causeElement1 = document.getElementById(`factor${index}1`);
        const causeElement2 = document.getElementById(`factor${index}2`);
        if (causeElement2) {
          causeElement1.textContent = "• " + cause.causesName;
          causeElement2.textContent = " " + cause.causesContent;
        }
      });
    })
    .catch((error) => console.error("Error loading JSON data:", error));
}

const colorMap = {
  // color setting for bars and lines
  Bladder: "#ee9b00",
  Brain: "#2a9d8f",
  "Colorectum and anus": "#5a189a",
  "Hodgkin lymphoma": "#f4a261",
  "Kidney and other urinary": "#e76f51",
  Leukaemia: "#606c38",
  "Lip Oral Cavity and Pharynx": "#ae2012",
  "Liver and intrahepatic bile ducts": "#432818",
  "Lung & Trachea": "#99582a",
  Melanoma: "#05668d",
  Myeloma: "#f72585",
  "Non-Hodgkin lymphoma": "#52b788",
  Oesophagus: "#b5838d",
  Pancreas: "#22333b",
  Stomach: "#9d4edd",
  Thyroid: "#ca6702",
};
