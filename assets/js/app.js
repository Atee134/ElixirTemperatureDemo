import "phoenix_html"
import { Socket } from "phoenix"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let socket = new Socket("/socket", { params: { _csrf_token: csrfToken } })
socket.connect()

// Show progress bar on live navigation and form submits.
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// Temperature Channel
let temperatureChannel = socket.channel("temperature:lobby", {})
temperatureChannel.join()
    .receive("ok", resp => { console.log("Joined temperature channel successfully", resp) })
    .receive("error", resp => { console.log("Unable to join temperature channel", resp) })

temperatureChannel.on("new_temperature", payload => {
  console.log("New Temperature:", payload.temp)
  if (document.getElementById("temperature-display")) {
      document.getElementById("temperature-display").innerText = `Current Temperature: ${payload.temp}°C`;
  }
});

// Expose socket on window for web console debug logs:
window.socket = socket
window.temperatureChannel = temperatureChannel
