defmodule TarifvarianteTest do
  alias Aufbereitung.Model.Merkmal, as: Merkmal
  alias Aufbereitung.Model.Tarifvariante, as: Tarifvariante

  use ExUnit.Case

  test "splitte mit leeren merkmalen" do
    tarifvariante = Tarifvariante.new(1, 10, [Merkmal.new_logisch(1, :erfuellt)])

    result = Tarifvariante.splitte(tarifvariante, [])

    assert result === [tarifvariante]
  end

  test "splitte bei einem merkmal" do
    tarifvariante = Tarifvariante.new(1, 10, [Merkmal.new_logisch(1, :egal)])

    result = Tarifvariante.splitte(tarifvariante, Merkmal.new_logisch(1, :erfuellt))

    assert result === [
      Tarifvariante.new(1, 10, [Merkmal.new_logisch(1, :erfuellt)]),
      Tarifvariante.new(1, 10, [Merkmal.new_logisch(1, :nicht_erfuellt)])
    ]
  end

  test "splitte bei mehreren merkmal" do
    tarifvariante =
      Tarifvariante.new(1, 10, [
        Merkmal.new_logisch(1, :egal),
        Merkmal.new_logisch(2, :erfuellt),
        Merkmal.new_bereich(3, 18, 150)
      ])

    split_merkmale = [
      Merkmal.new_logisch(1, :erfuellt),
      Merkmal.new_bereich(3, 30, 50)
    ]

    result = Tarifvariante.splitte(tarifvariante, split_merkmale)

    expected = [
      Tarifvariante.new(1, 10, [
        Merkmal.new_logisch(1, :erfuellt),
        Merkmal.new_logisch(2, :erfuellt),
        Merkmal.new_bereich(3, 18, 29),
      ]),

      Tarifvariante.new(1, 10, [
        Merkmal.new_logisch(1, :nicht_erfuellt),
        Merkmal.new_logisch(2, :erfuellt),
        Merkmal.new_bereich(3, 18, 29),
      ]),

      Tarifvariante.new(1, 10, [
        Merkmal.new_logisch(1, :erfuellt),
        Merkmal.new_logisch(2, :erfuellt),
        Merkmal.new_bereich(3, 30, 50),
      ]),

      Tarifvariante.new(1, 10, [
        Merkmal.new_logisch(1, :nicht_erfuellt),
        Merkmal.new_logisch(2, :erfuellt),
        Merkmal.new_bereich(3, 30, 50),
      ]),

      Tarifvariante.new(1, 10, [
        Merkmal.new_logisch(1, :erfuellt),
        Merkmal.new_logisch(2, :erfuellt),
        Merkmal.new_bereich(3, 51, 150),
      ]),

      Tarifvariante.new(1, 10, [
        Merkmal.new_logisch(1, :nicht_erfuellt),
        Merkmal.new_logisch(2, :erfuellt),
        Merkmal.new_bereich(3, 51, 150),
      ]),
    ]

    assert Enum.count(result) === 6
    assert Enum.filter(result, fn x -> Enum.member?(expected, fn y -> x === y end) end) === []
  end
end
