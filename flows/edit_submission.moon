

import assert_error from require "lapis.application"
import assert_valid from require "lapis.validate"
import trim_filter from require "lapis.util"
import filter_update from require "helpers.model"

import Flow from require "lapis.flow"

class EditSubmissionFlow extends Flow
  validate_params: =>
    assert_valid @params, {
      {"submission",  type: "table"}
    }

    submission_params = @params.submission
    trim_filter submission_params, {
      "title", "description"
    }

    assert_valid submission_params, {
      {"title", exists: true, max_length: 1024}
      {"description", exists: true, max_length: 1024 * 10}
    }

    submission_params

  create_submission: =>
    import Submissions from require "models"
    params = @validate_params!
    params.user_id = @current_user.id

    submission = Submissions\create params
    submit = @streak\submit submission
    submission, submit

