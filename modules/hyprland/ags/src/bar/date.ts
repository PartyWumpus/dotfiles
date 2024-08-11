// used like 50mW
//const time = Variable("", {
//  poll: [1000, `date "+%H:%M:<span fgalpha='60%'>%S</span>\n%Y/%m/%d"`],
//});

const time = Variable(new Date())

Utils.interval(1000, () => time.setValue(new Date()))

const pad = (num: number) => {
	return String(num).padStart(2,"0")
}

export const DateComponent = () =>
  Widget.Label({
    css: "font-size:1.2em",
    hpack: "start",
    useMarkup: true,
		//label: time.bind()
    label: time.bind().as(x => `${pad(x.getHours())}:${pad(x.getMinutes())}:<span fgalpha='60%'>${pad(x.getSeconds())}</span>\n${pad(x.getFullYear())}/${pad(x.getMonth()+1)}/${pad(x.getDate())}`),
  });
