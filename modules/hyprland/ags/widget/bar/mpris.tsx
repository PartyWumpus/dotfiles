import { bind } from "astal";
import { Gdk, Gtk } from "astal/gtk3";
import GLib from "gi://GLib";
import { Icon } from "astal/gtk3/widget";
import Mpris from "gi://AstalMpris";
import Hyprland from "gi://AstalHyprland";


const hyprland = Hyprland.get_default()

const transition_duration = 500

const enum SLIDE_STATE {
  STOPPED,
  DOWN,
  UP
}

const playerMaps: Record<string, string> = {
  Chrome: "initialclass:google-chrome",
  Spotify: "initialclass:[sS]potify"
}

function lengthStr(length: number) {
  if (length <= 0) {
    return `-:--`;
  }
  const min = Math.floor(length / 60);
  const sec = Math.floor(length % 60);
  const sec0 = sec < 10 ? "0" : "";
  return `${min}:${sec0}${sec}`;
}

function MediaPlayer({ player }: { player: Mpris.Player }) {
  let direction = true;
  let lock = false;
  const timeouts: GLib.Source[] = []

  let animation = SLIDE_STATE.STOPPED;


  return <box vertical={true}>
    <box
      className="mediaInfo"
      onDestroy={() => {
        for (const timeout of timeouts) {
          clearTimeout(timeout)
          clearInterval(timeout)
        }
      }}
    >
      <box>
        <box
          className="Cover"
          valign={Gtk.Align.CENTER}
          //tooltipText={bind(player, "album").as(album => `Album: ${album}`)}
          tooltipText={bind(player, "metadata").as(() => `\
Song: ${player.title}
Artist: ${player.artist}
Album: ${player.album}`)}
          css={bind(player, "coverArt").as(cover =>
            `background-image: url('${cover}');`
          )}
        />
        <eventbox
          onHover={() => {
            animation = SLIDE_STATE.DOWN
          }}
          onHoverLost={(self) => {
            animation = SLIDE_STATE.UP
          }}
        ><box><scrollable
          setup={(self) => {
            timeouts.push(setInterval(() => {
              if (animation === SLIDE_STATE.STOPPED) {
                return
              }
              const prev = self.vadjustment.value

              if (animation === SLIDE_STATE.UP) {
                self.vadjustment.value -= 2
              } else if (animation === SLIDE_STATE.DOWN) {
                self.vadjustment.value += 2
              }

              if (prev === self.vadjustment.value) {
                animation = SLIDE_STATE.STOPPED
              }
            }, 10))
          }}
          heightRequest={18}
          hscroll={Gtk.PolicyType.NEVER}
          vscroll={Gtk.PolicyType.EXTERNAL}
        >
          <box vertical={true} className={"songText"}>
            <scrollable
              className={"topText"}
              valign={Gtk.Align.START}
              hscroll={Gtk.PolicyType.EXTERNAL}
              vscroll={Gtk.PolicyType.EXTERNAL}
              setup={(self) => {
                timeouts.push(setTimeout(() => {
                  if (self.vadjustment.lower !== 0 || self.vadjustment.upper !== 15) {
                    console.log("vadjustment assumption 1 is wrong.", self.vadjustment.lower, self.vadjustment.upper)
                  }
                  self.vadjustment.value = 2
                }, 200))

                timeouts.push(setInterval(() => {
                  if (self.hadjustment.upper === 100) {
                    return
                  }
                  const before = self.hadjustment.value
                  if (direction) {
                    self.hadjustment.value += 1
                  } else {
                    self.hadjustment.value -= 1
                  }
                  if (self.hadjustment.value === before && lock === false) {
                    lock = true
                    setTimeout(() => { direction = !direction; lock = false }, 1250)
                  }
                }, 120))
              }}
            >

              <eventbox
                setup={
                  (self) => {
                    self.connect("scroll-event", () => { return Gdk.EVENT_STOP })
                  }
                }
              >
                <label
                  halign={Gtk.Align.CENTER}
                  label={bind(player, "title").as(() =>
                    `${player.title !== "" ? player.title : "Nothing Playing"} `
                  )}
                />
              </eventbox>
            </scrollable>
            <scrollable
              className={"bottomText"}
              valign={Gtk.Align.END}
              hscroll={Gtk.PolicyType.NEVER}
              vscroll={Gtk.PolicyType.EXTERNAL}
              setup={(self) => {
                timeouts.push(setTimeout(() => {
                  if (self.vadjustment.lower !== 0 || self.vadjustment.upper !== 9) {
                    console.log("vadjustment assumption 2 is wrong.", self.vadjustment.lower, self.vadjustment.upper)
                  }
                  self.vadjustment.value = 2
                }, 200))
              }}
            >
              <eventbox
                setup={
                  (self) => {
                    self.connect("scroll-event", () => { return Gdk.EVENT_STOP })
                  }
                }
              >
                <centerbox widthRequest={100}
                  startWidget={<label
                    halign={Gtk.Align.START}
                    label={bind(player, "artist").as(() =>
                      `${player.artist}`
                    )}
                    truncate={true}
                  />}
                  endWidget={<box
                    halign={Gtk.Align.END}
                  ><label

                      label={bind(player, "position").as(() =>
                        `${lengthStr(player.position)}`
                      )}
                    />
                    <label
                      halign={Gtk.Align.END}
                      label={bind(player, "length").as(() =>
                        `/${lengthStr(player.length)}`
                      )}
                    /></box>
                  }
                />
              </eventbox>
            </scrollable>
            <box halign={Gtk.Align.CENTER} heightRequest={18}>
              <button
                onClicked={() => player.previous()}
                visible={bind(player, "canGoPrevious")}>
                <icon icon="media-skip-backward-symbolic" />
              </button>
              <button
                css={"padding:0px 3px"}
                onClicked={() => player.play_pause()}
                visible={bind(player, "canControl")}>
                <icon icon={bind(player, "playbackStatus").as(s => (s === Mpris.PlaybackStatus.PLAYING) ? "media-playback-pause-symbolic" : "media-playback-start-symbolic")} />
              </button>
              <button
                onClicked={() => player.next()}
                visible={bind(player, "canGoNext")}>
                <icon icon="media-skip-forward-symbolic" />
              </button>
            </box>
          </box>
        </scrollable>
          </box>
        </eventbox >
        <button
          onClick={() => {
            hyprland.dispatch("focuswindow", playerMaps[player.identity])
          }}
          onScroll={(_, ev) => {
            player.volume += ev.delta_y * -0.02
          }}>
          <box className={"playerLogo"} tooltipText={bind(player, "metadata").as(() =>
            `Player: ${player.identity}\nVolume: ${Math.round(player.volume * 100)}%`)}
          >
            <Icon icon={bind(player, "entry").as(e => {
              if (e === null) {
                return "audio-x-generic-symbolic"
              }
              return (Icon.lookup_icon(e) ? e : "audio-x-generic-symbolic")
            })}
            />
          </box>
        </button>
      </box>
    </box>
  </box>

}

