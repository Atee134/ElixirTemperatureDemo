import "phoenix_html";
import { Socket } from "phoenix";
import topbar from "../vendor/topbar";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let socket = new Socket("/socket", { params: { _csrf_token: csrfToken } });
socket.connect();

// Show progress bar on live navigation and form submits.
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", info => topbar.show());
window.addEventListener("phx:page-loading-stop", info => topbar.hide());

// Temperature Channel
let temperatureChannel = socket.channel("temperature:lobby", {});
temperatureChannel.join()
    .receive("ok", resp => { console.log("Joined temperature channel successfully", resp); })
    .receive("error", resp => { console.log("Unable to join temperature channel", resp); });

// Define basic styles for the cells
const cellStyle = 'padding: 8px; text-align: center;';

// Create initial table structure
function createTable(rowLength, totalCells) {
  let container = document.getElementById('temperature-display');
  if (!container) {
    console.error("Temperature display container not found!");
    return;
  }

  let newHtml = '<table style="border-collapse: collapse; margin: 10px 0;">';
  for (let i = 0; i < totalCells; i += rowLength) {
    newHtml += '<tr>';
    for (let j = i; j < i + rowLength && j < totalCells; j++) {
      newHtml += `<td id="sensor-${j + 1}" style="${cellStyle}"></td>`;
    }
    newHtml += '</tr>';
  }
  newHtml += '</table>';
  container.innerHTML = newHtml;
}

// Update the UI with temperature data
function updateUI(temperatures) {
  temperatures.forEach(temp => {
    let cell = document.getElementById(`sensor-${temp.sensor_id}`);
    if (cell) {
      cell.innerHTML = `${temp.temp}°C`;
      cell.style.backgroundColor = getColorForTemperature(temp.temp);
    }
  });
}

function getColorForTemperature(temp) {
    const range = 80;  // Total temperature range (-30 to 50)
    const normalizedTemp = temp + 30;  // Normalize temperature to start from 0
    const hue = (1 - (normalizedTemp / range)) * 240;  // Calculate hue (240 is blue, 0 is red)
    return `hsl(${hue}, 100%, 50%)`;  // Return HSL color string
}

// Listen for new batches of temperature data and update UI accordingly
temperatureChannel.on("new_temperatures", payload => {
    if (Array.isArray(payload.temperatures)) {
        updateUI(payload.temperatures);
    } else {
        console.error("Received payload is not an array:", payload);
    }
});

// Expose socket on window for web console debug logs:
window.socket = socket;
window.temperatureChannel = temperatureChannel;

// Initialize the table when the document is ready
document.addEventListener('DOMContentLoaded', () => {
  createTable(30, 5000);  // Example with rowLength = 30, totalCells = 1000
});
