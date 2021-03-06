
class Categories extends require "community.models.categories"
  @get_relation_model: (name) =>
    require("models")[name] or @__parent\get_relation_model name

  @relations: {
    {"streak", has_one: "Streaks", key: "community_category_id"}
  }

  edit_options: =>
    {}

  url_params: =>
    streak = @get_streak!
    "community.streak", id: @streak.id, slug: @streak\slug!

  allowed_to_view: (user, ...) =>
    streak = @get_streak!

    unless @streak\allowed_to_view(user) and @streak\has_community!
      return false

    super user, ...

  name_for_display: =>
    return @title if @title
    streak = @get_streak!
    if streak
      @streak.title .. " discussion"
    else
      "unnamed community"




