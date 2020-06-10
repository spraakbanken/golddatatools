# golddatatools
 Some tools for working with gold data at SBX

talbanken_morphsplit.tsv: the list of sentence (by IDs) in test and dev sets.
talbanken_xml_morphsplit.rb: splits talbanken.xml into dev and test using the provided list. Run as ruby talbanken_xml_morphsplit.rb. The Nokogiri gem has to be installed first (gem install nokogiri).
xml_to_conllu.rb: converts Språkbanken's XML format to a pseudo-CONLLU format, see brief description at the resource page for TalbankenSBX.


Contact me at aleksandrs.berdicevskis@gu.se if you have questions.