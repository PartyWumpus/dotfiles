import { Gtk } from "astal/gtk3"
import { Variable } from "astal"

type PlainDate = {
  time: {
    hrs: string
    mins: string
    secs: string
  }
  date: {
    year: string
    month: string
    day: string
  }
  datestring: string
}

const pad = (num: number) => {
  return String(num).padStart(2, "0")
}

function dateToPlain(): PlainDate {
  const date = new Date()
  return {
    time: {
      hrs: pad(date.getHours()),
      mins: pad(date.getMinutes()),
      secs: pad(date.getSeconds())
    },

    date: {
      day: pad(date.getDate()),
      month: pad(date.getMonth()+1),
      year: pad(date.getFullYear())
    },

    datestring: date.toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "long",
      year: "numeric",
      weekday: "long",
    })
  }
}

const time = Variable<PlainDate>(dateToPlain()).poll(1000, () => {
  return dateToPlain()
})

export default function Time() {
  return <label
    css="padding-right:3px;"
    useMarkup={true}
    justify={Gtk.Justification.CENTER}
    label={time(t => `${t.time.hrs}:${t.time.mins}:<span fgalpha='60%'>${t.time.secs}</span> | ${t.date.year}/${t.date.month}/${t.date.day}`)}
    tooltipText={time(t => t.datestring)}
  />
}
