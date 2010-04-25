module WordCloud
  class Word < Box
    attr_accessor :values

    def initialize(args,tag,weight)
      defaults = { 
        :name => tag,
        :size => weight,
        :margin => 1,#3,
        :angle => 0,
        :fgcolor => "000000",
        :bgcolor => "FFFFFF",
        :font => "font/arial.ttf",
        :transparent => true
      }
      @values = defaults.merge args
      @box = calculateTextBox(@values[:size], @values[:angle], @values[:font], @values[:name])
      super(@box[:height], #+1+2*@values[:margin], 
            @box[:width] # +2+2*@values[:margin]
            )
    end
    
    def calculateTextBox(font_size, font_angle, font_file, text)
      image = Magick::Image.new(50, 100)
      draw  = Magick::Draw.new
      draw.pointsize = font_size
      # if (font_angle != 0)
      #   draw = draw.rotate(-90)
      # end
      box = draw.get_type_metrics(image, text)
      textheight = (box.ascent * 0.85) - box.descent
      width = (font_angle == 0) ? box.width : box.height
      height =  (font_angle == 0) ? textheight : box.width      
      image.destroy!
      
      return { :left => -1, 
          :top => 1,
          :width => width,
          :height => height,
          :box => box
        }
    end
    
    def rotate
      @values[:angle] = (@values[:angle] == 0 ? -90 : 0)
      @box = calculateTextBox(@values[:size], @values[:angle], @values[:font], @values[:name])
      # FIXME: should be using super's initialize
      @ul = Point.new(0,0)
      # @lr = Point.new(@box[:width]+2+2*@values[:margin], @box[:height]+1+2*@values[:margin])
      @lr = Point.new(@box[:width],#+2, 
                      @box[:height])
      
      @height = @box[:height]#+1+2*@values[:margin]
      @width = @box[:width]#+2+2*@values[:margin]
      @inPosition = false 
      # end of hack
    end
    

    def getImage
      # create the image
      box = calculateTextBox(@values[:size], @values[:angle], @values[:font], @values[:name])
      h = box[:box].height # + @values[:margin]
      w = box[:box].width + 2*@values[:margin]
      # create the colors
      fgcolor = "#" + @values[:fgcolor]
      bgcolor = "#" + @values[:bgcolor]
      # font pointsize
      fontsize = @values[:size].to_i
      
      
      # image : fake image to set the annotation size
      image = Magick::Image.new(w,h){
        self.background_color = bgcolor
      }
      # write text
      text = Magick::Draw.new
      text.pointsize = fontsize
      
      text.fill = fgcolor
      text.annotate(image, 0, 0, @values[:margin], h*0.75, @values[:name]) { # was h - @values[:margin]  - 5
        # more options?
      }
      
      # rotate canvas
      if (@values[:angle] != 0)
        image.rotate!(-90)
      end
      
      # set transparent color
      if @values[:transparent]
        image = image.transparent(bgcolor)
      end
      
      # return image
      return image
    end
    
    def getHTML(prefix = "")
      require 'digest/md5'
      # create image if it does not exist
      # FIXME - just cache the final image
      # hash = Digest::MD5.hexdigest(@values.to_query)
      cachefile =  prefix + @values[:name] + ".gif"
      
      #FIXME add check for existing files
      im = getImage
      im.write("public/words/" + cachefile)
      height = im.rows
      width = im.columns
      im.destroy!
      
      # get image html info
      # get link html info
      
      # create html
      url = "/words/" + cachefile
      title = "tags"
      top  = @ul.y
      left = @ul.x
      img = "<img src='#{url}' alt='#{title}' style='border: 0px none; height:#{height}px; width:#{width}px;' />";
      a = "<a href='#' class='tag-link-#{@values[:name]} tag-link' style='top:#{top}px; left:#{left}px; border: 0px none; position:absolute;' title='#{title}' >#{img}</a>";
      return a
    end
    
  end
end