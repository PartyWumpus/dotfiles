pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property string date: {
    Qt.formatDateTime(clock.date, "yyyy/MM/dd")
  }
  readonly property string time: {
    Qt.formatDateTime(clock.date, "hh:mm:")
    + "<font color='grey'>"
    + Qt.formatDateTime(clock.date, "ss")
    + "</font>"
  }

  SystemClock {
    id: clock
    // change to .Minutes when on battery saver
    precision: SystemClock.Seconds
  }
}
