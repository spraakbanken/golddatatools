#require_relative 'paths.rb'

STDERR.puts "Input: corpus_name.ext (in a tab-separated two-column format); Output: corpus_name.col3"

f = File.open("#{ARGV[0]}","r:utf-8")
o = File.open("#{ARGV[0].split(".")[0]}.col3","w:utf-8")

f.each_line do |line|
  line1 = line.strip
  if line1[0] != "#"
    if line1 != ""
      line1 = line1.split("\t")
      if line1[1].count(".") > 0
        line1[2] = line1[1].split(".")[1..-1].join(".")
      else 
        line1[2] = "_"
      end
      line1[1] = line1[1].split(".")[0]
      line1 = line1.join("\t")
    end
    o.puts line1
  end
end  