require "erb"
require "js/require_remote"

module Kernel
  def require_relative(path) = JS::RequireRemote.instance.load(path)
end

require_relative "wordle_search"

module DictionarySearch
  def self.call(event, params)
    event.preventDefault if event.respond_to?(:preventDefault)
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

    candidates_html = matched
      .sort_by do |word|
        (word.chars & frequency_chars.chars).length
      end
      .reverse
      .take(16)
      .map do |word|
        heiglighted_word = word.chars.map.with_index do |char, i|
          heigligten_char_with correct_places[i], included, frequency_chars, char
        end.join

        candidate_template.result_with_hash word:, heiglighted_word:
      end.join

    template = ERB.new(<<~'END_HTML')
      <div>
        <div
          class="text-center"
        >
          <%= counts %> candidates found
        </div>
        <%= candidates_html %>
      </div>
    END_HTML

    document.getElementById("result")[:innerHTML] = template.result_with_hash candidates_html: candidates_html, counts: matched.length
  end

  private

  def self.heigligten_char_with(correct_place, included, frequency_chars, char)
    color_class =
      if correct_place == char
        "text-green-500"
      elsif included.include? char
        "text-red-500"
      elsif frequency_chars.include? char
        "text-yellow-500"
      else
        ""
      end

    "<span class='inline-flex w-[0.9em] justify-center #{color_class}'>#{char}</span>"
  end

  def self.candidate_template = ERB.new(<<~'END_HTML')
    <div
      class="w-fit mx-auto text-center text-4xl leading-loose uppercase"
    >
      <a
        class="inline-flex justify-center gap-[0.35em]"
        href="https://www.merriam-webster.com/dictionary/<%= word %>"
        target="_blank"><%= heiglighted_word %></a>
    </div>
  END_HTML
end

search_on_enter = proc do |event, params|
  next unless event[:key].to_s == "Enter"

  event.preventDefault if event.respond_to?(:preventDefault)
  JS.global[:document].getElementById("search_button").click
end

OrbitalRing::Routes.draw do
  click "#search_button", to: DictionarySearch
  keydown "#exclude", to: search_on_enter
  keydown "#included", to: search_on_enter
  keydown "#correct_places", to: search_on_enter
end
