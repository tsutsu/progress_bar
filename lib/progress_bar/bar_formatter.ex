defmodule ProgressBar.BarFormatter do
  alias ProgressBar.Utils

  def write(io_device, format, {bar, bar_color}, suffix) do
    bar = render(format, {bar, bar_color}, suffix)
    IO.binwrite(io_device, bar)
  end

  def write(io_device, format, {bar, bar_color, bar_percent}, {blank, blank_color}, suffix) do
    bar = render(format, {bar, bar_color, bar_percent}, {blank, blank_color}, suffix)
    IO.binwrite(io_device, bar)
  end

  # Full-width bar, with no blank (i.e. indeterminate).
  def render(format, {bar, bar_color}, suffix) do
    render(format, {bar, bar_color, 100}, {"", []}, suffix)
  end

  # Bar + blank.
  def render(format, {bar, bar_color, bar_percent}, {blank, blank_color}, suffix) do
    {bar_width, blank_width} = bar_and_blank_widths(format, suffix, bar_percent)

    full_bar = [
      bar |> repeat(bar_width) |> Utils.color(bar_color),
      blank |> repeat(blank_width) |> Utils.color(blank_color)
    ]

    chardata(format, full_bar, suffix)
  end

  defp bar_and_blank_widths(format, suffix, bar_percent) do
    full_bar_width = full_bar_width(format, suffix)
    bar_width = (bar_percent / 100 * full_bar_width) |> round
    blank_width = full_bar_width - bar_width

    {bar_width, blank_width}
  end

  defp chardata(format, bar, suffix) do
    [
      Utils.ansi_prefix(),
      format[:left],
      bar,
      format[:right],
      suffix
    ]
  end

  defp full_bar_width(format, suffix) do
    other_text = chardata(format, "", suffix) |> IO.chardata_to_string()
    ProgressBar.FullBarWidth.determine(format[:width], other_text)
  end

  defp repeat("", _), do: ""

  defp repeat(bar, width) do
    bar
    |> String.graphemes()
    |> Stream.cycle()
    |> Enum.take(width)
    |> Enum.join()
  end
end
