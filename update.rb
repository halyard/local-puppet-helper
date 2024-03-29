#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open-uri'

PATH = 'Puppetfile'
REGEX = /^hmod '(?<name>\w+)', '(?<version>[\w.]+)'$/.freeze
URL = 'https://forgeapi.puppetlabs.com/v3/modules/halyard-%s'

def latest_release(name)
  JSON.parse(URI.open(URL % name).read).fetch('current_release', {})['version']
rescue OpenURI::HTTPError
  puts "No release found for #{name}"
end

def update(match)
  line, name, old = match.to_a
  latest = latest_release(name) || old
  puts "Updating #{name} from #{old} to #{latest}" if old != latest
  line.sub(old, latest)
end

lines = File.read(PATH).split("\n").map do |line|
  match = line.match(REGEX)
  match ? update(match) : line
end

File.open(PATH, 'w') { |fh| lines.each { |line| fh << "#{line}\n" } }
