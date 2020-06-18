require_relative 'paths.rb'

STDERR.puts "Specify the number of columns to output (if 1, only the forms will be outputted. If 2, specify which column has to be outputted (starting from 0 e.g. 4=XPOS or 5=FEATS). Usage: ruby conllu_to_tab.rb conllu_file_name number_of_columns_in_the_output [conllu_column_to_use]"

filename = "#{$corpora_path}#{ARGV[0]}"
extension = filename.split(".")[1]
if extension[0] == "~"
  outname = "#{filename.split(".")[0]}.~col#{ARGV[1]}"
else
  outname = "#{filename.split(".")[0]}.col#{ARGV[1]}"
end

f = File.open(filename,"r:utf-8")
outfile = File.open(outname, "w:utf-8")

f.each_line.with_index do |line, index|
  if index % 1000 == 0
    STDERR.puts index
  end
  line1 = line.strip
  if line1 == ""
    outfile.puts
  elsif line1[0]!= "#"
    line1 = line1.split("\t")
    if ARGV[1] == "2"
      outfile.puts "#{line1[1]}\t#{line1[ARGV[2].to_i]}"
    elsif ARGV[1] == "1"
      outfile.puts line1[1]
    end

  end
end 