# Description
#   backlog-summary
#
# Dependencies:
#   "async": "0.7.0"
#   "backlog-api": "1.0.2"
#
# Configuration:
#   HUBOT_BACKLOG_SUMMARY_SPACE_ID
#   HUBOT_BACKLOG_SUMMARY_USERNAME
#   HUBOT_BACKLOG_SUMMARY_PASSWORD
#   HUBOT_BACKLOG_SUMMARY_USE_HIPCHAT
#
# Commands:
#   hubot backlog-summary <project> - display Backlog project summary
#
# Author:
#   bouzuya <m@bouzuya.net>
#
{format} = require 'util'

maxWidth = (ss) -> ss.reduce ((max, s) -> Math.max(max, s.length)), 0

pad = (o, n, d) ->
  s = o.toString()
  padding = ''
  padding += ' ' for i in [0..(n - s.length)]
  (if d is 'l' then padding else '') + s + (if d is 'r' then padding else '')

lpad = (o, n) -> pad(o, n, 'l')
rpad = (o, n) -> pad(o, n, 'r')

formatLine = (name, issues, display) ->
  closed = issues.filter (i) -> i.status.id is 4

  # count
  allCount = issues.length
  closedCount = closed.length
  return '' if !display and allCount is closedCount
  return '' if display and allCount is 0

  # estimated hours
  allEstimatedHours = issues.reduce (hours, i) ->
    hours + (i.estimated_hours ? 0)
  , 0
  closedEstimatedHours = closed.reduce (hours, i) ->
    hours + (i.estimated_hours ? 0)
  , 0

  # actual hours
  allActualHours = issues.reduce (hours, i) ->
    hours + (i.actual_hours ? 0)
  , 0

  format(
    ' %s: %s/%s (%sh/%sh,%sh)\n',
    name,
    lpad(closedCount, 4),
    lpad(allCount, 4),
    lpad(closedEstimatedHours, 4),
    lpad(allEstimatedHours, 4),
    lpad(allActualHours, 4)
  )

formatMilestone = (milestone, users, issues) ->
  width = maxWidth(users.map((u) -> u.name))

  first = milestone.name + ':\n'
  second = formatLine(rpad('All', width), issues)
  return '' if second.length is 0
  userLines = users.map (user) ->
    formatLine(
      rpad(user.name, width),
      issues.filter (i) -> i.assigner and i.assigner.id is user.id,
      true
    )
  first + second + userLines.join('')

module.exports = (robot) ->
  async = require 'async'
  backlogApi = require 'backlog-api'

  robot.respond /backlog-summary\s+([_a-zA-Z0-9]+)\s*$/i, (res) ->
    projectKey = res.match[1].toUpperCase()

    res.send('OK. Now loading...')

    backlog = backlogApi(
      process.env.HUBOT_BACKLOG_SUMMARY_SPACE_ID,
      process.env.HUBOT_BACKLOG_SUMMARY_USERNAME,
      process.env.HUBOT_BACKLOG_SUMMARY_PASSWORD
    )

    project = null
    users = null
    milestones = null
    backlog.getProject projectKey: projectKey
    .then (p) ->
      project = p
      backlog.getUsers projectId: project.id
    .then (us) ->
      users = us
      backlog.getVersions projectId: project.id
    .then (ms) ->
      milestones = ms.sort((a, b) -> a.date < b.date)
      async.mapSeries milestones
      , (milestone, next) ->
        backlog.findIssue
          projectId: project.id,
          milestoneId: milestone.id,
        , (err, issues) ->
          next err, formatMilestone(milestone, users, issues)
      , (err, messages) ->
        if err
          res.send('error!')
        else
          isHipChat = process.env.HUBOT_BACKLOG_SUMMARY_USE_HIPCHAT?
          res.send [
            if isHipChat then '/quote ' else ''
            [
              'backlog-summary ' + projectKey + ' result:'
              'milestone:'
              ' All: closed/all (estimated closed/all, actual)'
              messages.join('')
            ].join('\n')
          ].join('')
    , (e) ->
      robot.logger.error(e)
