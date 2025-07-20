import { bind } from "astal"
import Hyprland from "gi://AstalHyprland"

// TODO: support multimonitor again
export default function Workspaces() {
  const hypr = Hyprland.get_default()
  if (!hypr) {
    return <box />
  }


  return <box className={"workspaces"} css="padding-left:2px;">
    {bind(hypr, "workspaces").as(wks => {
      let list = []
      for (let i = 1; i <= 10; i++) {
        let workspace = wks.find((ws) => ws.id === i)
        list.push(workspace)
      }
      return list.map((ws, i) => {
        if (ws === undefined) {
          return <button 
          onClick={() => hypr.dispatch("workspace", String(i+1))}
          className={"EmptyWorkspace"} />
        }
        else {
          return <button 
          onClick={() => {ws.focus()}}
          className={bind(hypr, "focusedWorkspace").as(fw =>
            ws.id === fw.id ? "FocusedWorkspace" : "ActiveWorkspace")}>
          </button>
        }
      })
    })}
  </box >
}

