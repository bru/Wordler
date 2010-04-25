module WordCloud
  class Cloud < Box
    attr_accessor :maxWidth
    attr_accessor :boxes
    
    def initialize(mW = -1)
      super(0,0)
      @boxes = []
      @points = []
      @maxWidth = mW
    end
    
    # Adds a Box to the cloud
    # box is the box to place
    # layout set to true to give to Box a position in the cloud
    def add(box, doLayout = true)
      # add the box
      @boxes << box
      box.inPosition = false
      box.parent = self
      
      if doLayout
        findSpot(box)
      end
    end
    
    # places all unplaced boxes in the wordcloud 
    def layout
      for box in @boxes
        if !box.inPosition
          findSpot(box)
        end
      end
    end
    
    # places a single Box in the cloud
    # box is the Box to place
    # return true if placement was successfull, false otherwise
    def findSpot(box)
      spotFound = false
      
      if @points.size == 0
        #sp = Point.new(0,0)
        spotFound = checkSpot(box)
      else
        #extend list of possible attachpoint with all corners of the Box
        # make sure the cloud doesn't get too wide
        if !in_shape? && box.values[:angle] == 0
          box.rotate
        end
        pss=createSpotGroup(box)
        spotFound = checkSpotGroup(pss,box)  
        if (!spotFound)
          box.rotate
          pss=createSpotGroup(box)
          spotFound=checkSpotGroup(pss,box)
        end        
      end

      if spotFound
        # mark box as in position
        box.inPosition = true
        
        # add the box attachpoints
        @points = @points.concat box.corners
        
        # recalculate (cloud) box boundaries
        @ul.x = [@ul.x, box.ul.x].min
        @ul.y = [@ul.y, box.ul.y].min
        @lr.x = [@lr.x, box.lr.x].max
        @lr.y = [@lr.y, box.lr.y].max
        
        @height = @lr.y - @ul.y
        @width  = @lr.x - @ul.x
      else
        #puts("XXX WTF????? can't find spot!!!")
      end
      return spotFound
    end
    
    def in_shape?
      @width < (@height *(0.8))
    end
    
    def createSpotGroup(box)
      ps = []
      for p in @points
        p1 = Point.new(p.x - box.width - 1, p.y - box.height - 1)
        p2 = Point.new(p.x, p.y - box.height - 1)
        p3 = Point.new(p.x - box.width - 1, p.y)
        p4 = Point.new(p.x + 1, p.y + 1)
        ps.push p1, p2, p3, p4
      end
      # sort list to have Point closest to origin first
      ps.sort do |a,b|
        lenA = a.x**2 + (2*a.y)**2
        lenB = b.x**2 + (2*b.y)**2
        
        # compare 
        if lenA==lenB
          0
        else
          lenA > lenB ? 1 : -1
        end
      end
      
      # find spot using randomized chunks
      chunkSize = 4
      pss = []
      ps.each_with_index do |k,i| 
        pss[i/chunkSize] ||= []
        pss[i/chunkSize].push k
      end
      return pss
    end
    
    def checkSpotGroup(pss,box)
      spotFound = false
      for aps in pss
        #shuffle the array
        aps.size.downto(1) { |n| aps.push aps.delete_at(rand(n)) }
        # go and find closest fitting spot
        for ap in aps
          box.moveTo(ap)
          if checkSpot(box)
            spotFound = true
            break
          end
        end
        break if spotFound
      end
      return spotFound
    end
    
    # checks if a Box can be placed in the cloud on the given location
    # param box to place
    # return true/false
    def checkSpot(box)
      #validate if the cloud maxwidth isn't violated
      if @maxWidth > 0
        lx = [@ul.x, box.ul.x].min
        rx = [@lr.x, box.lr.x].max
        if((rx - lx) > @maxWidth)
          return false
        end
      end
      
      # validate if the box doesn't overlap other boxes
      ok = true
      for tb in @boxes
        if tb.inPosition && box.overlaps(tb)
          ok = false
          
          break
        end
      end
      return ok
    end
    
    def moveTo(point)
      dx = point.x - @ul.x
      dy = point.y - @ul.y
      
      translate(dx, dy)
    end
    
    def translate(dx,dy)
      super(dx,dy)
      for box in @boxes
        box.translate(dx,dy)
      end
    end
        
  end
end