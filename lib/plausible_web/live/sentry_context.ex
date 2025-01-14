defmodule PlausibleWeb.Live.SentryContext do
  @moduledoc """
  This module tries to supply LiveViews with some common Sentry context
  (without it, there is practically none).

  Use via `use PlausibleWeb.Live.SentryContext` in your LiveView module,
  or preferably via `use PlausibleWeb, :live_view`.

  In case you have multiple LiveViews, there is `use PlausibleWeb, live_view: :no_sentry_context`
  exposed that allows you to skip using this module. This is because
  only the root LiveView has access to `connect_info` and an exception will be
  thrown otherwise.
  """

  defmacro __using__(_) do
    quote do
      on_mount PlausibleWeb.Live.SentryContext
    end
  end

  def on_mount(:default, _params, session, socket) do
    if Phoenix.LiveView.connected?(socket) do
      peer = Phoenix.LiveView.get_connect_info(socket, :peer_data)
      uri = Phoenix.LiveView.get_connect_info(socket, :uri)

      user_agent =
        Phoenix.LiveView.get_connect_info(socket, :user_agent)

      socket_host =
        case socket.host_uri do
          :not_mounted_at_router -> :not_mounted_at_router
          %URI{host: host} -> host
        end

      request_context =
        %{
          host: socket_host,
          env: %{
            "REMOTE_ADDR" => get_ip(peer),
            "REMOTE_PORT" => peer && peer.port,
            "SEVER_NAME" => uri && uri.host
          }
        }

      request_context =
        if user_agent do
          Map.merge(request_context, %{
            headers: %{
              "User-Agent" => user_agent
            }
          })
        else
          request_context
        end

      Sentry.Context.set_request_context(request_context)

      user_id = session["current_user_id"]

      if user_id do
        Sentry.Context.set_user_context(%{
          id: user_id
        })
      end
    end

    {:cont, socket}
  end

  defp get_ip(%{address: addr}) do
    case :inet.ntoa(addr) do
      {:error, _} -> ""
      address -> to_string(address)
    end
  end

  defp get_ip(_), do: ""
end
