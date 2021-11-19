defmodule HelloWorldWeb.ErrorView do
  use HelloWorldWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  def render("401.json", %{error: :missing_token}) do
    %{message: "Requires authentication"}
  end

  def render("401.json", %{error: :invalid_token}) do
    %{message: "Bad credentials"}
  end

  def render("401.json", %{error: :invalid_request}) do
    %{
      error: "invalid_request",
      error_description:
        "Authorization header value must follow this format: Bearer access-token",
      message: "Bad credentials"
    }
  end

  def render("401.json", _assigns) do
    %{
      error: "invalid_token",
      error_description: "Unable to validate token",
      message: "Bad credentials"
    }
  end

  def render("403.json", _assigns) do
    %{
      error: "insufficient_permissions",
      error_description: "Insufficient claim for the token",
      message: "Permission denied"
    }
  end

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
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
