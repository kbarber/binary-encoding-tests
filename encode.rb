#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'base64'
require 'cgi'

def percent(a, b)
  (a.length.to_f / b.length.to_f * 100)
end

results = []

Dir.glob("system/**/*.tar.gz") do |filename|
  original = nil
  File.open(filename, 'rb') do |file|
    original = file.read
  end

  base64 = Base64.encode64(original)

  json = {
    'command' => 'publish module',
    'version' => 1,
    'payload' => base64,
  }.to_json

  urlencoded = CGI::escape(json)

  result = {
    :filename => filename,
    :original => original.length,
    :base64 => base64.length,
    :base64_percent => percent(base64, original),
    :json => base64.length,
    :json_percent => percent(json, original),
    :urlencoded => base64.length,
    :urlencoded_percent => percent(urlencoded, original),
  }

  results << result
end

percents = results.map {|result| result[:urlencoded_percent] }
average = percents.inject(0.0) { |sum, el| sum + el } / percents.size
highest = percents.sort[-1]
lowest = percents.sort[0]

puts <<-EOS
Sample Size:          #{percents.size}
Mean Average Percent: #{average}
Highest Percent:      #{highest}
Lowest Percent:       #{lowest}
EOS
