require "js/require_remote/relative_shim"

require_relative "wordle_search"

search_on_enter = proc do |event, params|
  next unless event[:key].to_s == "Enter"

  event.preventDefault if event.respond_to?(:preventDefault)
  JS.global[:document].getElementById("search_button").click
end

OrbitalRing::Routes.draw do
  click "#search_button", to: WordleSearch
  keydown "#exclude", to: search_on_enter
  keydown "#included", to: search_on_enter
  keydown "#correct_places", to: search_on_enter
end
