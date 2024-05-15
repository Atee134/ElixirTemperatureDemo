import "phoenix_html"
import { Socket } from "phoenix"
import topbar from "../vendor/topbar"

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

// Buffer to store batches of temperatures
let temperatureBuffer = [];

function handleData(temperatures) {
  // Merge new temperatures into the buffer, maintaining grouping by sensorId
  temperatures.forEach(reading => {
    const { group_id, sensor_id, temp } = reading;
    if (!temperatureBuffer[group_id]) {
      temperatureBuffer[group_id] = {};
    }
    temperatureBuffer[group_id][sensor_id] = temp;
  });
}

function updateUI() {
  console.log("Updating UI");

  // Check if there are any items in the buffer
  if (temperatureBuffer.length === 0 || temperatureBuffer.every(group => Object.keys(group).length === 0)) {
      console.log("No items in buffer, DOM is not updated");
      return;  // Exit the function if the buffer is empty
  }

  let container = document.getElementById('temperature-display');
  if (!container) {
      console.error("Temperature display container not found!");
      return;
  }

  let newHtml = '';

  // Define some basic styles for the table and cells
  const tableStyle = 'border-collapse: collapse; margin: 10px 0;';
  const cellStyle = 'border: 1px solid black; padding: 8px; text-align: center;';

  // Create divs for each temperature reading grouped by sensor
  temperatureBuffer.forEach((group, groupId) => {
      if (Object.keys(group).length > 0) {  // Check if there are entries in the group
          newHtml += `<div class="group-container"><h3>Group ${groupId}</h3>`;
          newHtml += `<table style="${tableStyle}">`;
          let groupEntries = Object.entries(group);
          for (let i = 0; i < groupEntries.length; i += 10) {  // Process every 10 items for a row
              newHtml += `<tr>`;
              groupEntries.slice(i, i + 10).forEach(([sensorId, temp]) => {
                  newHtml += `<td style="${cellStyle}">${temp}°C</td>`;
              });
              newHtml += `</tr>`;
          }
          newHtml += `</table></div>`;
      }
  });

  container.innerHTML = newHtml;
  console.log("New HTML content set for temperature display");
  temperatureBuffer = [];  // Clear the buffer after updating UI
}

// Setup to update UI every second
setInterval(updateUI, 1000);

// Listen for new batches of temperature data
temperatureChannel.on("new_temperatures", payload => {
  handleData(payload.temperatures);
});

// Expose socket on window for web console debug logs:
window.socket = socket;
window.temperatureChannel = temperatureChannel;
