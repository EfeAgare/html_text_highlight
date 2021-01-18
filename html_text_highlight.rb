
require "nokogiri"
require 'securerandom'


content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas consectetur malesuada velit, sit amet porta magna maximus nec. Aliquam aliquet tincidunt enim vel rutrum. Ut augue lorem, rutrum et turpis in, molestie mollis nisi. Ut dapibus erat eget felis pulvinar, ac vestibulum augue bibendum. Quisque sagittis magna nisi. Sed aliquam porttitor fermentum. Nulla consequat justo eu nulla sollicitudin auctor. Sed porta enim non diam mollis, a ullamcorper dolor molestie. Nam eu ex non nisl viverra hendrerit. Donec ante augue, eleifend vel eleifend quis, laoreet volutpat ipsum. Integer viverra aliquam nulla, ac rutrum dui sodales nec.

Sed turpis enim, porttitor nec maximus sed, luctus pretium elit. Sed sodales imperdiet velit, vitae viverra erat commodo non. Nunc porttitor risus sit amet quam faucibus, et luctus ex fringilla. Mauris quis urna non lacus tempor iaculis vitae quis dolor. Nam vitae pulvinar lacus, quis varius erat. Etiam lobortis orci vitae elementum tempor. Praesent convallis euismod enim vel vestibulum. Proin vitae eros vitae nisi cursus dapibus vitae at ipsum. Phasellus sed tempor eros, non scelerisque nunc. Nullam condimentum ex ultrices, ultrices ante sit amet, rhoncus nibh. Aliquam fermentum vulputate fringilla. Ut risus orci, pharetra eu tellus vel, fringilla feugiat dolor.

Nunc quis elit quam. Sed aliquet, nibh ut sagittis egestas, lorem tortor laoreet diam, non maximus lectus dolor dignissim eros. Sed vehicula mi id aliquet aliquam. Vestibulum sed lacus et neque dictum convallis in vitae mauris. Etiam varius augue vel mattis tempor. Curabitur mattis facilisis metus, tempus consectetur quam aliquam sed. Mauris velit orci, efficitur sit amet nisl in, finibus dictum elit. In lectus augue, elementum eu sapien sed, auctor tincidunt urna.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Integer lacinia accumsan velit. Duis vel facilisis libero. Cras consequat sit amet mauris ut ultrices. Ut pulvinar sit amet odio sit amet pretium. Nullam tortor ligula, consequat non nisl vitae, rutrum placerat est. Sed finibus interdum justo vel placerat. Cras varius tortor sed justo tempus scelerisque. Praesent facilisis ex vitae iaculis iaculis. Sed consectetur a lectus non condimentum. Etiam id lacus a nulla cursus laoreet. Vivamus ipsum purus, sodales vel metus varius, viverra mollis justo. Nulla facilisi. Vivamus volutpat nunc elit, quis sollicitudin velit ornare sit amet.

Nullam fringilla nisi nunc, vitae accumsan tortor luctus quis. Sed facilisis, est ut eleifend sagittis, felis dolor pellentesque lectus, in congue purus orci non nunc. Nunc finibus eu metus et volutpat. Integer hendrerit tortor et tellus euismod vulputate. Aliquam erat volutpat. Aenean gravida justo in risus feugiat, ut suscipit tortor ullamcorper. Nam a sapien dictum, vestibulum eros vitae, sodales turpis. Interdum et malesuada fames ac ante ipsum primis in faucibus. Sed ultricies at elit et rutrum. Sed placerat erat quis condimentum convallis. Duis ornare magna nec ante faucibus malesuada. Duis a erat sed sapien semper eleifend. Mauris consequat nibh sollicitudin mi euismod, non ultricies lectus bibendum. Cras a erat libero. Aliquam nisl ipsum, scelerisque at risus a, hendrerit vestibulum sapien. Proin luctus diam eu mi lobortis molestie id vel ante."

