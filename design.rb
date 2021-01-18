module Design
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
    .hide {
      display: 'none'
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
end