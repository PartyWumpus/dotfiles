import { bind, Variable } from "astal"
import Battery from "gi://AstalBattery"

export default function BatteryInfo() {
  const bat = Battery.get_default()

  // no battery info if no battery. assumes battery existence is static
  if (bat.device_type === Battery.Type.UNKNOWN) {
    return <box />
  }

  const time_remaining = Variable.derive(
    [bind(bat, "time_to_full"), bind(bat, "time_to_empty")],
    (t1, t2) => {
      if (t1 !== 0) {
        return t1
      }
      return t2
    }
  )

  const tooltip_info = Variable.derive(
    [bind(bat, 'percentage'), bind(bat, 'energyRate'), bind(bat, 'charging')],
    (percent, watts, charging) =>
      `${charging ? "Gaining" : "Using"}: ${Math.round(watts * 10) / 10}W (${Math.round(percent * 100)}%)`,
  )

  return <box
    tooltipText={bind(tooltip_info)}
    className="batteryInfo"
    css="padding: 0 4px"
  >
    <label
    >
      {bind(time_remaining).as(t => `${Math.floor(t / 60 / 60)}:${String(Math.floor((t / 60) % 60)).padStart(2, "0")}`)}
    </label>
    <box
      onDestroy={() => { time_remaining.drop() }}
      visible={bind(bat, "isPresent")}
      css="padding:1px;padding-left:3px;">
      <circularprogress
        className="progressWheel"
        startAt={0.75}
        endAt={0.75}
        value={bind(bat, "percentage").as(p => p)}
      >
        <icon icon={bind(bat, "state").as(s => {
          switch (s) {
            case (Battery.State.CHARGING):
              return "battery-wumpus-charging-symbolic"
            case (Battery.State.DISCHARGING):
              return "battery-wumpus-discharging-symbolic"
            default:
              return "battery-wumpus-discharging-symbolic"
          }
        })} />
      </circularprogress>
    </box></box>

}
