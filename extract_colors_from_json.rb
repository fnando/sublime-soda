# frozen_string_literal: true

require "json"
require "erb"

json = JSON.parse(File.read("#{__dir__}/Soda.sublime-color-scheme"))

colors = Hash.new {|h, k| h[k] = [] }

colors = json["globals"].each_with_object(colors) do |(key, color), buffer|
  buffer[color] << key
end

colors = json["rules"].each_with_object(colors) do |rule, buffer|
  buffer[rule["foreground"]] << rule["scope"] if rule["foreground"]
  buffer[rule["background"]] << rule["scope"] if rule["background"]
end

def to_css(color)
  return color if color =~ /^#(.{3}|\.{6})$/

  p color
  _, r, g, b, alpha = *color.match(/^#(.{2})(.{2})(.{2})(.{1,3})$/)

  r = r.to_i(16)
  g = g.to_i(16)
  b = b.to_i(16)

  "rgba(#{r}, #{g}, #{b}, #{alpha})"
end

template = <<~HTML
  <% colors.keys.each do |color| %>
    <div style="width: 25px; height: 25px; background: <%= to_css(color) %>"></div>
  <% end %>
HTML

puts ERB.new(template).result(binding)
