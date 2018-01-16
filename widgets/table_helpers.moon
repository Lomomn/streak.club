
import time_ago_in_words from require "lapis.util"

class TableHelpers
  _extract_table_fields: (object) =>
    return for k, v in pairs object
      continue if type(v) == "table"
      if cls = object.__class
        plural = (k .. "s")\gsub("ss$", "ses")\gsub "ys$", "ies"
        enum = cls[plural]
        if enum and (enum.__class.__name == "Enum")
          k = {k, enum}
      k

  _format_table_value: (object, field) =>
    local enum, custom_val
    opts = {}

    if type(field) == "table"
      {field, enum} = field

    if type(enum) == "function"
      func = enum
      custom_val = -> func object
      enum = nil

    local style

    val = if real_field = type(field) == "string" and field\match "^:(.*)"
      field = real_field
      method = object[field]
      unless method == nil
        assert type(method) == "function", "expected method for #{field}"
        method object
    else
      object[field]

    if enum
      val = "#{enum[val]} (#{val})"

    switch type(val)
      when "boolean"
        opts.style = "color: #{val and "green" or "red"}"
      when "number"
        val = @number_format val
      when "nil"
        unless custom_val
          opts.style = "color: gray; font-style: italic"

    if val and (field\match("_at$") or field\match("_date_utc$")) and not custom_val
      opts.title = val
      custom_val = -> @date_format val

    if val and field == "ip"
      custom_val = ->
        a href: @url_for("admin.ip_address", nil, ip: val), val

    field, custom_val or tostring(val), opts


  field_table: (object, fields, extra_fields) =>
    unless fields
      fields = @_extract_table_fields object

    element "table", class: "nice_table field_table", ->
      for field in *fields
        field, val, opts = @_format_table_value object, field

        tr ->
          td -> strong field
          td opts, val

      extra_fields! if extra_fields


  column_table: (objects, fields) =>
    element "table", class: "nice_table", ->
      thead ->
        tr ->
          for f in *fields
            if type(f) == "table"
              {f, enum} = f

            td f

      for object in *objects
        tr ->
          for field in *fields
            field, val, opts = @_format_table_value object, field
            td opts, val

