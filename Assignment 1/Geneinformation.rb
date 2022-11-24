class Geneinformation

  attr_accessor :geneid 
  attr_accessor :genename
  attr_accessor :mutantphenotype
  
  
  def initialize (id = "An ID", name = "A name", phenotype = "A phenotype")
    @geneid = id
    @genename = name
    @mutantphenotype = phenotype
  end
  
  
end
