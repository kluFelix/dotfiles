// Flags the tmux window when this pane's opencode session goes idle, hits an
// error, or waits for a permission decision.
//
// This is the TUI part on purpose: TUI plugins run in the terminal client, so
// TMUX_PANE is the pane this terminal owns. A server plugin would see the
// shared background service's TMUX_PANE instead, i.e. whichever pane first
// started the service, and would flag the wrong window.
//
// The window flag (@agent-wait) is cleared by tmux.conf's after-select-window
// and pane-focus-in hooks when the window is opened again.

import { execFile } from "node:child_process"
import { Plugin } from "@opencode/plugin/tui"

const TOAST_MS = 5000

const tmux = (...args) =>
  new Promise((resolve) => {
    execFile("tmux", args, () => resolve())
  })

export default Plugin.define({
  id: "tmux.notify",
  setup(ctx) {
    const pane = process.env.TMUX_PANE
    if (!process.env.TMUX || !pane) return

    const location = ctx.location ?? ctx.data.location.default()
    const waiting = new Set()

    // Sessions this terminal owns: its open tabs plus their child sessions.
    // With session tabs off, fall back to this terminal's project.
    const mine = (sessionID) => {
      const root = ctx.data.session.root(sessionID)
      if (ctx.ui.tabs.enabled()) return ctx.ui.tabs.list().some((tab) => tab.sessionID === root)

      const project = ctx.data.project.get(ctx.data.session.get(sessionID)?.projectID)
      if (!project || !location) return false
      return (
        location.directory === project.canonical ||
        location.directory.startsWith(`${project.canonical}/`)
      )
    }

    const setFlag = async (value) => {
      await tmux("set", "-w", "-t", pane, "@agent-wait", value)
      await tmux("refresh-client", "-S")
    }

    const notify = async (sessionID, body) => {
      const alreadyWaiting = waiting.has(sessionID)
      waiting.add(sessionID)
      await setFlag(body)
      if (alreadyWaiting) return
      await tmux("display-message", "-d", String(TOAST_MS), "-t", pane, `OpenCode: ${body}`)
    }

    const clear = async (sessionID) => {
      waiting.delete(sessionID)
      if (waiting.size === 0) await setFlag("")
    }

    const stop = []
    const on = (type, handler) => {
      stop.push(
        ctx.data.on(type, (event) => {
          const sessionID = event?.data?.sessionID
          if (!sessionID) return
          try {
            if (mine(sessionID)) handler(event.data, sessionID)
          } catch (error) {
            console.error(`tmux-notify: ${type} failed`, error)
          }
        }),
      )
    }

    on("session.execution.succeeded", (_data, sessionID) => notify(sessionID, "waiting for input"))
    on("session.idle", (_data, sessionID) => notify(sessionID, "waiting for input"))
    on("session.execution.failed", (_data, sessionID) => notify(sessionID, "session error"))
    on("permission.asked", (data, sessionID) =>
      notify(sessionID, data.action ? `waiting for permission: ${data.action}` : "waiting for permission"),
    )
    on("permission.replied", (_data, sessionID) => clear(sessionID))
    on("session.execution.started", (_data, sessionID) => clear(sessionID))

    return () => stop.forEach((unsubscribe) => unsubscribe())
  },
})
