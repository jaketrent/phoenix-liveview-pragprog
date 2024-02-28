// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

import flatpickr from "../vendor/flatpickr";
import topbar from "../vendor/topbar";
import uploaders from "./uploaders.js";

const hooks = {
  Calendar: {
    mounted() {
      // console.log("Calendar mounted", this.el);
      this.pickr = flatpickr(this.el, {
        inline: true,
        mode: "range",
        showMonths: 2,
        onChange: (selectedDates) => {
          if (selectedDates.length !== 2) return;

          this.pushEvent("dates-picked", selectedDates);
        },
      });

      this.handleEvent("add-unavailable-dates", (dates) => {
        this.pickr.set("disable", [dates, ...this.pickr.config.disable]);
      });

      this.pushEvent("unavailable-dates", {}, (reply, _ref) => {
        this.pickr.set("disable", reply.dates);
      });
    },
    destroyed() {
      this.pickr.destroy();
    },
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks,
  uploaders,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) =>
  topbar.delayedShow(200),
);
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
