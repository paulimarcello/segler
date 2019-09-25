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
      {%MerkmalLogisch{}, %MerkmalLogisch{}} -> MerkmalLogisch.splitte(left, right)
    end
  end
end
