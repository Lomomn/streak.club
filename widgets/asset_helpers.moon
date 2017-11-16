config = require("lapis.config").get!

cache_buster = require "cache_buster"

class AssetsHelpers
  asset_url: (src, opts) =>
    unless opts and opts.cache_buster == false
      src = "#{src}?#{cache_buster}"

    "/static/" .. src

  include_js: (...) =>
    script type: "text/javascript", src: @asset_url ...

  include_css: (...) =>
    link rel: "stylesheet", href: @asset_url ...

  include_jquery_ui: =>
    @include_js "lib/jquery-ui/js/jquery-ui.js"
    @include_css "lib/jquery-ui/css/jquery-ui.css"
    @include_css "lib/jquery-ui/css/jquery-ui.structure.css"
    @include_css "lib/jquery-ui/css/jquery-ui.theme.css"

  include_redactor: (lazy=false) =>
    return unless config.enable_redactor
    if lazy
      script {
        class: "redactor_loader"
        type: "lazyscript"
        "data-script": capture -> @include_redactor!
      }
    else
      @include_js "lib/redactor/redactor.js"
      @include_css "lib/redactor/redactor.css"

  include_tagit: =>
    @include_js "lib/tag-it/js/tag-it.js"
    @include_css "lib/tag-it/css/jquery.tagit.css"
