require 'bio'
require 'rest-client'


def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
    response = RestClient::Request.execute({
        method: :get,
        url: url.to_s,
        user: user,
        password: pass,
        headers: headers})
    return response
    
    rescue RestClient::ExceptionWithResponse => e
        $stderr.puts e.inspect
        response = false
        return response 
    rescue RestClient::Exception => e
        $stderr.puts e.inspect
        response = false
        return response 
    rescue Exception => e 
        $stderr.puts e.inspect
        response = false
        return response 
end 

"################FETCH DONE#########################"


def read_gene_list(path)
    
    puts "Gene list..."
    gene_array = []
    
    begin
        IO.foreach(path) do |gene|
            gene.strip!.downcase!
            gene_array |= [gene.to_sym] if gene =~ /at\wg\d\d\d\d\d/ 
        end
        return gene_array 
    rescue Errno::ENOENT => e 
        puts "ERROR:file not found"
        $stderr.puts e.inspect
        return nil
    rescue Exception => e 
        $stderr.puts e.inspect
        return nil
    end
end

"################READ GENE LIST DONE#######################"

def get_embl(gene_array)
    unless gene_array && !gene_array.empty? 
        puts "WARNING: no genes in array¡¡¡¡"
        return nil
    end
    # else 
    puts "Getting the EMBL entries..."
    embl_hash = {} 
    gene_array = [gene_array] unless gene_array.is_a?(Array) 
    gene_array.each do |gene_id| 
        
        url = "https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}&style=raw"
        response = fetch(url) 
        if response
            entry = Bio::EMBL.new(response.body) 
            unless embl_hash.keys.include?(gene_id)
                embl_hash[gene_id] = entry 
            else
                puts "WARNING: #{gene_id} already contains an embl_hash entry¡¡¡¡"
            end
        end
    end
    return embl_hash 
end

"#######################GENE ARRAY DONE##################################"

def create_and_add_features(biosequence, gene_id, positions_array, strand)
    
    positions_array.uniq.each_with_index do |position_pair, index|
        start_pos, end_pos = *position_pair
        # creating the position string
        if strand == +1 || strand == "+" || strand == "+1"
            position_string = "#{start_pos}..#{end_pos}"
            strand_label = "+"
        elsif strand == -1 || strand == "-" || strand == "-1"
            position_string = "complement(#{start_pos}..#{end_pos})"
            strand_label = "-"
        else
            puts "WARNING: For #{gene_id}, the strand parameter was #{strand}. '+1' or '+' for the forward strand;'-1' or '-' for the reverse strand"
            next
        end

        new_feature = Bio::Feature.new(feature = "CTTCTT_direct_repeat", position = position_string, 
                                        qualifiers = [Bio::Feature::Qualifier.new('sequence', 'CTTCTT'),
                                                        Bio::Feature::Qualifier.new('strand', strand_label),
                                                        Bio::Feature::Qualifier.new('ID', "#{gene_id.to_s.upcase}.CTTCTT_repeat.#{strand_label}.#{index + 1}")])
                                                       
        biosequence.features << new_feature
    end
    
end

"#####################CREATE FEATURES DONE#########################"

def find_seq_in_exons(embl_hash)
    puts "Looking for CTTCTT in the entries..."
    new_embl_hash = {} 

    embl_hash.each do |gene_id, bio_embl| 

        bio_embl_as_biosequence = bio_embl.to_biosequence 
        embl_seq = bio_embl.seq 

        all_positions_forward = [] 
        all_positions_reverse = [] 

        
        bio_embl.features.each do |feature| 
            next unless feature.feature == "exon" 
            next unless feature.assoc["note"].match(Regexp.new(gene_id.to_s, "i")) 

            bio_location = feature.locations[0] 
            exon_start_pos, exon_end_pos = bio_location.from, bio_location.to 

            exon_seq = embl_seq.subseq(exon_start_pos, exon_end_pos) 

            if bio_location.strand == +1 
                
                start_f = exon_seq.enum_for(:scan, /(?=(cttctt))/i).map { Regexp.last_match.begin(0) + 1} 
                
                next if start_f.empty? 
                
                positions_f = start_f.map {|pos| [pos + exon_start_pos - 1, pos + exon_start_pos -1 + 5]} unless start_f.empty? 
                all_positions_forward |= positions_f 

            elsif bio_location.strand == -1 
               
                start_r = exon_seq.enum_for(:scan, /(?=(aagaag))/i).map { Regexp.last_match.begin(0) + 1} # 1-indexed

                next if start_r.empty? 
                
                positions_r = start_r.map {|pos| [pos + exon_start_pos - 1, pos + exon_start_pos -1 + 5]} unless start_r.empty? 
                all_positions_reverse |= positions_r 
            else
                puts "WARNING: No strand¡¡¡"
                next 
            end
        end
        
        create_and_add_features(bio_embl_as_biosequence, gene_id, all_positions_forward, "+")
        create_and_add_features(bio_embl_as_biosequence, gene_id, all_positions_reverse, "-")
        
        unless all_positions_forward.empty? && all_positions_reverse.empty? 
            new_embl_hash[gene_id] = bio_embl_as_biosequence unless new_embl_hash.keys.include?(gene_id)
        end
    end
    return new_embl_hash # return the new embl hash
