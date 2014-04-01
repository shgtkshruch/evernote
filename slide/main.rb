require_relative './config'
require_relative '../module/slide_note'
require 'evernote_oauth'

# Get slide url
puts 'Slide URL'
url = gets.chomp
tags = ['slide']

slideNote(url, tags)
