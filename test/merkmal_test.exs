defmodule MerkmalLogischTest do
  use ExUnit.Case
  doctest(MerkmalLogisch)

  test "ueberschneidet unterschiedliche merkmal_id" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new(true)
    right = MerkmalId.new(2) |> MerkmalLogisch.new(true)

    assert Merkmal.ueberschneidet(left, right) === false
  end

  test "ueberschneidet gleiche merkmal_id und beide identische auspraegung" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new(true)
    right = MerkmalId.new(1) |> MerkmalLogisch.new(true)

    assert Merkmal.ueberschneidet(left, right) === true
  end

  test "ueberschneidet gleiche merkmal_id und unterschiedliche auspraegung" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new(true)
    right = MerkmalId.new(1) |> MerkmalLogisch.new(false)

    assert Merkmal.ueberschneidet(left, right) === false
  end

  test "ueberschneidet gleiche merkmal_id und eine auspraegung nil" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new(true)
    right = MerkmalId.new(1) |> MerkmalLogisch.new()

    assert Merkmal.ueberschneidet(left, right) === true
  end
end
