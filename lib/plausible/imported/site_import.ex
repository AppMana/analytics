defmodule Plausible.Imported.SiteImport do
  @moduledoc """
  Site import schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Plausible.Imported.ImportSources

  @type t() :: %__MODULE__{}

  schema "site_imports" do
    field :start_date, :date
    field :end_date, :date
    field :source, :string
    field :status, Ecto.Enum, values: [:pending, :importing, :completed, :failed]

    belongs_to :site, Plausible.Site
    belongs_to :imported_by, Plausible.Auth.User

    timestamps()
  end

  def create_changeset(site, user, params) do
    %__MODULE__{}
    |> cast(params, [:source, :start_date, :end_date])
    |> validate_required([:source])
    |> validate_inclusion(:source, ImportSources.names())
    |> put_assoc(:site, site)
    |> put_assoc(:imported_by, user)
    |> put_change(:status, :pending)
  end

  def start_changeset(site_import) do
    site_import
    |> change(status: :importing)
  end

  def complete_changeset(site_import, params \\ %{}) do
    site_import
    |> cast(params, [:start_date, :end_date])
    |> put_change(:status, :completed)
    |> validate_required([:start_date, :end_date])
  end

  def fail_changeset(site_import) do
    change(site_import, status: :failed)
  end
end
