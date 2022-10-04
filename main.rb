require "js"
require "erb"

template = ERB.new(<<~'END_HTML')
  <div
    class="w-full flex flex-col justify-center items-center text-4xl tracking-[1em] leading-loose uppercase"
  >
    <a
      href="https://www.merriam-webster.com/dictionary/<%= word %>"
      target="_blank"><%= heiglighted_word %></a>
  </div>
END_HTML

document = JS.global[:document]
search_button = document.getElementById "search_button"
search_button.addEventListener "click" do
  exclude = document.getElementById("exclude")[:value]
  included = document.getElementById("included")[:value].to_s
  correct_places = document.getElementById("correct_places")[:value]
  matched = WordleSeach.search exclude, included, correct_places

  frequency_chars = matched.join
    .chars
    .tally
    .sort_by { _2 }
    .reverse
    .take(5)
    .map { _1[0] }
    .join

  html = matched.map do |word|
    heiglighted_word = word.chars.map do |char|
      if included.include? char
        "<span class='text-red-500'>#{char}</span>"
      elsif frequency_chars.include? char
        "<span class='text-green-500'>#{char}</span>"
      else
        char
      end
    end.join
    template.result_with_hash word:, heiglighted_word:
  end.join

  document.getElementById("result")[:innerHTML] = html
end
