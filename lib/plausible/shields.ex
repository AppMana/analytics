defmodule Plausible.Shields do
  import Ecto.Query
  alias Plausible.Repo
  alias Plausible.Shield

  @spec list_ip_rules(Plausible.Site.t() | non_neg_integer()) :: [Shield.IPRule.t()]
  def list_ip_rules(site_id) when is_integer(site_id) do
    Repo.all(
      from r in Shield.IPRule,
        where: r.site_id == ^site_id,
        order_by: [desc: r.inserted_at]
    )
  end

  def list_ip_rules(%Plausible.Site{id: id}) do
    list_ip_rules(id)
  end

  @spec add_ip_rule(Plausible.Site.t() | non_neg_integer(), map()) ::
          {:ok, Shield.IPRule.t()} | {:error, Ecto.Changeset.t()}
  def add_ip_rule(site_id, params) when is_integer(site_id) do
    %Shield.IPRule{}
    |> Shield.IPRule.changeset(Map.put(params, "site_id", site_id))
    |> Repo.insert()
  end

  def add_ip_rule(%Plausible.Site{id: id}, params) do
    add_ip_rule(id, params)
  end

  @spec remove_ip_rule(Plausible.Site.t() | non_neg_integer(), String.t()) :: :ok
  def remove_ip_rule(site_id, rule_id) when is_integer(site_id) do
    Repo.delete_all(from(r in Shield.IPRule, where: r.site_id == ^site_id and r.id == ^rule_id))
  end

  def remove_ip_rule(%Plausible.Site{id: site_id}, rule_id) do
    remove_ip_rule(site_id, rule_id)
  end

  @spec count_ip_rules(Plausible.Site.t() | non_neg_integer()) :: non_neg_integer()
  def count_ip_rules(site_id) when is_integer(site_id) do
    Repo.aggregate(from(r in Shield.IPRule, where: r.site_id == ^site_id), :count)
  end

  def count_ip_rules(%Plausible.Site{id: id}) do
    count_ip_rules(id)
  end
end
