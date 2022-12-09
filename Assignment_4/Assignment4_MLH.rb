require 'bio'

def make_blast_db(fastafilename)
    begin
        fastaff = Bio::FlatFile.auto(fastafilename)
        seq_type = fastaff.next_entry.to_biosequence.guess  
        database_type = 'nucl' if seq_type == Bio::Sequence::NA
        database_type = 'prot' if seq_type == Bio::Sequence::AA
        abort("Unknown type of database encountered by make_blast_db with the file #{fastafile}") unless seq_type == Bio::Sequence::NA || seq_type == Bio::Sequence::AA
        filename_without_ext = fastafilename.split(/\.(?!\/)/).first 
        command = "makeblastdb -in #{fastafilename} -dbtype '#{database_type}' -out #{filename_without_ext}"
        puts "\nCommand: \n #{command}"
        system(command)
        return {fasta_file: fastafilename,
                fasta_file_no_ext: filename_without_ext,
                db_type: database_type}
    rescue Errno::ENOENT => e 
        puts "ERROR: file not found #{fastafilename}"
        $stderr.puts e.inspect
        abort
    rescue Exception => e 
        puts "ERROR in make_blast_db"
        $stderr.puts e.inspect
        abort
    end
end



def get_best_reciprocal_hits(db1_hash, db2_hash, evalue = nil, filtering = nil, coverage = nil)

    best_hits_q1_against_db2 = blast_db_against_db(db1_hash, db2_hash, 
        evalue = evalue, filtering = filtering, coverage = coverage)
    best_hits_q2_against_db1 = blast_db_against_db(db2_hash, db1_hash, 
        evalue = evalue, filtering = filtering, coverage = coverage, reverse_hash = best_hits_q1_against_db2)

    reciprocal_hits = {}
    best_hits_q2_against_db1.keys.each do |seq2|
        seq1 = best_hits_q2_against_db1[seq2]
        next unless seq2 == best_hits_q1_against_db2[seq1] 
        reciprocal_hits[seq2] = seq1 
    end
    return reciprocal_hits 
end


def determine_blast_type(type_query_seq, type_db)
    return "blastp" if type_query_seq == "prot" && type_db == "prot" 
    return "blastn" if type_query_seq == "nucl" && type_db == "nucl" 
    return "blastx" if type_query_seq == "nucl" && type_db == "prot" 
    return "tblastn" if type_query_seq == "prot" && type_db == "nucl" 
    abort("This program doesn't support the combination of query type #{type_query_seq} and database type #{type_db}. Only accepts 'nucl' or 'prot'")
end


def coverage_bigger_than_threshold?(query_start, query_end, query_length, threshold)
    coverage = (query_end.to_f - query_start.to_f)/query_length.to_f
    return coverage >= threshold
end


def build_arguments_string(evalue = nil, filtering = nil)
    arguments = ""
    arguments += "-e #{evalue} " if evalue 
    arguments += "-F #{filtering} " if filtering 
    return arguments unless arguments.empty?
    return nil if arguments.empty?
end


def create_factory(blast_type, database, arguments = nil)
    if arguments.nil? || arguments.empty? 
        factory = Bio::Blast.local(blast_type, database)
    else 
        factory = Bio::Blast.local(blast_type, database, arguments) 
    end
    return factory
end



def blast_db_against_db(db1_hash, db2_hash, evalue = nil, filtering = nil, coverage = nil, reverse_hash = nil)

    arguments = build_arguments_string(evalue = evalue, filtering = filtering)
    blast_type = determine_blast_type(type_query_seq = db1_hash[:db_type], type_db = db2_hash[:db_type])
    factory = create_factory(blast_type, db2_hash[:fasta_file_no_ext], arguments)

    $stderr.puts "Blasting each sequence from #{db1_hash[:fasta_file_no_ext]} against the database #{db2_hash[:fasta_file_no_ext]}..."
    best_hits_q1_db2 = {} 
    db1_ff = Bio::FlatFile.auto(db1_hash[:fasta_file])
    db1_ff.each_entry do |entry|

        if reverse_hash 
            next unless reverse_hash.value?(entry.definition.split("|").first.strip.to_sym)
        end

        report = factory.query(entry)
        next if report.hits.empty? 
        best_hit = report.hits.first
        unless coverage.nil?
            next unless coverage_bigger_than_threshold?(query_start = best_hit.query_start,
                                                        query_end = best_hit.query_end,
                                                        query_length = best_hit.query_len, 
                                                        threshold = coverage) 
        end
        seq1 = entry.definition.split("|").first.strip.to_sym 
        seq2 = best_hit.definition.split("|").first.strip.to_sym
        best_hits_q1_db2[seq1] = seq2 
    end
return best_hits_q1_db2 
end

#
# Write a report with the best reciprocal hits found in the analysis, in a .tsv format.
#

def write_report(best_reciprocal_hits, output_name = "MLH_Assignment4_report.tsv")
    f = File.new(output_name, "w")
    best_reciprocal_hits.each do |seq1, seq2|
        f.write("#{seq1}\t#{seq2}\n")
    end
    f.close
end

abort("Include both databases. Command must be: ruby Assignment4_MLH.rb ./blast_databases/arabidopsis_thaliana.fa ./blast_databases/schizosaccharomyces_pombe.fa") if ARGV.length < 2

#Getting arguments
db1 = ARGV[0]
db2 = ARGV[1]
# Creating the blast databases 
db1_hash = make_blast_db(db1)
db2_hash = make_blast_db(db2)
# Getting the best reciprocal hits
    # From https://doi.org/10.1093/bioinformatics/btm585
    # They recommend an E-value threshold of 1*10^-6
    # and that there is a query coverage of at least 50%.
    # As shown by their results, the recommended parameters for the best ortholog detection is the combination of soft filtering with a final Smith-Waterman alignment (the -F "m S" -s T options in NCBI's BLASTP). 
    #These options result in a higher number of orthologs and lower error rates. 
MLH = get_best_reciprocal_hits(db1_hash, db2_hash, evalue = "1e-6", filtering = "'m S'", coverage = 0.5)
# Writing the report
write_report(MLH)
