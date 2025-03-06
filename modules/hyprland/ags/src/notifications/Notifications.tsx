import { GLib, Variable } from "astal"
import { Gtk, Astal, Gdk } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"

// Largely stolen from AGS examples, thanks https://github.com/tokyob0t
const isIcon = (icon: string) =>
  !!Astal.Icon.lookup_icon(icon)

const fileExists = (path: string) =>
  GLib.file_test(path, GLib.FileTest.EXISTS)

const time = (time: number, format = "%H:%M") => GLib.DateTime
  .new_from_unix_local(time)
  .format(format)!

const urgency = (n: Notifd.Notification) => {
  const { LOW, NORMAL, CRITICAL } = Notifd.Urgency
  // match operator when?
  switch (n.urgency) {
    case LOW: return "low"
    case CRITICAL: return "critical"
    case NORMAL:
    default: return "normal"
  }
}

type Props = {
  notification: Notifd.Notification
  deleteNotif: () => void
}

function Notification(props: Props) {
  const { notification: n, deleteNotif } = props
  const { START, CENTER, END } = Gtk.Align
  const duration = Math.max(Math.min(n.expire_timeout, 10000), 2000) + transition_duration
  let timeout: GLib.Source | undefined = undefined

  return <eventbox
    className={`Notification ${urgency(n)}`}

    onHoverLost={() => {
      deleteNotif()
    }}
    onHover={() => {
      timeout?.destroy()
    }}
    setup={() => {
      timeout = setTimeout(deleteNotif, duration)
    }}
  >
    <box vertical>
      <box className="header">
        {(n.appIcon || n.desktopEntry) && <icon
          className="app-icon"
          visible={Boolean(n.appIcon || n.desktopEntry)}
          icon={n.appIcon || n.desktopEntry}
        />}
        <label
          className="app-name"
          halign={START}
          truncate
          label={n.appName || "Unknown"}
        />
        <label
          className="time"
          hexpand
          halign={END}
          label={time(n.time)}
        />
        <button onClicked={() => n.dismiss()}>
          <icon icon="window-close-symbolic" />
        </button>
      </box>
      <Gtk.Separator visible />
      <box className="content">
        {n.image && fileExists(n.image) && <box
          valign={START}
          className="image"
          css={`background-image: url('${n.image}')`}
        />}
        {n.image && isIcon(n.image) && <box
          expand={false}
          valign={START}
          className="icon-image">
          <icon icon={n.image} expand halign={CENTER} valign={CENTER} />
        </box>}
        <box vertical>
          <label
            className="summary"
            halign={START}
            xalign={0}
            label={n.summary}
            truncate
          />
          {n.body && <label
            className="body"
            wrap
            useMarkup
            halign={START}
            xalign={0}
            justifyFill
            label={n.body}
          />}
        </box>
      </box>
      {n.get_actions().length > 0 && <box className="actions">
        {n.get_actions().map(({ label, id }) => (
          <button
            hexpand
            onClicked={() => n.invoke(id)}>
            <label label={label} halign={CENTER} hexpand />
          </button>
        ))}
      </box>}
    </box>
  </eventbox>
}

const transition_duration = 500

function NotificationRevealer(visible: Variable<boolean>, props: Props) {
  return <revealer
    revealChild={false}
    transition_duration={transition_duration / 2}
    transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
    setup={(self) => {
      setTimeout(() => { self.revealChild = true }, 0)
      self.hook(visible, () => {
        if (visible.get() === false) {
          setTimeout(() => { self.revealChild = false }, transition_duration / 3)
        }
      })
    }}
  >
    <box>
      <box width_request={1} hexpand />
      <revealer
        hexpand={false}
        revealChild={false}
        transition_duration={transition_duration / 2}
        transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
        setup={(self) => {
          setTimeout(() => { self.revealChild = true }, transition_duration / 3)
          self.hook(visible, () => {
            self.revealChild = visible.get()
          })
        }}
        child={Notification(props)}
      />
    </box>
  </revealer>
}


export default function Notifications(gdkmonitor: Gdk.Monitor) {
  const notifd = Notifd.get_default()
  notifd.ignoreTimeout = true
  const notifs: Map<number, [Gtk.Widget, Variable<boolean>]> = new Map()

  return <window
    className="NotificationPopups"
    namespace={"ags-bar"}
    gdkmonitor={gdkmonitor}
    exclusivity={Astal.Exclusivity.EXCLUSIVE}
    anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}>
    <box vertical setup={
      (self) => {
        // Doesn't close the notification, for showing in sidebar (TODO)
        const deleteNotif = (id: number) => {
          const notif = notifs.get(id)
          if (notif) {
            const [widget, visible] = notif
            visible.set(false)
            notifs.delete(id)
            setTimeout(() => widget.destroy(), transition_duration * 1.2)
          }
        }

        const addNotif = (id: number) => {
          const notif = notifd.get_notification(id)!
          const visible = Variable(true)
          const widget = NotificationRevealer(visible, {
            notification: notif,
            deleteNotif: () => deleteNotif(id)
          })

          notifs.get(id)?.[0]?.destroy?.()
          notifs.set(id, [widget, visible])
          self.pack_end(widget, true, true, 0)
          self.show_all()
        }

        notifd.connect("notified", (_, id) => {
          console.log("notif", id)
          addNotif(id)
        })

        notifd.connect("resolved", (_, id) => {
          deleteNotif(id)
        })
      }
    } />
  </window>
}
