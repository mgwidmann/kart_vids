defmodule KartVids.Helpers do
  defmacro admin_only(current_user, do: block) do
    quote do
      if unquote(current_user) && unquote(current_user).admin? do
        unquote(block)
      else
        raise "Only admin allowed function!"
      end
    end
  end
end
