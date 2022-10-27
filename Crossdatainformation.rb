require 'E:\Miriam\Máster UPM\Bioinformatics programming\Assignement_1\Seedstockinformation.rb'
require 'E:\Miriam\Máster UPM\Bioinformatics programming\Assignement_1\Geneinformation.rb'

class Crossdatainformation 

  attr_accessor :p1
  attr_accessor :p2
  attr_accessor :f2wild
  attr_accessor :f2p1
  attr_accessor :f2p2
  attr_accessor :f2p1p2
  attr_accessor :linked
  
  def initialize (thisparent = "A parent", thisotherparent = "A parent", f2wildtype = "Something", f2parent1="Something", f2parent2="Something", f2both ="Something", link=false)
    @p1 = thisparent
    @p2 = thisotherparent
    @f2wild = f2wildtype
    @f2p1=f2parent1
    @f2p2 = f2parent2
    @f2p1p2 = f2both
    @linked = link
  end
    
  
  def chivalue
    total_value = @f2wild + @f2p1 + @f2p2 + @f2p1p2
    
    expectedWT = 9/16.0*(total_value)
    int_chisquare1=(@f2wild.to_f-expectedWT.to_f)**2 / expectedWT.to_f
    
    expectedP1 = 3/16.0*(total_value)
    int_chisquare2=(@f2p1.to_f-expectedP1.to_f)**2 / expectedP1.to_f
    
    expectedP2 = 3/16.0*(total_value)
    int_chisquare3=(@f2p2.to_f-expectedP2.to_f)**2 / expectedP2.to_f
    
    expectedP1P2 = 1/16.0*(total_value)
    int_chisquare4=(@f2p1p2.to_f-expectedP1P2.to_f)**2 / expectedP1P2.to_f
    
    chivalue = int_chisquare1 + int_chisquare2 + int_chisquare3 +int_chisquare4
    
        
    if chivalue > 7.815
      @linked = true
      puts "\n" + @p1 + " and " +  @p2 + " are linked with chi-square value of" + chivalue.to_s + "\n\n "
      
      puts "Final report:\n" + @p1 + " is linked to " +  @p2
      puts "\n" + @p2 + " is linked to " +  @p1

    end
  end



end