require_relative './config.rb'
require_relative '../module/Slidenote.rb'

# Get slide url
puts 'Slide URL'
url = gets.chomp
tag = ['slide']

Slidenote.new(url, tag)

