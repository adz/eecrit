defmodule Eecrit.AggregateViewWidgets do
  use Eecrit.Web, :view
  import Eecrit.Router.Helpers
  use Eecrit.TagHelpers
  alias Eecrit.TagHelpers, as: T   # TODO: this is a kludge to avoid conflicts

  def report_links(conn) do
    [
      link("Animal use", to: report_path(conn, :animal_use)),
    ]
  end

  defp dropdown_button(title, button_size \\ "btn_xs") do
    button_attrs = [type: "button",
                    class: "btn btn-default #{button_size} dropdown-toggle",
                    data_toggle: "dropdown",
                    aria_haspopup: "true",
                    aria_expanded: "false"]

    [title, " ", symbol_span("caret")]
    |> T.button(button_attrs)
  end

  def dropdown_launcher(conn, title, links, button_size \\ "btn-xs") do
    # For whatever reason, a dropdown button list requires a menu and a button.
    build_if can?(conn.assigns.current_user, :work_with, :reports) do 
      button_part = dropdown_button(title, button_size)
      menu_part = links |> Enum.map(&li/1) |> T.ul(class: "dropdown-menu")
      T.div([button_part, menu_part], class: "btn-group")
    end
  end

  def reports_launcher(conn, params \\ []) do
    dropdown_launcher(conn, "Reports", report_links(conn), params)
  end
end
