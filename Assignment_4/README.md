Assignment 4. Command to run:

ruby Assignment4_MLH.rb ./blast_databases/schizosaccharomyces_pombe.fa ./blast_databases/arabidopsis_thaliana.fa

The results of the analysis are in MLH_Assignment4_report.tsv

---------------

About the fasta files:

In this case, the fasta files provided for Arabidopsis and S. pombe don't have the problem we mentioned in class about the non-unique identifiers.

---------------

About the parameters:

From https://doi.org/10.1093/bioinformatics/btm585

They recommend an E-value threshold of 1*10^-6 and that there is a query coverage of at least 50%.

Also, as shown by their results, the recommended parameters for the best ortholog detection is the combination of soft filtering with a final Smith-Waterman alignment (the -F \"m S\" -s T options in NCBI's BLASTP). These options result in a higher number of orthologs and lower error rates. 

----------------

Next steps in the search of orthologs:

From https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3193375/

In this case, the fasta files provided for Arabidopsis and S. pombe have unique identifiers. 

---------------

About parameters:

From https://doi.org/10.1093/bioinformatics/btm585

They recommend an E-value threshold of 1*10^-6 and that there should be at least 50% query coverage.

In addition, the best detection of orthologs as best reciprocal matches was obtained with soft filtering and a final Smith-Waterman alignment (-F "m S" -s T), which provided both the highest number of orthologs and minimal error rates. However, using a final Smith-Waterman alignment is computationally expensive, and almost the same results were obtained with the use of soft filtering (-F "m S"), which is what I will use.

----------------

Next steps in the search for orthologs:

From https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3193375/

A reasonable next step would be to include a third species, and perform a COG (cluster of orthologous genes) search, a clustering method based on the best reciprocal hit. The best reciprocal matches among the three species would be identified and the clusters containing the best reciprocal match among the three species would be found. By including an additional species, it is more likely that the orthologous genes found would actually be orthologous.

In addition, we could use approaches based on phylogenetic gene trees among three or more species, and looking for orthologous genes among our species of interest.








