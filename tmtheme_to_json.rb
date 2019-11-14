#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "plist"
require "json"
require "fileutils"

input_file = File.expand_path(ARGV[0])
output_file = File.expand_path(ARGV[1])
plist = Plist.parse_xml(input_file)

def build_rule(rule)
  return unless rule["scope"]
  return if rule["name"] =~ /^-+$/

  {
    name: rule["name"],
    scope: rule["scope"]
  }.merge(normalize(rule["settings"]))
end

def normalize(hash)
  hash.each_with_object({}) do |(key, value), buffer|
    next if value.empty?

    buffer[key.gsub(/([A-Z])/) { "_#{Regexp.last_match(1)}".downcase }] = value.downcase
  end
end

rules = plist["settings"].reject {|rule| rule["scope"] =~ /^m?col/ }

theme = {}
theme[:name] = "Soda"
theme[:uuid] = plist["uuid"]
theme[:globals] = normalize(rules.reject {|rule| rule["name"] }.first.fetch("settings"))
theme[:rules] = rules
                .map {|rule| build_rule(rule) }
                .reject(&:nil?)

FileUtils.mkdir_p(File.dirname(output_file))

File.open(output_file, "w") do |file|
  file << JSON.pretty_generate(theme)
end
