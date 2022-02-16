defmodule HelloWorldWeb.ErrorView do
  use HelloWorldWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  def render("404.json", _assigns) do
    %{message: "Not Found"}
  end

  def render("500.json", _assigns) do
    %{message: "Internal Server Error"}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{message: Phoenix.Controller.status_message_from_template(template)}
  end
end
