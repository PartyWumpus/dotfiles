
const time = Variable(new Date(), {
  poll: [
    1000,
    () => {
      return new Date()
    }
  ]
})

const pad = (num: number) => {
  return String(num).padStart(2, "0")
}

export const DateComponent = () =>
  Widget.Label({
    css: "font-size:1.2em",
    hpack: "start",
    useMarkup: true,
    label: time.bind().as(x => `${pad(x.getHours())}:${pad(x.getMinutes())}:<span fgalpha='60%'>${pad(x.getSeconds())}</span>\n${pad(x.getFullYear())}/${pad(x.getMonth() + 1)}/${pad(x.getDate())}`),
    tooltipText: time.bind().as(x => x.toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "long",
      year: "numeric",
      weekday: "long",
    }))
  });
