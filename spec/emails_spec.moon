import use_test_server from require "lapis.spec"
import request from require "lapis.spec.server"
import truncate_tables from require "lapis.spec.db"

import stub_email, assert_email_sent, assert_emails_sent from require "spec.helpers.email"
import Streaks, StreakUsers, StreakSubmissions, Submissions, Users from require "models"

factory = require "spec.factory"

describe "emails", ->
  use_test_server!
  last_email, req = stub_email!

  before_each ->
    truncate_tables Streaks, StreakUsers, StreakSubmissions, Submissions, Users

  it "sends password reset email", ->
    user = factory.Users!
    reset_url = "http://leafo.net"

    mailer = require "emails.password_reset"
    mailer\send req, user.email, { :reset_url, :user }

    recipient, subject, body, opts = unpack last_email!
    assert.same recipient, user.email

  it "sends reminder email", ->
    -- TODO: this should be moved into a flow so we don't have to duplicate
    -- logic from admin action

    users = {
      factory.Users!
    }

    template = require "emails.reminder_email"
    t = template {
      email_body: "<p>Here is your custom reminder email</p>"
      email_subject: "A test reminder email"
      show_tag_unsubscribe: true
    }

    t\include_helper @

    import send_email from require "helpers.email"
    send_email [u.email for u in *users], t\subject!, t\render_to_string!, {
      html: true
      sender: "Streak Club <postmaster@streak.club>"
      tags: { "reminder_email" }
      vars: { u.email, { name_for_display: u\name_for_display! } for u in *users }
      track_opens: true
      headers: {
        "Reply-To": require("lapis.config").get!.admin_email
      }
    }

    recipient, subject, body, opts = unpack last_email!
    assert.same recipient, {users[1].email}
    assert.same opts.vars, {
      [users[1].email]: { name_for_display: users[1]\name_for_display! }
    }

