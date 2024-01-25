defmodule Plausible.Stats.Util do
  @moduledoc """
  Utilities for modifying stat results
  """

  @doc """
  `__internal_visits` is fetched when querying bounce rate and visit duration, as it
  is needed to calculate these from imported data. This function removes that metric
  from all entries in the results list.
  """
  def remove_internal_visits_metric(results, metrics) when is_list(results) do
    if :bounce_rate in metrics or :visit_duration in metrics do
      results
      |> Enum.map(&remove_internal_visits_metric/1)
    else
      results
    end
  end

  def remove_internal_visits_metric(result) when is_map(result) do
    Map.delete(result, :__internal_visits)
  end

  def calculate_cr(nil, _converted_visitors), do: nil

  def calculate_cr(unique_visitors, converted_visitors) do
    if unique_visitors > 0,
      do: Float.round(converted_visitors / unique_visitors * 100, 1),
      else: 0.0
  end
end
