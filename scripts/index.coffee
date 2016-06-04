require('dotenv').config();
_ = require("lodash")
filesize = require('filesize')
firebase = require('./firebase')
CronJob = require('cron').CronJob
moment = require('moment')

module.exports = (robot) ->
  robot.respond /(.*)information?/i, (msg) ->
    msg.send "Firebase backup service!"

  robot.respond /firebase url/i, (msg) ->
    msg.send "#{process.env.FIREBASE_URL}"

  robot.respond /how big is firebase?/i, (msg) ->
    firebase.size (err, bytes) ->
      if err
        msg.send "An error occured"
      else
        size = filesize(bytes)
        msg.send "#{size}"

  robot.respond /backup firebase/i, (msg) ->
    firebase.backup (err, result) ->
      if err
        msg.send "Something went wrong! #{err.message}"
      else
        today = moment(new Date()).format('YYYY-MM-DD')
        size = filesize(result)
        msg.send "#{today}: #{size} of data successfully backed up!"
    return

  robot.respond /backupStorm firebase/i, (msg) ->
    firebase.backupStorm (err, result) ->
      if err
        msg.send "Something went wrong! #{err.message}"
      else
        today = moment(new Date()).format('YYYY-MM-DD')
        size = filesize(result)
        msg.send "#{today}: #{size} of Storm data successfully backed up!"
    return

  # Weekly schedule (10am every day)
  new CronJob('00 30 00 * * *', (->
    firebase.backup (err, result) ->
      if err
        robot.messageRoom "releases", "Something went wrong! #{err.message}"
      else
        today = moment(new Date()).format('YYYY-MM-DD')
        size = filesize(result)
        robot.messageRoom "releases", "#{today}: #{size} of data successfully backed up!"
    return
    firebase.backupStorm (err, result) ->
      if err
        robot.messageRoom "releases", "Something went wrong! #{err.message}"
      else
        today = moment(new Date()).format('YYYY-MM-DD')
        size = filesize(result)
        robot.messageRoom "releases", "#{today}: #{size} of data successfully backed up!"
    return
  ), null, true, 'America/Los_Angeles')
