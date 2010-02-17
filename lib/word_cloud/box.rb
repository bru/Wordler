module WordCloud
  class Box
    # ul - upper left corner
    # lr - lower right corner
    # height - height of the box
    # width - width of the box
    # parent - owner of the box
    # inPosition - marker to indicate wether this box has been placed in a Cloud
    attr_accessor :ul, :lr, :height, :width, :parent, :inPosition
    
    def initialize(h, w)
      @ul = Point.new(0,0)
      @lr = Point.new(w, h)
      @height = h
      @width = w
      @inPosition = false
    end
    
    # move the box to a specific coordinate
    def moveTo(p)
      @ul = p.clone
      @lr = p.clone
      @lr.translate(@width, @height)
    end
    
    # move the box
    def translate(x,y)
      @ul.translate(x,y)
      @lr.translate(x,y)
    end
    
    # signal if this box overlaps with the provided box
    def overlaps(box)
      return !(
      box.lr.above(@ul)  ||
      box.lr.leftOf(@ul) ||
      box.ul.below(@lr)  ||
      box.ul.rightOf(@lr))
    end
    
    # gives the coordinates of all corners this box
    def corners
      points = []
      points << @ul.clone
      points << Point.new(@ul.x, @lr.y)
      points << @lr.clone
      points << Point.new(@lr.x, @ul.y)
      return points
    end
    
  end
end