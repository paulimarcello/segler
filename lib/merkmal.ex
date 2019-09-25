defmodule Merkmal do
  def ueberschneidet(left, right) do
    gleiche_id(left, right) &&
      ueberschneidet_merkmal(left, right)
  end

  defp gleiche_id(left, right) do
    left.id == right.id
  end

  defp ueberschneidet_merkmal(%MerkmalLogisch{id: _, ist_erfuellt: l_bool}, %MerkmalLogisch{id: _, ist_erfuellt: r_bool}) do
    l_bool == nil || r_bool == nil || l_bool === r_bool
  end

  def splitte(left, right) do
    case {left, right} do
      {%MerkmalLogisch{}, %MerkmalLogisch{}} -> splitte_logisch(left, right)
    end
  end

  defp splitte_logisch(left, right) do
    cond do
      left == right -> [left]
      left.ist_erfuellt == nil -> beide_logische_auspraegungen(left.id)
      right.ist_erfuellt == nil -> beide_logische_auspraegungen(right.id)
      left.ist_erfuellt -> [left]
    end
  end

  defp beide_logische_auspraegungen(id),
    do: [%MerkmalLogisch{id: id, ist_erfuellt: true}, %MerkmalLogisch{id: id, ist_erfuellt: false}]
end
