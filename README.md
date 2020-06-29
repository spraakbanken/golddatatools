# golddatatools
 Some tools for working with gold data at SBX

talbanken_morphsplit.tsv: the list of sentence (by IDs) in test and dev sets.

talbanken_xml_morphsplit.rb: splits talbanken.xml into dev and test using the provided list. Run as ruby talbanken_xml_morphsplit.rb. The Nokogiri gem has to be installed first (gem install nokogiri).

xml_to_conllu.rb: converts Språkbanken's XML format to a pseudo-CONLLU format, see brief description at the resource page for TalbankenSBX.

connlu_to_tab.rb: converts CONLL(U) to a tab-separated two-column (or one-column) format. Specify the number of columns to output (if 1, only the forms will be outputted. If 2, specify which CONLL column has to be outputted (starting from 0 e.g. 4=XPOS or 5=FEATS). Usage: ruby conllu_to_tab.rb conllu_file_name number_of_columns_in_the_output [conllu_column_to_use].

convert_col2_to_marmot.rb converts .col2 to .col3, which is a convenient format for Marmot (the single POS.MSD tag is split into two separate tags, as Marmot requires).

convert_marmot_to_conllu.rb converts Marmot output (conll with an unusual order of columns) to CONLLU.

train_flair_p.py, tag_flair_p.py: scripts to train a Flair POS-tagging model and tag texts using it, see the page for Flair models under Resources.

Contact me at aleksandrs.berdicevskis@gu.se if you have questions.
