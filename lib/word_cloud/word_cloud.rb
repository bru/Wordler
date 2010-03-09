module WordCloud
  
class WordCloud < Cloud
  
  def initialize(args= { :smallest => 1.2, :largest => 3.5, :unit => "em"})
    # convert units to pt
    case args[:unit]
    when "px"
      args[:smallest] = args[:smallest] / 96 * 25.4 / 0.35146 # divide by DPI to get inches, multiply by 25.4 to get mm, divide by 0.35416 to get points
      args[:largest] = args[:largest] / 96 * 25.4 / 0.35416 # divide by  DPI to get inches, multiply by 25.4 to get mm, divide by 0.35416 to get points
      args[:unit] = "pt"
    when "em"
      args[:smallest] *= 12 # assume 12pt base letter
      args[:largest] *= 12;
      args[:unit] = "pt";
    end
    
    # default values for WordCloud specific properties
    
    defs = {
      :font => 'fonts/optima.ttf',
      :fgcolor => "#CCCCCC",
      :fgcolor2 => "#2D2D2D",
      :bgcolor => "#FFFFFF",
      :transparent => false,
      :percentup => 40,
      :maxwidth => 500,
      :margin => 3,
      :number => 200
    }
    
    # merge the args with the default values
    @args = defs.merge args
    
    # init parent
    super(@args[:maxwidth])
    
    # init tag array
    @tags = []
    
  end
  
  def setTags(tags)
    
    counts = {}
    minCount = maxCount = 0
    tags.each do |tag, weight|
      counts[tag] = weight
    end
    
    minCount = tags.map {|k,v| v}.min
    maxCount = tags.map {|k,v| v}.max
    
    tags.each do |tag, weight|
      # get word values by merging cloud default values with tag specific values
      # vals = args.merge tag # FIXME
      weight = weight
      vals = {}
      
      # set angle. rotate box based on chance
      p = rand(100)
      vals[:angle] = p < @args[:percentup] ? 90 : 0
      
      # calculate ratio of size
      if (maxCount - minCount <= 0)
        ratio = 0.5
      else
        ratio = (weight - minCount).to_f / (maxCount - minCount).to_f
      end
      
      # set font size
      vals[:size] = @args[:smallest] + ratio * (@args[:largest] - @args[:smallest])
      
      # calculate colour
      if (@args[:fgcolor2] && @args[:fgcolor2] != "")
        # color to hex array
        rgb  = /(..)(..)(..)/.match(@args[:fgcolor][-6,6])[1,3].map { |s| s.hex }
        rgb2 = /(..)(..)(..)/.match(@args[:fgcolor2][-6,6])[1,3].map { |s| s.hex }
        
        # calculate color in decimals
        rgb[0] = rgb[0] + (ratio * (rgb2[0] - rgb[0])).round
        rgb[1] = rgb[1] + (ratio * (rgb2[1] - rgb[1])).round
        rgb[2] = rgb[2] + (ratio * (rgb2[2] - rgb[2])).round
        
        vals[:fgcolor] = rgb.map { |i| i.to_s(16) }.join('')
      end
      word = Word.new(vals, tag, weight)
      self.add(word, false)
      
    end
  end
  
  def getImage(cachedir="")
    self.layout
    self.moveTo(Point.new(0,0))
    
    list = Magick::ImageList.new
    list.new_image(@width, @height)
    for box in @boxes
      i = box.getImage
      i.page = Magick::Rectangle.new(box.width, box.height, box.ul.x, box.ul.y) 
      list << i
    end
    # XXX flatten images and return result
    return list.flatten_images
  end

  
  def getHTML(cachedir="")
    # calculate cache file name
    # FIXME: let's think later about cache
    
    # make sure cloud layout is set properly
    self.layout
    self.moveTo(Point.new(0,0))
    
    html = "<div class='tag-cloud'><div style='position: relative; height: #{@height}px; width: #{@width}px;'>"
    for box in @boxes
      html += box.getHTML
    end
    
    html += "</div></div>"
    
    # FIXME: update cache
    
    return html 
  end
  
end
end