defmodule YamlEncoderTest do
  use ExUnit.Case
  doctest YamlEncoder

  test "encode number" do
    value = YamlEncoder.encode(1)
    assert value == "1\n"
  end

  test "encode boolean" do
    value = YamlEncoder.encode(true)
    assert value == "true\n"

    value = YamlEncoder.encode(false)
    assert value == "false\n"
  end

  test "encode string" do
    value = YamlEncoder.encode("foo")
    assert value == ~s("foo"\n)
  end

  test "encode string, escape control characters" do
    value = YamlEncoder.encode("foo\nbar")
    assert value == ~s("foo\\nbar"\n)

    value = YamlEncoder.encode("\\")
    assert value == ~s("\\\\"\n)

    value = YamlEncoder.encode("\\ 💬 Escalate")
    assert value == ~s("\\\\ 💬 Escalate"\n)
  end

  test "encode atom" do
    value = YamlEncoder.encode(:foo)
    assert value == ~s("foo"\n)
  end

  test "encode tuple" do
    value = YamlEncoder.encode({:foo, :bar})
    assert value == ~s(foo: "bar"\n)
  end

  test "encode list of tuples" do
    value = YamlEncoder.encode([{:foo, 1}, {:bar, 2}])

    expected = """
    foo: 1
    bar: 2
    """

    assert value == expected
  end

  test "encode string with single quotes" do
    value = YamlEncoder.encode("foo 'bar'")
    assert value == ~s("foo 'bar'"\n)
  end

  test "encode string with double quotes" do
    value = YamlEncoder.encode(~s(foo "bar"))
    assert value == ~s('foo "bar"'\n)
  end

  test "encode string with single and double quotes" do
    value = YamlEncoder.encode(~s(foo "bar" 'baz'))
    assert value == ~s(>\n  foo "bar" 'baz'\n)
    value = YamlEncoder.encode(%{"key" => ~s(foo "bar" 'baz')})
    assert value == ~s(key: >\n  foo "bar" 'baz'\n)
    value = YamlEncoder.encode([%{"key" => ~s(foo "bar" 'baz')}])
    assert value == ~s(-\n  key: >\n    foo "bar" 'baz'\n)
  end

  test "encode list" do
    value = YamlEncoder.encode([1, "foo", 2, "bar"])

    expected = """
    - 1
    - "foo"
    - 2
    - "bar"
    """

    assert value == expected
  end

  test "encode empty list" do
    value = YamlEncoder.encode([])

    expected = "[]\n"
    assert value == expected
  end

  test "encode nested empty list" do
    value = YamlEncoder.encode([{:foo, []}])

    expected = "foo: []\n"
    assert value == expected
  end

  test "encode map" do
    value = YamlEncoder.encode(%{"foo" => 1, "bar" => "baz"})

    expected_lines = [
      ~s(bar: "baz"),
      ~s(foo: 1)
    ]

    lines = String.split(value, "\n")

    for expected <- expected_lines do
      found = Enum.find(lines, &(&1 == expected))
      assert found
    end
  end

  test "encode map with a list child" do
    data = %{
      "foo" => [1, 2, 3]
    }

    value = YamlEncoder.encode(data)

    expected = """
    foo:
      - 1
      - 2
      - 3
    """

    assert value == expected
  end

  test "encode map with a map child" do
    data = %{
      "foo" => %{
        "bar" => %{
          "baz" => %{
            "xxx" => [1, 2],
            "zzz" => [
              %{
                "hello" => 1,
                "world" => [
                  [1, 2],
                  [3, 4]
                ],
                "x" => [],
                "z" => [
                  {:a, 1},
                  {:b, 2}
                ]
              }
            ]
          }
        }
      }
    }

    value = YamlEncoder.encode(data)

    expected = """
    foo:
      bar:
        baz:
          xxx:
            - 1
            - 2
          zzz:
            -
              hello: 1
              world:
                -
                  - 1
                  - 2
                -
                  - 3
                  - 4
              x: []
              z:
                a: 1
                b: 2
    """

    assert value == expected
  end

  test "encode empty map" do
    value = YamlEncoder.encode(%{})

    expected = "{}\n"
    assert value == expected
  end

  test "encode nested empty map" do
    value = YamlEncoder.encode([{:foo, %{}}])

    expected = "foo: {}\n"
    assert value == expected
  end
end
