require "erb"
require "js/require_remote"

module Kernel
  def require_relative(path) = JS::RequireRemote.instance.load(path)
end

require_relative "wordle_search"

module DictionarySearch
  def self.call(event, params)
    document = JS.global[:document]
    exclude = document.getElementById("exclude")[:value].to_s
    included = document.getElementById("included")[:value].to_s
    correct_places = document.getElementById("correct_places")[:value].to_s
    matched = WordleSeach.search exclude, included, correct_places.gsub('*', '\w')

    frequency_chars = matched.join
      .chars
      .tally
      .sort_by { _2 }
      .reverse
      .take(5)
      .map { _1[0] }
      .join

    html = matched
      .sort_by do |word|
        (word.chars & frequency_chars.chars).length
      end
      .reverse
      .map do |word|
        heiglighted_word = word.chars.map.with_index do |char, i|
          heigligten_char_with correct_places[i], included, frequency_chars, char
        end.join

        template.result_with_hash word:, heiglighted_word:
      end.join

    document.getElementById("result")[:innerHTML] = html
  end

  private

  def self.heigligten_char_with(correct_place, included, frequency_chars, char)
    if correct_place == char
      "<span class='text-green-500'>#{char}</span>"
    elsif included.include? char
      "<span class='text-red-500'>#{char}</span>"
    elsif frequency_chars.include? char
      "<span class='text-yellow-500'>#{char}</span>"
    else
      char
    end
  end

  def self.template = ERB.new(<<~'END_HTML')
    <div
      class="w-full flex flex-col justify-center items-center text-4xl tracking-[1em] leading-loose uppercase"
    >
      <a
        href="https://www.merriam-webster.com/dictionary/<%= word %>"
        target="_blank"><%= heiglighted_word %></a>
    </div>
  END_HTML
end

OrbitalRing::Routes.draw do
  click "#search_button", to: DictionarySearch
end
