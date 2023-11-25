defmodule KartVidsWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import KartVidsWeb.Gettext
  use KartVidsWeb, :verified_routes

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false)
  attr(:on_cancel, JS, default: %JS{})
  attr(:on_confirm, JS, default: %JS{})

  slot(:inner_block, required: true)
  slot(:title)
  slot(:subtitle)
  slot(:confirm)
  slot(:cancel)

  def modal(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_modal(@id)} class="relative z-50 hidden">
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-zinc-50/90 transition-opacity" aria-hidden="true" />
      <div class="fixed inset-0 overflow-y-auto" aria-labelledby={"#{@id}-title"} aria-describedby={"#{@id}-description"} role="dialog" aria-modal="true" tabindex="0">
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="hidden relative rounded-2xl bg-white p-14 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition"
            >
              <div class="absolute top-6 right-5">
                <button phx-click={hide_modal(@on_cancel, @id)} type="button" class="-m-3 flex-none p-3 opacity-20 hover:opacity-40" aria-label={gettext("close")}>
                  <Heroicons.x_mark solid class="h-5 w-5 stroke-current" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <header :if={@title != []}>
                  <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-zinc-800">
                    <%= render_slot(@title) %>
                  </h1>
                  <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
                    <%= render_slot(@subtitle) %>
                  </p>
                </header>
                <%= render_slot(@inner_block) %>
                <div :if={@confirm != [] or @cancel != []} class="ml-6 mb-4 flex items-center gap-5">
                  <.button :for={confirm <- @confirm} id={"#{@id}-confirm"} phx-click={@on_confirm} phx-disable-with class="py-2 px-3">
                    <%= render_slot(confirm) %>
                  </.button>
                  <.link :for={cancel <- @cancel} phx-click={hide_modal(@on_cancel, @id)} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
                    <%= render_slot(cancel) %>
                  </.link>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr(:id, :string, default: "flash", doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount")
  attr(:close, :boolean, default: true, doc: "whether the flash can be closed")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show_expand("##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide_contract("#flash")}
      role="alert"
      class={[
        "fixed hidden top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 shadow-md shadow-zinc-900/5 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 p-3 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-[0.8125rem] font-semibold leading-6">
        <Heroicons.information_circle :if={@kind == :info} mini class="h-4 w-4" />
        <Heroicons.exclamation_circle :if={@kind == :error} mini class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-[0.8125rem] leading-5"><%= msg %></p>
      <button :if={@close} type="button" class="group absolute top-2 right-1 p-2" aria-label={gettext("close")}>
        <Heroicons.x_mark solid class="h-5 w-5 stroke-current opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form :let={f} for={%{}} as={:user} phx-change="validate" phx-submit="save">
        <.input field={{f, :email}} label="Email"/>
        <.input field={{f, :username}} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr(:for, :any, default: nil, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")
  attr(:class, :string, default: nil)

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class={@class || "space-y-8 bg-white mt-10"}>
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-sky-600 hover:bg-sky-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80 whitespace-nowrap",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr(:type, :atom, default: :brand)
  attr(:class, :string, default: "")
  slot(:inner_block, required: true)

  def pill(assigns) do
    type =
      cond do
        :brand == assigns[:type] || assigns[:type] == nil -> "bg-brand/20"
        :success == assigns[:type] -> "bg-emerald-500"
        :warning == assigns[:type] -> "bg-yellow-300"
        :danger == assigns[:type] -> "bg-rose-400"
        true -> nil
      end

    assigns = Map.put(assigns, :type, type)

    ~H"""
    <small class={["ml-3 rounded-full px-2 text-[0.8125rem] font-medium leading-6", @type, @class]}>
      <%= render_slot(@inner_block) %>
    </small>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={{f, :email}} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr(:id, :any)
  attr(:name, :any)
  attr(:label, :string, default: nil)

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)
  )

  attr(:value, :any)
  attr(:field, :any, doc: "a %Phoenix.HTML.Form{}/field name tuple, for example: {f, :email}")
  attr(:errors, :list)
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:rest, :global, include: ~w(autocomplete disabled form max maxlength min minlength
                                   multiple pattern placeholder readonly required size step))
  slot(:inner_block)

  def input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn -> Phoenix.HTML.Form.input_name(f, field) end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn -> translate_errors(f.errors || [], field) end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> input_equals?(assigns.value, "true") end)

    ~H"""
    <label phx-feedback-for={@name} class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
      <input type="hidden" name={@name} value="false" />
      <input type="checkbox" id={@id || @name} name={@name} value="true" checked={@checked} class="rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900" {@rest} />
      <%= @label %>
    </label>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select id={@id} name={@name} class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 sm:text-sm" {@rest}>
        <option :if={@prompt}><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id || @name}
        name={@name}
        class={[
          input_border(@errors),
          "mt-2 block min-h-[6rem] w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      >

    <%= @value %></textarea>
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input
      type={@type}
      name={@name}
      id={@id || @name}
      value={@value}
      class={[
        input_border(@errors),
        "mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
        "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
        "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
      ]}
      {@rest}
    />
    """
  end

  def input(%{type: "datetime-local"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={(@value && !is_binary(@value) && Calendar.strftime(@value, "%Y-%m-%dT%H:%M")) || (is_binary(@value) && @value)}
        class={[
          input_border(@errors),
          "mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={[
          input_border(@errors),
          "mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors} message={msg} />
    </div>
    """
  end

  # @doc """
  # Regular select element which does not require a form element.
  # """

  # attr :prompt, :string, default: nil
  # attr :options, :list, required: true
  # attr :value, :string, required: true
  # attr :class, :string, default: nil
  # attr :rest, :global

  # def select(assigns) do
  #   ~H"""
  #   <select class={["mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 sm:text-sm", @class]} {@rest}>
  #     <option :if={@prompt}><%= @prompt %></option>
  #     <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
  #   </select>
  #   """
  # end

  defp input_border([] = _errors),
    do: "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5"

  defp input_border([_ | _] = _errors),
    do: "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"

  @doc """
  Renders a label.
  """
  attr(:for, :string, default: nil)
  slot(:inner_block, required: true)

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  attr(:message, :string, required: true)

  def error(assigns) do
    ~H"""
    <p class="phx-no-feedback:hidden mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <Heroicons.exclamation_circle mini class="mt-0.5 h-5 w-5 flex-none fill-rose-500" />
      <%= @message %>
    </p>
    """
  end

  attr(:timestamp, :map, required: true)
  attr(:timezone, :string, required: true)
  attr(:date, :boolean)
  attr(:date_with_year, :boolean)
  attr(:time, :boolean)
  attr(:rest, :global)

  def display_timestamp(assigns) do
    [rest: rest] = assigns_to_attributes(assigns, [:timestamp, :timezone, :date, :date_with_year, :time])
    assigns = assigns |> assign(:rest, rest)

    format =
      cond do
        assigns[:date] -> "%A %B %-d"
        assigns[:date_with_year] -> "%A %B %-d %Y"
        assigns[:time] -> "%I:%M %p %Z"
        true -> "%a %b %d, %Y %I:%M %p %Z"
      end

    assigns = assign(assigns, format: format)

    ~H"""
    <span {@rest}>
      <%= Timex.Timezone.convert(@timestamp, @timezone) |> Calendar.strftime(@format) %>
    </span>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr(:class, :string, default: nil)

  slot(:inner_block, required: true)
  slot(:subtitle)
  slot(:subheader)
  slot(:actions)

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="grid grid-cols-4 w-full">
        <div class="col-span-3">
          <%= render_slot(@subheader) %>
        </div>
        <div class="flex justify-end">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr(:id, :string, required: true)
  attr(:class, :string, default: "mt-11 w-full")
  attr(:container_class, :string, default: "")
  attr(:row_click, JS, default: nil)
  attr(:rows, :list, required: true)
  attr(:row_add, :any, default: nil)
  attr(:row_remove, :any, default: nil)
  attr(:y_padding, :string, default: "py-2")

  slot :col, required: true do
    attr(:class, :string)
    attr(:row_class, :string)
    attr(:label, :string)
    attr(:label_mobile, :string)
    attr(:inner_div_class, :string)
  end

  slot(:action, doc: "the slot for showing user actions in the last table column")

  def table(assigns) do
    ~H"""
    <div id={@id} class={["overflow-y-auto sm:overflow-visible px-0", @container_class]}>
      <table class={@class}>
        <thead class="text-left text-[0.8125rem] leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class={["p-0 pb-4 sm:px-3 font-normal", col[:class]]}>
              <span class="hidden sm:inline"><%= col[:label] %></span>
              <span class="sm:hidden inline"><%= col[:label_mobile] || col[:label] %></span>
            </th>
            <th class="relative p-0 pb-4"><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700">
          <tr :for={row <- @rows} id={"#{@id}-#{Phoenix.Param.to_param(row)}"} class="group hover:bg-zinc-50" phx-mounted={is_function(@row_add, 1) && @row_add.(row)} phx-remove={is_function(@row_remove, 1) && @row_remove.(row)}>
            <td :for={{col, i} <- Enum.with_index(@col)} phx-click={@row_click && @row_click.(row)} class={["relative p-0", @row_click && "hover:cursor-pointer", if(is_function(col[:row_class]), do: col[:row_class].(row), else: col[:row_class])]}>
              <div class={["block #{@y_padding} sm:px-3 overflow-auto h-full", col[:inner_div_class]]}>
                <span class="absolute right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <div class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, row) %>
                </div>
              </div>
            </td>
            <td :if={@action != []} class="relative p-0 w-14">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span :for={action <- @action} class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
                  <%= render_slot(action, row) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  attr(:size, :atom, default: :large, values: ~w(small large)a)
  attr(:photo, :string)
  attr(:rounded, :atom, default: :none, values: ~w(none lg full)a)
  attr(:square, :boolean, default: false)
  attr(:class, :string, default: nil)

  def racer_photo(assigns) do
    size = Map.get(assigns, :size, :large)
    shape_class = if(assigns[:square], do: "h-full w-[80px] md:h-[100px] md:w-[100px]", else: "h-full w-[80px] md:h-[100px] md:w-[160px]")
    assigns = assign(assigns, shape_class: shape_class)

    case size do
      :large ->
        ~H"""
        <img src={@photo} class={["object-cover", @shape_class, "rounded-#{@rounded}", @class]} />
        """

      :small ->
        ~H"""
        <img src={@photo} class={["h-full w-[80px] object-cover", "rounded-#{@rounded}", @class]} />
        """
    end
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%= item.title %></dt>
          <dd class="text-sm leading-6 text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  attr :default_active, :string

  slot :tab, required: true do
    attr :name, :string, required: true
    attr :title, :string, required: true
  end

  # <th :for={col <- @col}

  def tabs(assigns) do
    assigns = assign(assigns, :default_active, assigns[:default_active] || List.first(assigns[:tab]).name)

    ~H"""
    <ul class="mb-5 flex list-none flex-col flex-wrap border-b-1 border-grey-400 pl-0 md:flex-row" role="tablist">
      <li :for={tab <- @tab} role="presentation">
        <a
          id={tab.name}
          phx-click={tabs_show_hide(tab, @tab)}
          class={[
            "cursor-pointer my-2 block border-x-0 border-t-0 border-b-2 px-7 pt-4 pb-3.5 text-xs font-medium uppercase leading-tight text-neutral-500 hover:isolate hover:bg-neutral-100 focus:isolate text-primary",
            if(@default_active == tab.name, do: "border-sky-400", else: "")
          ]}
        >
          <%= tab.title %>
        </a>
      </li>
    </ul>
    <div class="mb-6">
      <div :for={tab <- @tab} class={["opacity-0 opacity-100 transition-opacity", if(@default_active != tab.name, do: "hidden", else: "")]} id={"#{tab.name}-tab"} role="tabpanel">
        <%= render_slot(tab) %>
      </div>
    </div>
    """
  end

  defp tabs_show_hide(tab, tabs) do
    commands =
      for t <- tabs, t.name != tab.name, reduce: JS.show(to: "##{tab.name}-tab") do
        js -> JS.hide(js, to: "##{t.name}-tab")
      end

    for t <- tabs, t.name != tab.name, reduce: JS.add_class(commands, "border-sky-400", to: "##{tab.name}") do
      js -> JS.remove_class(js, "border-sky-400", to: "##{t.name}")
    end
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr(:navigate, :any, required: true)
  attr(:position, :atom, default: :bottom)
  slot(:inner_block, required: true)

  def back(assigns) do
    ~H"""
    <div class={if(@position == :top, do: "", else: "mt-16")}>
      <.link navigate={@navigate} class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700">
        <Heroicons.arrow_left solid class="w-3 h-3 stroke-current inline" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a button navigation link.

  ## Examples

      <.button_link navigate={~p"/posts"}>Button Text</.button_link>
  """
  attr(:navigate, :any, required: true)
  slot(:inner_block, required: true)

  def button_link(assigns) do
    ~H"""
    <.link navigate={@navigate} class="rounded-lg bg-sky-600 hover:bg-sky-700 py-2 px-3 text-sm font-semibold leading-6 text-white active:text-white/80">
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  @doc """
  Renders an admin navigation link.

  ## Examples

      <.admin_link navigate={~p"/admin/posts"}>Button Text</.admin_link>
  """
  attr(:navigate, :any)
  attr(:patch, :any)
  attr(:current_user, :any, required: true)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def admin_link(assigns) do
    rest = assigns_to_attributes(assigns, [:current_user, :inner_block])
    assigns = assigns |> assign(:rest, rest)

    ~H"""
    <%= if @current_user && @current_user.admin? do %>
      <.link {@rest}>
        <%= render_slot(@inner_block) %>
      </.link>
    <% end %>
    """
  end

  @doc """
  Renders a user navigation link.

  ## Examples

      <.user_link navigate={~p"/admin/posts"}>Button Text</.link_link>
  """
  attr(:navigate, :any)
  attr(:patch, :any)
  attr(:current_user, :any, required: true)
  slot(:inner_block, required: true)
  attr(:rest, :global)

  def user_link(assigns) do
    rest = assigns_to_attributes(assigns, [:current_user, :inner_block])
    assigns = assigns |> assign(:rest, rest)

    ~H"""
    <%= if @current_user do %>
      <.link {@rest}>
        <%= render_slot(@inner_block) %>
      </.link>
    <% end %>
    """
  end

  defmacro admin_redirect(socket, blocks) do
    blocks = Keyword.put(blocks, :else, blocks[:else] || quote(do: socket))

    unless blocks[:do] do
      raise "admin_redirect must pass do block, only else block is optional"
    end

    quote do
      if unquote(socket).assigns.current_user && unquote(socket).assigns.current_user.admin? do
        unquote(blocks[:do])
      else
        socket =
          unquote(socket)
          |> assign(unquote(socket).assigns.__changed__)
          |> push_navigate(to: ~p"/users/log_in")

        unquote(blocks[:else])
      end
    end
  end

  ## JS Commands

  def show(js \\ %JS{}, selector, time \\ 200) do
    JS.show(js,
      to: selector,
      time: time,
      transition: {"transition-opacity transform ease-out duration-1000", "opacity-0", "opacity-100"}
    )
  end

  def hide(js \\ %JS{}, selector, time \\ 200) do
    JS.hide(js,
      to: selector,
      time: time,
      transition: {"transition-opacity transform ease-in duration-1000", "opacity-100", "opacity-0"}
    )
  end

  def show_expand(js \\ %JS{}, selector, time \\ 200) do
    JS.show(js,
      to: selector,
      time: time,
      transition: {"transition-all transform ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95", "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide_contract(js \\ %JS{}, selector, time \\ 200) do
    JS.hide(js,
      to: selector,
      time: time,
      transition: {"transition-all transform ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show_expand("##{id}-container", 500)
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide_contract("##{id}-container", 500)
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(KartVidsWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(KartVidsWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  defp input_equals?(val1, val2) do
    Phoenix.HTML.html_escape(val1) == Phoenix.HTML.html_escape(val2)
  end

  @doc """
  Displays a video preview for a file which is being uploaded.

  Example:

      <.live_video_preview entry={entry} />
  """
  def live_video_preview(%{entry: %Phoenix.LiveView.UploadEntry{ref: ref} = entry} = assigns) do
    rest =
      assigns
      |> assigns_to_attributes([:entry])
      |> Keyword.put_new_lazy(:id, fn -> "phx-preview-#{ref}" end)

    assigns = assign(assigns, entry: entry, ref: ref, rest: rest)

    ~H"""
    <video data-phx-upload-ref={@entry.upload_ref} data-phx-entry-ref={@ref} data-phx-hook="Phoenix.LiveImgPreview" data-phx-update="ignore" {@rest} />
    """
  end

  attr(:current_user, :any)

  def navigation_header(assigns) do
    ~H"""
    <header class="px-4 sm:px-6 lg:px-8 text-white border-b-4 border-slate-300 bg-gradient-to-b from-sky-800 to-sky-400">
      <div class="flex items-center justify-between py-3">
        <div class="flex items-center gap-4">
          <a href={~p"/"}>
            <image src={~p"/images/KartVids-64.png"} />
          </a>
          <span class="font-mono text-2xl">KART VIDS</span>
        </div>
        <div class="flex items-center gap-4 text-right">
          <ul>
            <%= if @current_user do %>
              <li>
                <%= @current_user.email %>
              </li>
              <li>
                <.link href={~p"/locations"}>Locations</.link>
                &nbsp;|&nbsp;
                <%= if @current_user.admin? do %>
                  <.admin_link current_user={@current_user} navigate={~p"/admin/videos"}>Videos</.admin_link>
                  &nbsp;|&nbsp;
                <% end %>
                <.link href={~p"/users/settings"}>Settings</.link>
              </li>
              <li>
                <.link href={~p"/users/log_out"} method="delete">Log out</.link>
              </li>
            <% else %>
              <li>
                <.link href={~p"/users/register"}>Register</.link>
              </li>
              <li>
                <.link href={~p"/users/log_in"}>Log in</.link>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </header>
    """
  end
end
