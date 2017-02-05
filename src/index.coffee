# Description:
#  Animate message on slack
#
# Commands:
#  animation sample - Start sample animation
#  animation <animation> - Start animation.
#  animation <#channel> <animation> - Start animation in #channel.
#
# Author:
#  knit
#

SAMPLE = {
  frames: [
    {
      message:":full_moon:",
      duration:1
    },
    {
      message:":waning_gibbous_moon:",
      duration:1
    },
    {
      message:":last_quarter_moon:",
      duration:1
    },
    {
      message:":waning_crescent_moon:",
      duration:1
    },
    {
      message:":new_moon:",
      duration:1
    },
    {
      message:":waxing_crescent_moon:",
      duration:1
    },
    {
      message:":first_quarter_moon:",
      duration:1
    },
    {
      message:":moon:",
      duration:1
    },
    {
      message:":full_moon:",
      duration:1
    }
  ]
}
MIN_UPDATE_INTERVAL = process.env.MIN_UPDATE_INTERVAL
MAX_ANIMATION_LENGTH = process.env.MAX_ANIMATION_LENGTH

module.exports = (robot) ->

  postMessage = (channelId, message) -> new Promise (resolve, reject) ->
    option = {as_user: true}
    robot.adapter.client.web.chat.postMessage channelId, message, option, (err, res) ->
      if res.ok then resolve(res) else reject(res)

  updateMessage = (ts, channelId, message) -> new Promise (resolve, reject) ->
    robot.adapter.client.web.chat.update ts, channelId, message, (err, res) ->
      if res.ok then resolve(res) else reject(res)

  updateFrame = (ts, channelId, frame) ->
    ->
      new Promise((resolve, reject) ->
        setTimeout (->
          updateMessage(ts, channelId, frame.message)
          .then (res) ->
            resolve res
            return
        ), if MIN_UPDATE_INTERVAL > frame.duration then MIN_UPDATE_INTERVAL * 1000 else frame.duration * 1000
        return
      )

  startAnimation = (from, to, animation) ->
    postMessage(to, animation.frames[0].message)
    .then (res) ->
      ts = res.ts
      tasks = []
      for f in animation.frames
        tasks.push updateFrame(ts, to, f)
      tasks.shift()
      tasks.reduce ((a, b) ->
        a.then b
      ), Promise.resolve()
    .catch (err) ->
      postMessage(from, "ERROR!:sob: " + err.error)

  post = (from, to, param) ->
    if param is "sample"
      startAnimation(from, to, SAMPLE)
    else
      anim = JSON.parse(param)
      cnt = 0
      for f in anim.frames
        cnt += f.duration
        if cnt >= MAX_ANIMATION_LENGTH
          return
      startAnimation(from, to, anim)


  robot.hear /animation (#.*) `?(sample|{.*})`?/, (res) ->
    channelId = robot.adapter.client.rtm.dataStore.getChannelOrGroupByName(res.match[1]).id
    param = res.match[2]
    post(res.envelope.room, channelId, param)


  robot.hear /animation `?(sample|{.*})`?/, (res) ->
    channelId = res.envelope.room
    param = res.match[1]
    post(channelId, channelId, param)
