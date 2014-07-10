# hubot-backlog-summary

A Hubot script for retrieving Backlog project summary.

## Installation

    $ npm install bouzuya/hubot-backlog-summary

or

    $ npm install git://github.com/bouzuya/hubot-backlog-summary.git

or

    $ npm install git://github.com/bouzuya/hubot-backlog-summary.git\#0.1.1

## Usage

    $ # install npm package
    $ npm install bouzuya/hubot-backlog-summary --save

    $ # add "hubot-backlog-summary" to `external-scripts.json`
    $ cat external-scripts.json
    ["hubot-backlog-summary"]

    $ # add configuration to `process.env.*`
    $ export HUBOT_BACKLOG_SUMMARY_SPACE_ID='...'
    $ export HUBOT_BACKLOG_SUMMARY_USERNAME='...'
    $ export HUBOT_BACKLOG_SUMMARY_PASSWORD='...'
    $ export HUBOT_BACKLOG_SUMMARY_USE_HIPCHAT='0'

    $ # start hubot
    $ hubot

[See example (faithcreates/sushi)](https://github.com/faithcreates/sushi)

## License

MIT

## Badges

[![Build Status](https://travis-ci.org/bouzuya/hubot-backlog-summary.svg?branch=master)](https://travis-ci.org/bouzuya/hubot-backlog-summary)
