import { bind, Variable } from "astal"
import GTop from "gi://GTop"

export default function CpuInfo() {
  const cpu = new GTop.glibtop_cpu()
  GTop.glibtop_get_cpu(cpu)
  let last_used = cpu.user + cpu.sys + cpu.nice + cpu.irq + cpu.softirq
  let last_total = last_used + cpu.idle + cpu.iowait

  const cpuVar = Variable(0).poll(1000, () => {
    GTop.glibtop_get_cpu(cpu)
    const used = cpu.user + cpu.sys + cpu.nice + cpu.irq + cpu.softirq
    //const total = used + cpu.idle + cpu.iowait
    const total = cpu.total
    if (used - last_used < 0) {
      return 0
    }
    const load = (used - last_used) / (total - last_total)
    last_used = used
    last_total = total

    return Math.min(load, 1)
  }

  )
  const tooltip_info = Variable.derive(
    [bind(cpuVar)],
    (percent) => `Cpu usage: ${Math.floor(percent * 100)}%`
  )

  return <box
    tooltipText={tooltip_info()}
    className={"volumeInfo"}
    onDestroy={() => {
      cpuVar.drop()
      tooltip_info.drop()
    }}
  >
    <button
      css="padding-top:2px"
    >
      <circularprogress
        className="progressWheel"
        startAt={0.4}
        endAt={0.105}
        value={bind(cpuVar).as(p => {
          // range (0-1) -> (0.3-1)
          return (0.7 * p) + 0.3
        })}
      >
        <icon icon="system-wumpus-cpu-symbolic" />
      </circularprogress>
    </button></box >

}
