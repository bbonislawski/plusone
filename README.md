# Arkency's PlusOne Slack Bot

This project is quick implementation for plusone bot. It is like giving +1 points on message board.

Example usage:

![example use of plusone bot](http://i.imgur.com/6loapQ5.png)

# Setup

1. Deploy application on publicly available server. E.g. [Heroku](http://heroku.com/)
  1. Remember about setting up database
  2. Run migration: `rake db:migrate`
2. Get URL of your application.
3. Setup `Outgoing WebHooks` on [Slack Integrations page](https://arkency.slack.com/services/new/outgoing-webhook)
  ![Slack's outgoing hook configuration](http://i.imgur.com/osQIqaW.png)
4. Add environmental variable with your Slack API key:
  1. You can generate key here: https://api.slack.com/web
  2. Set environmental variable called `SLACK_API_TOKEN`

# Slack gotcha: Nicknames with `@`

If we specify username nick with mention prefix `@` (e.g. `+1 @voter101`). PlusOne bot will convert that nick to
match name without prefixing `@` character.

Unfortunatelly this operation isn't performed by simple string operation. Slack converts all
nicknames in this format. It uses it's own user format looking like this:

  * `<@USLACKBOT>` - unique ID for Slackbot
  * `<@U029FH1FH>` - ID of some user from our Slack

We can hit hit Slack API to fetch information about user hidden behind given tag. We presume that
user whose name doesn't begin with `<@` is valid nickname and doesn't need hitting Slack API to
decode.

## About

<img src="http://arkency.com/images/arkency.png" alt="Arkency" width="20%" align="left" />

This repository is funded and maintained by Arkency. Check out our other [open-source projects](https://github.com/arkency).

You can [read our blog](http://blog.arkency.com). We write about Rails and JavaScript development.
