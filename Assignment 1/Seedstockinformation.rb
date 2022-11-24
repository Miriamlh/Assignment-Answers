class Seedstockinformation
  

  attr_accessor :seedstock 
  attr_accessor :mutantgene
  attr_accessor :lastplanted
  attr_accessor :storage
  attr_accessor :gramsremaining
  

  # First, an empty list is generated. Then, a name is got from the new entry, or set a default.
  def initialize (thisseed = "A seed", thismutant = "A mutant", planted = "********", stored="somewhere", remain="a quantity")  
    @seedstock = thisseed
    @mutantgene = thismutant
    @lastplanted = planted
    @storage=stored
    @gramsremaining = remain
    
  end

def seedstock
    @seedstock
  end
  
  def mutantgene
    @mutantgene
  end
  
  def lastplanted
    @lastplanted
  end
  
  def storage
    @storage
  end
  
  def gramsremaining
    @gramsremaining
  end

  def plantseed
    if @gramsremaining > 7
       @gramsremaining -= 7
    else
      puts "FRIENDLY WARNING: No seeds left in the bank " + @seed_stock
      @gramsremaining = 0
    end
  end
  
  def writeseed(file)
    file.puts(@seedstock + "\t" + @mutantgene + "\t" + @lastplanted + "\t" + @storage +"\t" + @gramsremaining.to_s)
  end
end
