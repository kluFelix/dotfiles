const hasTmux = Boolean(process.env.TMUX) && Boolean(process.env.TMUX_PANE)
const TOAST_MS = 5000

export const TmuxNotify = async ({ $ }) => {
  if (!hasTmux) return {}
  const pane = process.env.TMUX_PANE
  let sessionID = null

  const setFlag = async (value) => {
    await $`tmux set -w -t ${pane} @agent-wait ${value}`.nothrow().quiet()
    await $`tmux refresh-client -S`.nothrow().quiet()
  }

  const notify = async (body) => {
    await setFlag(body)
    await $`tmux display-message -d ${TOAST_MS} ${`OpenCode: ${body}`}`.nothrow().quiet()
  }

  return {
    "chat.message": async (input) => {
      sessionID = input.sessionID
      await setFlag("")
    },

    event: async ({ event }) => {
      const props = event.properties
      const mine = props?.sessionID === sessionID

      if (event.type === "session.status") {
        if (mine && props.status?.type === "busy") await setFlag("")
        return
      }
      if (event.type === "session.error") {
        if (props?.sessionID === undefined || mine) await notify("session error")
        return
      }

      let body = null
      if (event.type === "session.idle" && mine) {
        body = "waiting for input"
      } else if (event.type === "permission.updated" && mine) {
        body = "waiting for permission"
      }
      if (!body) return

      await notify(body)
    },
  }
}
