import { App } from "astal/gtk3"
import style from "./style.scss"
import Bar from "./widget/Bar"
import Popovers from "./widget/Popovers"
import Hotcorner from "./widget/Hotcorner"

App.start({
  icons: `./icons/`,
  css: style,
  main() {
    App.get_monitors().map(Bar)
    App.get_monitors().map(Popovers)
    App.get_monitors().map(Hotcorner)
  },
  requestHandler(request, res) {
    // getting Gio.IOErrorEnum "Stream has outstanding operation"
    switch (request) {
      case "hotcorner":
        globalThis?.enableHotcorner?.()
        res("hotcorner success")
      default:
        res(`ERROR: ${request} is an invalid request`)
    }
  },
})
