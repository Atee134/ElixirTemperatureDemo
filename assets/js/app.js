import "phoenix_html"
import { Socket, Presence } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let Hooks = {}
let socket = new Socket("/socket", { params: { _csrf_token: csrfToken } })

// Connect if there are any LiveViews on the page.
let liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks,
    params: { _csrf_token: csrfToken }
})

// Show progress bar on live navigation and form submits.
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

liveSocket.connect()

// Temperature Channel
let temperatureChannel = socket.channel("temperature:lobby", {})
temperatureChannel.join()
    .receive("ok", resp => { console.log("Joined temperature channel successfully", resp) })
    .receive("error", resp => { console.log("Unable to join temperature channel", resp) })

temperatureChannel.on("new_temperature", payload => {
    console.log("New Temperature:", payload.temp)
    document.getElementById("temperature-display").innerText = `Current Temperature: ${payload.temp}°C`;
})

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
window.temperatureChannel = temperatureChannel
