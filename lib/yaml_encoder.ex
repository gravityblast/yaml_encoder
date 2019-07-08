defmodule YamlEncoder do
  @moduledoc """
  Not ready for production, still WIP.
  """

  @doc """
  Encodes data to YAML
  """
  def encode(value) do
    encode(0, value)
  end

  defp encode(indent, data) when is_number(data) do
    "#{data}\n"
  end

  defp encode(indent, data) when is_boolean(data) do
    value =
      case data do
        true -> "true"
        _ -> "false"
      end

    ~s(#{value}\n)
  end

  defp encode(indent, data) when is_binary(data) do
    value = encode_string(indent, data)
    ~s(#{value}\n)
  end

  defp encode(indent, data) when is_atom(data) do
    encode(indent, to_string(data))
  end

  defp encode(indent, []) do
    "[]\n"
  end

  defp encode(indent, data) when is_list(data) do
    encode_list(indent, "", data)
  end

  defp encode(indent, {k, v}) do
    prefix = indent_spaces(indent)
    value = encode(indent, v)
    "#{prefix}#{k}: #{value}"
  end

  defp encode(indent, data) when is_map(data) do
    encode_map(indent, "", data)
  end

  defp encode_list(indent, s, [{_, _} | _] = list) do
    for {k, v} <- list,
        do: encode_key_value(indent, {k, v}),
        into: s
  end

  defp encode_list(indent, s, [head | tail]) do
    value = encode_list_item(indent, head)
    encode_list(indent, "#{s}#{value}", tail)
  end

  defp encode_list(indent, s, []) do
    s
  end

  defp encode_list_item(indent, data) do
    value = encode(data)
    prefix = indent_spaces(indent)
    "#{prefix}- #{value}"

    if is_map(data) || is_list(data) do
      value = encode(indent + 1, data)
      "#{prefix}-\n#{value}"
    else
      value = encode(indent, data)
      "#{prefix}- #{value}"
    end
  end

  defp encode_map(indent, s, data) do
    for {k, v} <- data,
        do: encode_key_value(indent, {k, v}),
        into: s
  end

  defp encode_key_value(indent, {k, v}) do
    prefix = indent_spaces(indent)

    if is_map(v) || (is_list(v) && length(v) > 0) do
      value = encode(indent + 1, v)
      "#{prefix}#{k}:\n#{value}"
    else
      value = encode(indent, v)
      "#{prefix}#{k}: #{value}"
    end
  end

  defp encode_string(indent, data) do
    single_quotes = data =~ ~r/'/
    double_quotes = data =~ ~r/"/
    encode_string(indent, data, single_quotes, double_quotes)
  end

  defp encode_string(indent, data, true, true) do
    ["'''", escape(data), "'''"]
    |> IO.iodata_to_binary()
  end

  defp encode_string(indent, data, false, true) do
    [?', escape(data), ?']
    |> IO.iodata_to_binary()
  end

  defp encode_string(indent, data, _single_quotes, _double_quotes) do
    [?", escape(data), ?"]
    |> IO.iodata_to_binary()
  end

  defp escape(""), do: []

  for {char, seq} <- Enum.zip('\\\n\t\r\f\b', '\\ntrfb') do
    defp escape(<<unquote(char)>> <> rest) do
      [unquote("\\" <> <<seq>>) | escape(rest)]
    end
  end

  defp escape(<<char::utf8>> <> rest) do
    [char | escape(rest)]
  end

  defp indent_spaces(0) do
    ""
  end

  defp indent_spaces(n) do
    for _ <- 0..(n - 1), do: "  ", into: ""
  end
end
