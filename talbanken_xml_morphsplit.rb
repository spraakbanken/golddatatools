### Applying the MorphSplit to talbanken.xml. Aleksandrs Berdicevskis, 2020-06-09 ###

STDERR.puts "Usage: ruby talbanken_xml_morphsplit.rb. The files talbanken_morphsplit.tsv and talbanken.xml have to be in the same directory."


require "Nokogiri"

inputfilename = "talbanken.xml"
@tbsize = 6160
devsize = 3080
testsize = 3080

list_ids_from_xml = false
split_ids = false
split_tb = true

def readdatasplit
  ids = File.open("talbanken_morphsplit.tsv","r:utf-8")
  datasplit = {}
  ids.each_line do |line|
    line1 = line.strip.split("\t")
    datasplit[line1[0]] = line1[1]
  end
  return datasplit 
end

def extract_sentences(filename)
  STDERR.puts ("Parsing xml...")
  talbanken = Nokogiri::XML(File.read(filename))
  STDERR.puts ("Searching xml...")
  text = talbanken.css("text").to_a[0]
  sentences = text.css("sentence")
  return sentences
end

if split_tb
  sentences = extract_sentences(inputfilename)
  STDERR.puts ("Creating the sets...")

  devf = File.open("talbanken_dev.xml","w:utf-8")
  testf = File.open("talbanken_test.xml","w:utf-8")
  datasets = {devf => "dev", testf => "test"}
  datasets_rev = {"dev" => devf, "test" => testf}
  datasets.each_key do |dataset|
    dataset.puts "<corpus id = \"talbanken_#{datasets[dataset]}\">"
    dataset.puts "<text>"
  end
  
  STDERR.puts ("Reading the split data...")
  datasplit = readdatasplit
  
  STDERR.puts ("Splitting...")
  sentences.each do |sentence|
    datasets_rev[datasplit[sentence["id"].to_s]].puts sentence
  end

  datasets.each_key do |dataset|
    dataset.puts "</text>"
    dataset.puts "</corpus>"
  end

end