function checkEmptyPlayer(player: Mpris.Player): boolean {
  return (player.title === "" && player.artist === "" && player.position === 0)
}

function MediaPlayerRevealer(player: Mpris.Player): Gtk.Revealer {
  return <revealer
    revealChild={false}
    transitionType={Gtk.RevealerTransitionType.SLIDE_RIGHT}
    transitionDuration={transition_duration}
    setup={(self) => {
      setTimeout(() => { self.revealChild = !checkEmptyPlayer(player) }, 0)
      self.hook(bind(player, "metadata"), () => {
        self.revealChild = !checkEmptyPlayer(player)
      })
    }}
  >
    <MediaPlayer player={player} />
  </revealer> as Gtk.Revealer
}

export default function MediaInfo() {
  const mpris = Mpris.get_default()
  const players = Object.fromEntries(mpris.players.map(p => [p.busName, MediaPlayerRevealer(p)]))

  return <box className={"medias"} css={"background:transparent"} setup={(self) => {
    self.children = [...Object.values(players)]


    mpris.connect("player-added", (_, player) => {
      console.log("added", player.busName)
      const widget = MediaPlayerRevealer(player)
      players[player.busName] = widget
      self.pack_end(widget, true, true, 0)
      self.show_all()
    })

    // This may be triggered more than once per player
    mpris.connect("player-closed", (_, player) => {
      console.log("closed", player.busName)
      const widget = players[player.busName]
      if (widget) {
        widget.revealChild = false
        delete players[player.busName]
        setTimeout(() => {
          widget?.destroy()
        }, transition_duration * 1.2)
      }
    })

  }
  }
  />
}

