defmodule Plausible.Shields do
  import Ecto.Query
  alias Plausible.Repo
  alias Plausible.Shield

  @spec list_ip_rules(Plausible.Site.t()) :: [Rules.IP.t()]
  def list_ip_rules(site) do
    Repo.all(from r in Shield.IPRule, where: r.site_id == ^site.id)
  end

  @spec add_ip_rule(Plausible.Site.t(), map()) ::
          {:ok, ShieldIPRule.t()} | {:error, Ecto.Changeset.t()}
  def add_ip_rule(site, params) do
    %Shield.IPRule{}
    |> Shield.IPRule.changeset(Map.put(params, "site_id", site.id))
    |> Repo.insert()
  end
end
