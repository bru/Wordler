module WordCloud
  class Point
    attr_accessor :x, :y
    
    def initialize(px, py)
      @x = px
      @y = py
    end
    
    def above(p)
      @y < p.y
    end
    
    def below(p)
      @y > p.y
    end
    
    def leftOf(p)
      @x < p.x
    end
    
    def rightOf(p)
      @x > p.x
    end
    
    def moveTo(p)
      @x = p.x
      @y = p.y
    end
    
    def translate(dx, dy)
      @x += dx
      @y += dy
    end
    
  end
end
