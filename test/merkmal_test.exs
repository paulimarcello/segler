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

  test "gleiche ids und beide true -> ein gleiches merkmal" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new(true)
    right = MerkmalId.new(1) |> MerkmalLogisch.new(true)

    result = Merkmal.splitte(left, right)

    assert result == [left] && result == [right]
  end

  test "gleiche ids und beide false -> ein gleiches merkmal" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new(false)
    right = MerkmalId.new(1) |> MerkmalLogisch.new(false)

    result = Merkmal.splitte(left, right)

    assert result == [left] && result == [right]
  end

  test "gleiche ids und erstes nil -> 2 auspraegungen" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new()
    right = MerkmalId.new(1) |> MerkmalLogisch.new(false)

    result = Merkmal.splitte(left, right)

    expected = [MerkmalId.new(1) |> MerkmalLogisch.new(true), MerkmalId.new(1) |> MerkmalLogisch.new(false)]

    assert result == expected
  end

  test "gleiche ids und zweites nil -> 2 auspraegungen" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new(true)
    right = MerkmalId.new(1) |> MerkmalLogisch.new()

    result = Merkmal.splitte(left, right)

    expected = [MerkmalId.new(1) |> MerkmalLogisch.new(true), MerkmalId.new(1) |> MerkmalLogisch.new(false)]

    assert result == expected
  end

  test "gleiche ids und unterschiedliche auspraegungen -> nicht splittbar, also left" do
    left = MerkmalId.new(1) |> MerkmalLogisch.new(true)
    right = MerkmalId.new(1) |> MerkmalLogisch.new(false)

    result = Merkmal.splitte(left, right)

    assert result == [left]
  end
end
