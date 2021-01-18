
require "nokogiri"
require 'securerandom'
require './design'

class ParameterMissingException < RuntimeError
  def initialize
    super("Must pass text content file as the content value and highlights file as parameters")
  end
end

raise ParameterMissingException if ARGV[0].nil? || ARGV[1].nil?

class HtmlTextHighlight
  include Design
  def initialize(content, highlights)
    @content = File.read(content).split("=")[1]
    @highlights_content = File.read(highlights).split("=")[1]
    @generate_highlights = []
    @html_to_paragraph = []
  end

  def execute
    read_highlights_start_and_end
    read_highlights_comment
    read_highlights_length
    map_highlights_length
    html_highlights_to_paragraph
  end

  private

  def read_highlights_start_and_end
    @read_highlights_start_and_end = @highlights_content.scan(/\d+/)
  end

  def read_highlights_comment
    @read_highlights_comment = @highlights_content.scan(/\b(?![a-z]+\b|[A-Z]+\b)[a-zA-Z]+/)
  end

  def get_highlights_comment
    @read_highlights_comment.slice!(0)
  end

  def read_highlights_length
    read_highlights_start_and_end.length/2
  end

  def get_highlights_range
    @read_highlights_start_and_end.slice!(0,2)
  end

  def map_highlights_length
    (1..read_highlights_length).to_a.map do |_|
       @generate_highlights << generate_html_highlights(@content)
    end
  end

  def generate_html_highlights(text)
    range = get_highlights_range
    comment = get_highlights_comment
    text_replacement =  text.split[range[0].to_i...range[1].to_i].join(" ").to_s
    html_text = """<span class='tooltip' style='background-color:##{SecureRandom.hex(3)}'>#{text_replacement}<span class='tooltiptext'>#{comment}</span></span>"""  if !text_replacement&.empty?
    html_color_text = text.sub!(/#{text_replacement}/, "#{html_text}") if !text_replacement&.empty?

    # For highlight spanning between paragraph
    if !text_replacement&.empty? && !html_color_text
      text_content = text.gsub(/<\/?[^>]*>/, "").scan(/\w+/)
      count = text_content.size
      return if (range[0].to_i  > count ||  range[1].to_i > count )
      # start range
      total_count = text.split.count
      diff = total_count - count
      small_count = range[0].to_i + diff
      color = SecureRandom.hex(3)
      comment_hack = comment
      begin_span = text.split[small_count.to_i...small_count.to_i+2].join(" ").to_s
      html_text = """<div class='tooltip'><mark style='background-color:##{color}'>#{begin_span}"""  if !begin_span&.empty?
      text.sub!(/#{begin_span}/, "#{html_text}") if !begin_span&.empty?
      ## end range
      new_total_count = text.split.count
      diff = new_total_count - count
      large_count = range[1].to_i + diff
      end_span = text.split[large_count.to_i-2...large_count].join(" ").to_s
      large_html_text = """#{end_span} <span class='tooltiptext'>#{comment_hack}</span> </mark></div>"""  if !end_span&.empty?
      html_color_text = text.sub!(/#{end_span}/, "#{large_html_text}") if !end_span&.empty?
      return html_color_text
    end

    return html_color_text
  end

  def html_highlights_to_paragraph
    @html_to_paragraph = @generate_highlights.compact.last.split(/\n\n/).map do |paragraph|
       "<p>#{paragraph}</p>"
    end
    write_html_highlights_to_file(@html_to_paragraph)
  end

  def write_html_highlights_to_file(text_to_html)
    document = Nokogiri::HTML(text_to_html.join("\n"))
    body = document.at_css "body"
    body.parent = document.at_css "html"

    body.add_previous_sibling(stylesheet)
    body.add_previous_sibling(js_script)

    html = document.at_css "html"
    html['lang'] = 'en'
    File.write("html_hightlight_text.html", document.to_html)
  end
end



html_text_hightlight = HtmlTextHighlight.new(ARGV[0], ARGV[1])
html_text_hightlight.execute

