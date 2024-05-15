import "phoenix_html"
import { Socket } from "phoenix"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let socket = new Socket("/socket", { params: { _csrf_token: csrfToken } });
socket.connect();

let something = false;

// Show progress bar on live navigation and form submits.
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", info => topbar.show());
window.addEventListener("phx:page-loading-stop", info => topbar.hide());

// Temperature Channel
let temperatureChannel = socket.channel("temperature:lobby", {});
temperatureChannel.join()
    .receive("ok", resp => { console.log("Joined temperature channel successfully", resp); })
    .receive("error", resp => { console.log("Unable to join temperature channel", resp); });

// Define some basic styles for the table and cells
const tableStyle = 'border-collapse: collapse; margin: 10px 0;';
const cellStyle = 'padding: 8px; text-align: center;';

function getColorForTemperature(temp) {
    // Generate a smooth color gradient from light blue (-30°C) to red (50°C)
    const range = 80; // Total temperature range (-30 to 50)
    const normalizedTemp = temp + 30; // Normalize temperature to start from 0
    const hue = (1 - (normalizedTemp / range)) * 240; // Calculate hue (240 is blue, 0 is red)
    return `hsl(${hue}, 100%, 50%)`; // Return HSL color string
}

function updateUI(temperatures) {
  console.log("Updating UI");
  // Sort temperatures by sensorId before updating the UI
  temperatures.sort((a, b) => a.sensor_id - b.sensor_id);

  let container = document.getElementById('temperature-display');
  if (!container) {
      console.error("Temperature display container not found!");
      return;
  }

  let newHtml = `<table style="${tableStyle}">`;

  // Iterate over temperatures array and create table rows with 10 cells each
  for (let i = 0; i < temperatures.length; i += 30) {
      newHtml += "<tr>";
      for (let j = i; j < i + 30 && j < temperatures.length; j++) {
          const backgroundColor = getColorForTemperature(temperatures[j].temp);
          newHtml += `<td id="${temperatures[j].sensor_id}" style="${cellStyle} background-color: ${backgroundColor};">${temperatures[j].temp}°C</td>`;
      }
      newHtml += "</tr>";
  }

  newHtml += "</table>";
  container.innerHTML = newHtml;
  console.log("New HTML content set for temperature display");
}

// Listen for new batches of temperature data and update UI accordingly
temperatureChannel.on("new_temperatures", payload => {
    // Ensure payload.temperatures is an array before calling updateUI
    if (Array.isArray(payload.temperatures)) {
        updateUI(payload.temperatures);
    } else {
        console.error("Received payload is not an array:", payload);
    }
});

// Expose socket on window for web console debug logs:
window.socket = socket;
window.temperatureChannel = temperatureChannel;
