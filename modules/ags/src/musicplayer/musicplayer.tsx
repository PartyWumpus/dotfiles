import { bind } from "astal";
import { Astal, Gdk, Gtk } from "astal/gtk3";
import { Icon } from "astal/gtk3/widget";
import Mpris from "gi://AstalMpris";
import Pango from "gi://Pango?version=1.0";

const scaler = 3;
// unicode consortium i wish pain upon thee
const newline_regex = "(\r\n|[\n\v\f\r\x85\u2028\u2029])"

function lengthStr(length: number) {
  if (length <= 0) {
    return `-:--`;
  }
  const min = Math.floor(length / 60);
  const sec = Math.floor(length % 60);
  const sec0 = sec < 10 ? "0" : "";
  return `${min}:${sec0}${sec}`;
}

export default function MusicPlayer(gdkmonitor: Gdk.Monitor) {
  return <box />
  const player = Mpris.get_default().players[0]
  return <window
    className="MusicPlayer"
    namespace="ags-bar"
    exclusivity={Astal.Exclusivity.IGNORE}
    anchor={Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.BOTTOM}
  >
    <box className="bg" css={`font-size:${2 * scaler}px;`} widthRequest={114 * scaler} vertical>
      <box
        heightRequest={108 * scaler}
        valign={Gtk.Align.START}
        css={bind(player, "coverArt").as(cover =>
          `background-color: #FF0FFF;
          margin-top: ${6 * scaler}px;
          background-image: url('${cover}');
          background-size: contain;
          background-position: center;
          `
        )}
      />
      <box heightRequest={8 * scaler} hexpand css={`margin-top:${4 * scaler}px;`} valign={Gtk.Align.START}>
        <box css="background-color: #000000;" hexpand />
        <box css="background-color: #00FF00;" hexpand />
        <box css="background-color: #FF0000;" hexpand />
        <box css="background-color: #0000FF;" hexpand />
        <box css="background-color: #FF00FF;" hexpand />
        <box css="background-color: #00FF00;" hexpand />
      </box>
      <box margin_top={scaler * 2} valign={Gtk.Align.START}>
        <label setup={(self) => {
        }} halign={Gtk.Align.START} hexpand truncate css={`font-weight: 600;font-size:${8 * scaler}px;padding:0px`}>{bind(player, "title").as(t => `${t.toUpperCase()}\nwasd`)}</label>
        <label halign={Gtk.Align.END} valign={Gtk.Align.END} css={`font-size:${4 * scaler}px;margin-bottom:${1.5 * scaler}px;margin-left:${scaler*10}px`}>{lengthStr(player.length)}</label>
      </box>
      {/*TODO: remove padding between title and artist*/}
      <box className="buttons" valign={Gtk.Align.START}>
        <label single_line_mode valign={Gtk.Align.START} halign={Gtk.Align.START} hexpand css={`font-weight: 500;font-size:${6 * scaler}px;`}>{bind(player, "artist")}</label>
        {/*
        <button halign={Gtk.Align.END} className="play" onClicked={()=>{player.play_pause()}} > </button>
        <button halign={Gtk.Align.END} className="shuffle" onClicked={() => {player.shuffle();console.log(player.shuffleStatus, Mpris.Shuffle)}}> </button>
        <button halign={Gtk.Align.END} className="list" >󰲸 </button>
        <button halign={Gtk.Align.END} className="heart" >♥</button>
        */}
      </box>
      <box valign={Gtk.Align.START}>
        <label halign={Gtk.Align.START} hexpand css={`font-weight: 400;font-size:${3 * scaler}px;`}>{"TODO (lyrics)\nTODO\nto do\nme when i do it later"}</label>
      </box>

      <box margin_top={scaler * 4} valign={Gtk.Align.START}>
        <box hexpand css={`font-size:${8 * scaler}px;`} valign={Gtk.Align.END}>
          <Icon icon={bind(player, "entry").as(e => {
            if (e === null) {
              return "audio-x-generic-symbolic"
            }
            return (Icon.lookup_icon(e) ? e : "audio-x-generic-symbolic")
          })}
          />
        </box>

        <box vertical css={`font-size:${3 * scaler}px`} valign={Gtk.Align.START} >
          <label halign={Gtk.Align.START} css="font-weight: 800;">TODO (date)</label>
          <label halign={Gtk.Align.START} css="font-weight: 800;">TODO (publisher)</label>
        </box>
      </box>
      <box css={`background-color:#FF00FF;min-height:${3*scaler}px;`} marginTop={5*scaler}/>
    </box>

  </window>
}
