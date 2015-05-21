
SubmissionList = require "widgets.submission_list"
HomeHeader = require "widgets.home_header"

class FollowingFeed extends require "widgets.base"
  @needs: {"submission"}

  js_init: =>
    "S.FollowingFeed(#{@widget_selector!});"

  inner_content: =>
    widget HomeHeader page_name: "following_feed"

    h3 "Submissions from everyone you follow"

    if next @submissions
      widget SubmissionList
    else
      p class: "empty_message", ->
        if @current_user.following_count == 0
          text "You're not following anyone yet"
        else
          text "None of the people you follow have posted yet"

