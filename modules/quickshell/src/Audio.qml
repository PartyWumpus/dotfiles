pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property list<PwNode> sinks: {
        Pipewire.nodes.values.filter(n => n.isSink && !n.isStream);
    }

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink
    readonly property PwNode defaultSource: Pipewire.defaultAudioSource

    readonly property bool muted: Boolean(defaultSink?.audio?.muted)
    readonly property real volume: Boolean(defaultSink?.audio?.volume ?? 0)

    function setVolume(newVolume: real): void {
        if (defaultSink?.ready && defaultSink?.audio !== undefined) {
            defaultSink.audio.muted = false;
            defaultSink.audio.volume = Math.max(0, Math.min(1, newVolume));
        }
    }

    function getIcon(node: PwNode): string {
        node?.device?.['icon-name'] ?? '';
    }

    function increaseVolume(amount: real): void {
        setVolume(volume + (amount ?? 5));
    }

    function decreaseVolume(amount: real): void {
        setVolume(volume - (amount ?? 5));
    }

    function setAudioSink(newSink: PwNode): void {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource: PwNode): void {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    PwObjectTracker {
        objects: [...root.sinks]
    }
}
