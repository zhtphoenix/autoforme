# frozen-string-literal: true

module AutoForme
  # Helper class for formating HTML tables used for the browse/search results pages.
  class Table
    # The AutoForme::Action for the current table
    attr_reader :action

    # The AutoForme::Model for the current table
    attr_reader :model

    # The AutoForme::Request for the current table
    attr_reader :request

    # The action type for the current table
    attr_reader :type

    # The data columns for the current table
    attr_reader :columns

    # An array of objects to show in the table
    attr_reader :objs

    def initialize(action, objs)
      @action = action
      @request = action.request
      @model = action.model
      @type = action.normalized_type
      @columns = model.columns_for(type, request)
      @objs = objs
    end
    
    def h(s)
      action.h(s)
    end

    # Return an HTML string for the table.
    def to_s
      html = String.new
      html << "<table id=\"autoforme_table\" class=\"#{model.table_class_for(type, request)}\">"

      html << "<thead><tr>"
      columns.each do |column|
        html << "<th>#{h action.column_label_for(type, request, model, column)}</th>"
      end
      html << "<th>Show</th>" if show = model.supported_action?(:show, request)
      html << "<th>Edit</th>" if edit = model.supported_action?(:edit, request)
      html << "<th>Delete</th>" if delete = model.supported_action?(:delete, request)
      html << "</tr></thead>"

      html << "<tbody>"
      objs.each do |obj|
        html << "<tr>"
        columns.each do |column|
          unless val = model.show_html_for(obj, column, type, request)
            val = model.column_value(type, request, obj, column)
            val = val.to_s('F') if defined?(BigDecimal) && val.is_a?(BigDecimal)
            val = h(val)
          end
          html << "<td>#{val}</td>"
        end
        html << "<td><a href=\"#{action.url_for("show/#{model.primary_key_value(obj)}")}\" class=\"btn btn-xs btn-info\">Show</a></td>" if show
        html << "<td><a href=\"#{action.url_for("edit/#{model.primary_key_value(obj)}")}\" class=\"btn btn-xs btn-primary\">Edit</a></td>" if edit
        html << "<td><a href=\"#{action.url_for("delete/#{model.primary_key_value(obj)}")}\" class=\"btn btn-xs btn-danger\">Delete</a></td>" if delete
        html << "</tr>"
      end
      html << "</tbody></table>"
      html
    end
  end
end
