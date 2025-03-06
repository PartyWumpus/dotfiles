import { bind, Variable } from "astal"
import Wp from "gi://AstalWp"

export default function VolumeInfo() {
  const audio = Wp.get_default()?.audio!
  const tooltip_info = Variable.derive(
    [bind(audio.defaultSpeaker, "description"), bind(audio.defaultSpeaker, "volume")],
    (desc, vol) => `${desc}\nVolume ${Math.floor(vol * 100)}%`
  )

  return <box
    tooltipText={tooltip_info()}
    className={"volumeInfo"}
  >
    <button
      css="padding-top:2px"
      onScroll={(_, ev) => {
        if (ev.delta_y >= 0) {
          audio.defaultSpeaker.volume = Math.max(0, audio.defaultSpeaker.volume - 0.015);
        } else {
          audio.defaultSpeaker.volume = Math.min(1, audio.defaultSpeaker.volume + 0.015);
        }
      }}
      //onClick={() => execAsync(nix.audio_changer)}
    >
      <circularprogress
        className="progressWheel"
        startAt={0.4}
        endAt={0.105}
        value={bind(audio.default_speaker, "volume").as(p => {
          // range (0-1) -> (0.3-1)
          if (p > 1) { return 1 }
          return (0.7 * p) + 0.3
        })}
      >
        <icon icon="audio-wumpus-headphones-symbolic" />
      </circularprogress>
    </button></box >

}
