# Assignment-Answers
Assigment #1 - Creating Objects

ASSIGNMENT:

There are three tab-delimited data files:
1. seed_stock_data.tsv
2. gene_information.tsv
3. cross_data.tsv

#1 contains information about seeds in your genebank
#2 contains information about genes
#3 contains information about the crosses you have made

Each file begins with a heading line, followed by lines of data

Your task is to use Object-oriented programming to achieve two things:
1) "simulate" planting 7 grams of seeds from each of the records in the seed stock genebank
then you should update the genebank information to show the new quantity of seeds
that remain after a planting. The new state of the genebank
should be printed to a new file, using exactly the same format as the
original file seed_stock_data.tsv

-- if the amount of seed is reduced to zero or less than zero, then
a friendly warning message should appear on the screen. The amount
of seed left in the gene bank is, of course, not LESS than zero guiño


2) process the information in cross_data.tsv and determine which genes are
genetically-linked. To achieve this, you will have to do a Chi-square test
on the F2 cross data. If you discover genes that are linked, this information
should be added as a property of each of the genes (they are both linked to each
other).

***************************************

Hints:
*** You will need to create 3 Objects:
1. A Class for the Gene
2. A Class for the SeedStock
3. A Class for the Hybrid Cross

*** the values of some Object Properties will be other Objects

*** the seed_stock ID is the key to link seed_stock_data->cross_data

*** the GeneID is the key to link gene_information->seed_stock_data

BONUS SCORES
+1% if your Gene Object tests the format of the Gene Identifier and rejects incorrect formats without crashing Arabidopsis gene identifiers have the format /A[Tt]\d[Gg]\d\d\d\d\d/ If the identifier isn't correct, then your code should stop with a helpful error message

+1% if you create an Object that represents your entire Seed Stock "database"

the object should have a #load_from_file($seed_stock_data.tsv)
the object should access individual SeedStock objects based on their ID (e.g. StockDatabase.get_seed_stock('A334')
the object should have a #write_database('new_stock_file.tsv')
