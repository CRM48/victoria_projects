# Cancer Data Visualization

An interactive web application developed as part of a Human-Computer Interaction university project. The website uses cancer statistics to explore historical trends, mortality rates, and comparisons across different cancer types.

The project was developed collaboratively, with a focus on presenting complex health data through accessible and interactive visualizations.

## Features

- **Cancer History:** Explore historical cancer data through interactive visualizations.
- **Cancer Mortality:** View mortality statistics across different cancer types.
- **Mortality Comparisons:** Compare cancer mortality rates and trends across different years.

## Technologies

- HTML, CSS, JavaScript
- D3.js for data visualization
- CSV and JSON datasets

## Running the Project

No installation or additional dependencies are required, other than Python to run a local web server.

1. Clone the repository and navigate to the project directory.
2. Start a local server:

   ```bash
   python -m http.server 8000
   ```

3. Open [http://localhost:8000](http://localhost:8000) in your browser.

The application will automatically redirect to the homepage.

**Note:** An internet connection is required to load D3.js from its CDN.

## Project Structure

```text
cancer-visualization/
├── history/       # Historical cancer visualizations
├── mortality/     # Cancer mortality visualizations
├── comparison/    # Mortality rate comparisons
├── index.html     # Application entry point
└── README.md
```

## About

Developed as a group project for SWEN422 (Human-Computer Interaction), with an emphasis on interactive data visualization and user interface design.