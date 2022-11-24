require 'E:\Miriam\Máster UPM\Bioinformatics programming\Assignement_1\Seedstockinformation.rb'
require 'E:\Miriam\Máster UPM\Bioinformatics programming\Assignement_1\Crossdatainformation.rb'
require 'E:\Miriam\Máster UPM\Bioinformatics programming\Assignement_1\Geneinformation.rb'
require 'csv'

#Parse seed_stock_data.tsv into a variable and transpose columns to rows.
parsed_file = CSV.read("/home/osboxes/BioinformaticsRetos-1-4/seed_stock_data.tsv", { :col_sep => "\t" })
transposed = parsed_file.transpose

#Separate each result in different arrays and eliminate the first row (the header).
first = transposed[0]
one=first.drop(1)

second = transposed[1]
two=second.drop(1)

third = transposed[2]
three=third.drop(1)

fourth = transposed[3]
four=fourth.drop(1)

fifth = transposed[4]
five=fifth.drop(1)

#Create seeds information. 
seed1 = Seedstockinformation.new(one[0],two[0], three[0], four[0], five[0].to_i)
seed2 = Seedstockinformation.new(one[1],two[1], three[1], four[1], five[1].to_i)
seed3 = Seedstockinformation.new(one[2],two[2], three[2], four[2], five[2].to_i)
seed4 = Seedstockinformation.new(one[3],two[3], three[3], four[3], five[3].to_i)
seed5 = Seedstockinformation.new(one[4],two[4], three[4], four[4], five[4].to_i)

#Plant seeds (7 gr.).
seed1.plantseed
seed1.plantseed
seed3.plantseed
seed4.plantseed
seed5.plantseed

#Update db.
file = File.open("seed_stock_update.tsv", "w")
file.puts("Seed_Stock\tMutant_Gene_ID\tLast_planted\tStorage\tGrams_Remaining")
seed1.writeseed(file)
seed2.writeseed(file)
seed3.writeseed(file)
seed4.writeseed(file)
seed5.writeseed(file)
file.close

#Parse cross_data.tsv into a variable and transpose columns to rows.
parsed_file = CSV.read("/home/osboxes/BioinformaticsRetos-1-4/cross_data.tsv", { :col_sep => "\t" })
parsed_file[1]
transposed = parsed_file.transpose

#Separate each result in different arrays and eliminate the first row (the header).
first = transposed[0]
one=first.drop(1)

second = transposed[1]
two=second.drop(1)

third = transposed[2]
three=third.drop(1)

fourth = transposed[3]
four=fourth.drop(1)

fifth = transposed[4]
five=fifth.drop(1)

sixth = transposed[5]
six=sixth.drop(1)

#Create crossdata information. 
cross1 = Crossdatainformation.new(one[0],two[0], three[0].to_i, four[0].to_i, five[0].to_i, six[0].to_i)
cross2 = Crossdatainformation.new(one[1],two[1], three[1].to_i, four[1].to_i, five[1].to_i, six[1].to_i)
cross3 = Crossdatainformation.new(one[2],two[2], three[2].to_i, four[2].to_i, five[2].to_i, six[2].to_i)
cross4 = Crossdatainformation.new(one[3],two[3], three[3].to_i, four[3].to_i, five[3].to_i, six[3].to_i)
cross5 = Crossdatainformation.new(one[4],two[4], three[4].to_i, four[4].to_i, five[4].to_i, six[4].to_i)

#Calculating the Chi-square values
cross1.chi_value
cross2.chi_value
cross3.chi_value
cross4.chi_value

#Parse gene_information.tsv into a variable and transpose columns to rows.
parsed_file = CSV.read("/home/osboxes/BioinformaticsRetos-1-4/gene_information.tsv", { :col_sep => "\t" })
transposed = parsed_file.transpose

#Separate each result in different arrays and eliminate the first row (the header).
first = transposed[0]
one=first.drop(1)

second = transposed[1]
two=second.drop(1)

third = transposed[2]
three=third.drop(1)


#Create geneinformation information. 
gene1 = Geneinformation.new(one[0],two[0], three[0])
gene2 = Geneinformation.new(one[1],two[1], three[1])
gene3 = Geneinformation.new(one[2],two[2], three[2])
gene4 = Geneinformation.new(one[3],two[3], three[3])
gene5 = Geneinformation.new(one[4],two[4], three[4])
