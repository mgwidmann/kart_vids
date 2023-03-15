defmodule KartVidsWeb.Router do
  alias KartVidsWeb.Layouts
  use KartVidsWeb, :router

  import KartVidsWeb.UserAuth
  import Phoenix.LiveDashboard.Router
  import Flames.Router

  pipeline :browser do
    plug(:redirect_old_host)
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {KartVidsWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :admin do
    plug(:restrict_admin)
  end

  # Publicly available routes

  scope "/", KartVidsWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
  end

  # Other scopes may use custom stacks.
  # scope "/api", KartVidsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:kart_vids, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).

    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  # Redirect authenticated

  scope "/", KartVidsWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{KartVidsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  # Auth routes

  scope "/", KartVidsWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{KartVidsWeb.UserAuth, :ensure_authenticated}] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)

      live("/videos", VideoLive.Index, :index)
      live("/videos/new", VideoLive.Index, :new)
      live("/videos/:id/edit", VideoLive.Index, :edit)

      live("/videos/:id", VideoLive.Show, :show)
      live("/videos/:id/show/edit", VideoLive.Show, :edit)
    end
  end

  # Admin restricted routes

  scope "/admin", KartVidsWeb do
    pipe_through([:browser, :require_authenticated_user, :admin])

    live_dashboard("/dashboard", metrics: KartVidsWeb.Telemetry)

    flames("/errors")

    live_session :require_authenticated_user_admin,
      on_mount: [{KartVidsWeb.UserAuth, :ensure_authenticated_admin}] do
      # Locations
      live("/locations/new", LocationLive.Index, :new)
    end

    live_session :require_authenticated_user_admin_racing, on_mount: [{KartVidsWeb.UserAuth, :ensure_authenticated_admin}, {KartVidsWeb.Content, :location_id}], layout: {Layouts, :racing} do
      # Locations
      live("/locations/:location_id/edit", LocationLive.Index, :edit)
      live("/locations/:location_id/show/edit", LocationLive.Show, :edit)

      # Karts
      live("/locations/:location_id/karts/new", KartLive.Index, :new)
      live("/locations/:location_id/karts/:id/edit", KartLive.Index, :edit)
      live("/locations/:location_id/karts/:id/show/edit", KartLive.Show, :edit)

      # Races
      live("/locations/:location_id/races/new", RaceLive.Index, :new)
      live("/locations/:location_id/races/:id/edit", RaceLive.Index, :edit)
      live("/locations/:location_id/races/:id/show/edit", RaceLive.Show, :edit)

      # Racer
      live("/locations/:location_id/races/:race_id/racers/new", RacerLive.Index, :new)
      live("/locations/:location_id/races/:race_id/racers/:id/edit", RacerLive.Index, :edit)
    end
  end

  # Public routes which load the user if available

  scope "/", KartVidsWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{KartVidsWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)

      # Locations
      live("/locations", LocationLive.Index, :index)
    end

    live_session :current_user_racing, on_mount: [{KartVidsWeb.UserAuth, :mount_current_user}, {KartVidsWeb.Content, :location_id}], layout: {Layouts, :racing} do
      # Locaitons
      live("/locations/:location_id/racing", LocationLive.Racing, :racing)
      live("/locations/:location_id", LocationLive.Show, :show)

      # Karts
      live("/locations/:location_id/karts", KartLive.Index, :index)
      live("/locations/:location_id/karts/by_number/:kart_number", KartLive.Show, :show)
      live("/locations/:location_id/karts/:id", KartLive.Show, :show)

      # Races
      live("/locations/:location_id/leagues", RaceLive.Leagues, :index)
      live("/locations/:location_id/leagues/:date", RaceLive.League, :show)
      live("/locations/:location_id/races", RaceLive.Index, :index)
      live("/locations/:location_id/races/:id", RaceLive.Show, :show)

      # Racer
      live("/locations/:location_id/races/:race_id/racers", RacerLive.Index, :index)
      live("/locations/:location_id/racers/by_external/:external_racer_id", RacerLive.ShowDup, :show)
      live("/locations/:location_id/racers/by_nickname/:nickname", RacerLive.ShowDup, :show)
      live("/locations/:location_id/racers/:racer_profile_id", RacerLive.Show, :show)
    end
  end

  def redirect_old_host(conn, []) do
    if String.contains?(conn.host, "fly.dev") do
      conn
      |> put_status(:found)
      |> put_resp_header("location", "https://www.kart-vids.com")
    else
      conn
    end
  end

  def restrict_admin(conn, []) do
    if conn.assigns[:current_user] && conn.assigns.current_user.admin? do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> Phoenix.Controller.put_view(KartVidsWeb.ErrorView)
      |> Phoenix.Controller.render("404.html")
      |> halt
    end
  end
end
