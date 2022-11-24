class Protein 

  attr_accessor :gene
  attr_accessor :name
  attr_accessor :pathway_hash
  attr_accessor :go_hash
  attr_accessor :interact_with

  def initialize (gene = "", name = [], go_hash = Hash.new, pathway_hash = Hash.new, interact_with = [])
    @gene = gene
    @name = name
    @go_hash = go_hash
    @pathway_hash = pathway_hash
    @interact_with = interact_with
  end

  def set_interact_with(proteins)
    if proteins
      proteins.each do |protein|
        if !@name.include? protein
          @interact_with.push protein
        end
      end
    end
  end

end



class Network
    attr_accessor :proteins

end


def initialize (proteins = "", pathways_dict = [], gos_dict = Hash.new)
    @proteins = proteins


end


require 'net/http'
require 'json'

#Open the file.
genes = File.read('/home/osboxes/Retos_Assignments_JLR/ArabidopsisSubNetwork_GeneList.txt').split("\n")

#Generate proteins matrix.
proteins = []
proteins_names = []

#Counter.
i = 0


genes.each do |gene|
  #Proteins IDs of each gene.
  accessions_uri = URI("http://togows.org/entry/ebi-uniprot/#{gene}/accessions.json")

  accessions_text = Net::HTTP.get_response(accessions_uri)
  gene_prot_names = JSON.parse(accessions_text.body).flatten

  #puts "#############SELECTING GO TERMS AND KEGG PATHWAYS############################"

  #GO terms of each gene. 
  go_uri = URI("http://togows.org/entry/ebi-uniprot/#{gene}/dr.json")
  go_text = Net::HTTP.get_response(go_uri)
  go_terms = JSON.parse(go_text.body)[0]["GO"]
  #puts go_terms


  #Select only "biological process" GO terms. 
  go_hash = Hash.new
  if go_terms
    go_terms.each do |term|
      if term[1][/P:/]
        go_hash[term[0]] = term[1]
      end
    end
  end


  #Kegg Pathways of each genes. 
  kegg_uri = URI("http://togows.org/entry/kegg-enzyme/ath:#{gene}.json")
  kegg_text = Net::HTTP.get_response(kegg_uri).body
  kegg_hash = JSON.parse(kegg_text)[0]["pathways"]


  proteins.push(Protein.new(gene, gene_prot_names, go_hash, kegg_hash))
  proteins_names.push(gene_prot_names)
  i += 1
  #puts i
end

#Flatten the array of protein names
proteins_names = proteins_names.flatten

puts "#################INTERACTIONS##################################"

#Interactions.

#Direct interactions of each protein of the list.
interactions = []

proteins.each do |protein|
  protein.name.each do |name|
    interact_uri = URI("http://togows.org/entry/ebi-uniprot/#{name}/dr.json")
    interact_text = Net::HTTP.get_response(interact_uri).body
    data = JSON.parse(interact_text)
    int_act = data[0]["IntAct"]
    if int_act
      int_act.each do |int|
        protein_inter_address = URI("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{int[0]}")
        protein_inter_text = Net::HTTP.get_response(protein_inter_address).body
        proteins_inter_line = protein_inter_text.split("\n").select{|x| /^uniprotkb/.match x}
        proteins_inter_line.each do |line|
          words = line.split("\t")
          prot_id = words[0].split(":")[1]

          interactions.push(prot_id)

          prot_id = words[1].split(":")[1]
          if proteins_names.include? prot_id
            interactions.push(prot_id)
          end
        end
      end
    end
  end

  #remove redundancies

  protein.set_interact_with(interactions.uniq)
  if protein.interact_with
    puts protein.gene + " directly interacts with: " + protein.interact_with.inspect

  end
end

puts "#######################NETWORKS####################################"
networks = []
proteins_interacted=[]
proteins.each do |prot1|
        networks.push (prot1)
    proteins.each do |prot2|
        if prot1 != prot2 && !prot1.interact_with.empty? && !prot2.interact_with.empty?
            prot1.interact_with.each do |prot_int|
                if prot2.name.include? prot_int
                    proteins_interacted.push(prot2)
                    break
                end
            end
        end

    end
    networks.push(Network.new(proteins_interacted))
end


puts networks.inspect