end

"###################SEQ FOUND IN EXONS###################################"


def write_gff3_local(new_embl_hash, filename = "CTTCTT_GFF3_gene.gff")
    write_gff3(new_embl_hash, mode = "local", filename = filename)
end


def write_gff3_global(new_embl_hash, filename = "CTTCTT_GFF3_chromosome.gff")
    write_gff3(new_embl_hash, mode = "global", filename = filename)
end


def write_gff3(new_embl_hash, mode, filename)

    
    puts "Writing GFF3 file..."

    puts "WARNING: mode isn't 'local' or 'global', the default 'local' will be used" if mode != "local" && mode != "global"

    source = "BioRuby"
    type = "direct_repeat"
    score = "."
    phase = "."

    f = File.new(filename, "w")
    f.write("##gff-version 3\n") 
    
    new_embl_hash.each do |gene_id, biosequence|
        biosequence.features.each do |feature|
            next unless feature.feature == "CTTCTT_direct_repeat" 

            
            bio_location = feature.locations[0]
            
            if mode == "global"
                seqid = "Chr#{gene_id.to_s[2]}"
                chr_start_pos = biosequence.primary_accession.split(":")[3].to_i 
                start_pos = (chr_start_pos + bio_location.from.to_i - 1).to_s 
                end_pos = (chr_start_pos + bio_location.to.to_i - 1).to_s 
            else 
                seqid = gene_id.to_s.upcase
                start_pos = bio_location.from
                end_pos = bio_location.to
            end
            
            strand = feature.assoc["strand"]
            attributes = "ID=#{feature.assoc["ID"]};Name=#{feature.feature};"

            
            elements = [seqid, source, type, start_pos, end_pos, score, strand, phase, attributes]
            entry = elements.join("\t") + "\n"
            f.write(entry)
        end
    end
    f.close
end

"#############################GFF FILES GENERATED########################"


def write_report(gene_array, new_embl_hash, filename = "list do NOT have exons with the CTTCTT repeat_report.txt")
    puts "Writing the report..."
    # getting the genes from gene_array that aren't in new_embl_hash
    not_feature_genes = gene_array.select {|gene_id| !new_embl_hash.keys.include?(gene_id)} 
    f = File.new(filename, "w") # opening the file
    f.write("Number of initial genes: #{gene_array.length}\n")
    f.write("Number of genes without CTTCTT in any exon: #{not_feature_genes.length}\n")
    f.write("List of genes: \n")
    not_feature_genes.each do |gene_id|
        f.write("#{gene_id}\n")
    end
    f.close # closing the file
end

"#############################REPORT GENERATED##########################"



if ARGV.length < 1
    puts "You need to include the input gene list as an argument"
    abort
end

gene_array = read_gene_list(path = ARGV[0])
embl_hash = get_embl(gene_array)
new_embl_hash = find_seq_in_exons(embl_hash)
write_gff3_local(new_embl_hash, filename = "CTTCTT features_GFF3_gene.gff")
write_gff3_global(new_embl_hash, filename = "CTTCTT features_GFF3_chromosome.gff")
write_report(gene_array, new_embl_hash, filename = "list do NOT have exons with the CTTCTT repeat_report.txt")


# To execute in the terminal put--> ruby GFF_Assignment_Code.rb ../Assignment3/ArabidopsisSubNetwork_GeneList.txt

