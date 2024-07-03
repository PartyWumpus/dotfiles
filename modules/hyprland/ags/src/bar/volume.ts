const audio = await Service.import("audio");

import * as COLOR from "../../colours.json";

const VolumeSlider = () =>
  Widget.Slider({
    hexpand: true,
    drawValue: false,
    onChange: ({ value }) => (audio.speaker.volume = value),
    value: audio.speaker.bind("volume"),
  });

const VolumeIndicator = () =>
  Widget.Icon().hook(audio.speaker, (self) => {
    const vol = audio.speaker.volume * 100;
    let icon = [
      [101, "overamplified"],
      [67, "high"],
      [34, "medium"],
      [1, "low"],
      [0, "muted"],
    ].find(([threshold]) => Number(threshold) <= vol)?.[1];
    if (audio.speaker.is_muted) {
      icon = "muted";
    }

    self.icon = `audio-volume-${icon}-symbolic`;
    self.css = "font-size:15px;";
  });

export const VolumeWheel = () =>
  Widget.Button({
    className: "flat",
    css: "box-shadow: none;text-shadow: none;background: none;padding: 0;",
    onClicked: () => (audio.speaker.is_muted = !audio.speaker.is_muted),
    onSecondaryClick: () => Utils.execAsync(nix.audio_changer).catch(print),
    tooltipText: audio.speaker
      .bind("volume")
      .as((vol) => `Volume ${Math.floor(vol * 100)}%`),
    onScrollUp: () => {
      if (audio.speaker.volume < 1) {
        audio.speaker.volume += 0.015;
      }
    },
    onScrollDown: () => (audio.speaker.volume -= 0.015),

    child: Widget.CircularProgress({
      css:
        "min-width: 40px;" + // its size is min(min-height, min-width)
        "min-height: 40px;" +
        "font-size: 6px;" + // to set its thickness set font-size on it
        "margin: 1px;" + // you can set margin on it
        `background-color: ${COLOR.Surface0};` + // set its bg color
        `color: ${COLOR.Highlight};`,
      rounded: false,
      inverted: false,
      startAt: 0.4,
      endAt: 0.105,
      value: audio.speaker.bind("volume"),
      child: VolumeIndicator(),
    }),
  });