highlights = [{
  start: 20,
  end: 35,
  comment: 'Foo'
}, {
  start: 73,
  end: 92,
  comment: 'Bar'
}, {
  start: 50,
  end: 98,
  comment: 'Baz'
}]

class HtmlTextHighlight

  def initialize(content, highlights)
    @content = content
    @highlights_content = highlights
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
    @read_highlights_start_and_end = @highlights_content.to_s.scan(/\d+/)
  end

  def read_highlights_comment
    @read_highlights_comment = @highlights_content.to_s.scan(/\b(?![a-z]+\b|[A-Z]+\b)[a-zA-Z]+/)
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
    html_highlight_text = text.sub!(/#{text_replacement}/, "#{html_text}") if !text_replacement&.empty?

    # For highlight spanning between paragraphs
    if !text_replacement&.empty? && !html_highlight_text
      text_content = text.gsub(/<\/?[^>]*>/, "").scan(/\w+/)
      count = text_content.size
      return if (range[0].to_i  > count ||  range[1].to_i > count )
      # start range of highlight
      total_count = text.split.count
      diff = total_count - count
      small_count = range[0].to_i + diff
      color = SecureRandom.hex(3)
      comment_hack = comment
      begin_span = text.split[small_count.to_i...small_count.to_i+2].join(" ").to_s
      html_text = """<div class='tooltip'><mark style='background-color:##{color}'>#{begin_span}"""  if !begin_span&.empty?
      text.sub!(/#{begin_span}/, "#{html_text}") if !begin_span&.empty?
      # end range of highlight
      new_total_count = text.split.count
      diff = new_total_count - count
      large_count = range[1].to_i + diff
      end_span = text.split[large_count.to_i-2...large_count].join(" ").to_s
      large_html_text = """#{end_span} <span class='tooltiptext'>#{comment_hack}</span> </mark></div>"""  if !end_span&.empty?
      html_highlight_text = text.sub!(/#{end_span}/, "#{large_html_text}") if !end_span&.empty?
      return html_highlight_text
    end

    return html_highlight_text
  end

  def html_highlights_to_paragraph
    @html_to_paragraph = @generate_highlights.compact.last.split(/\n\n/).map do |paragraph|
       "<p>#{paragraph}</p>"
    end
    write_html_highlights_to_file(@html_to_paragraph)
  end

  def stylesheet
    """<style>
    .tooltip {
     position: relative;
   }

  .tooltiptext {
       visibility: hidden;
       width: 120px;
       background-color: black;
       color: #fff;
       text-align: center;
       border-radius: 6px;
       padding: 5px 0;
       /* Position the tooltip */
       position: absolute;
       z-index: 1;
       margin-top: 15px;
     }
     div p span.tooltiptext{
      right: 50px
    }

     div {
      display: inline-table;
     }
     p div span.tooltiptext {
       display: inline
     }
     span:hover .tooltiptext {
       visibility: visible;
     }
     div:hover .tooltiptext {
      visibility: visible;
    }
   </style>"""
  end

  def js_script
    """
    <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js'></script> 
       <script>
               $(document).ready(function() {
                var color = $('mark').css( 'background-color' );
                $('mark').children().css({backgroundColor: color})
                $('div.tooltip').prev().css({
                    'display': 'inline'
                });
                $('span.tooltip span.tooltip').hover(function() {
                  $(this).find('span.tooltiptext').css({'display': 'inline'})
                  $(this).closest('span.tooltip span.tooltiptext').css({'display': 'inline'})
                }, function() {
                  $(this).find('span.tooltiptext').css({'display': 'none'})
                })

                $('span.tooltip').hover(function() {
                  $(this).find('span.tooltip span.tooltiptext').css({'display': 'none'})
                }, function() {
                  $(this).find('span.tooltip span.tooltiptext').css({'display': 'inline'})
                })
            });
        </script>
    """
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



html_text_hightlight = HtmlTextHighlight.new(content, highlights)
html_text_hightlight.execute

