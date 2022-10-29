defmodule KartVids.Repo.Migrations.AddAdminUser do
  use Ecto.Migration

  alias KartVids.Accounts

  def up do
    {:ok, _user} = Accounts.register_user(%{
      email: System.get_env("ADMIN_EMAIL", "admin@gmail.com"),
      password: System.get_env("ADMIN_PASSWORD", "adminpassword"),
      admin?: true
    })
  end

  def down do

  end
end
