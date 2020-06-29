require_relative 'C:\\Sasha\\D\\DGU\\tagging-experiments\\paths.rb'

f = File.open("#{$corpora_path}#{ARGV[0]}","r:windows-1252")
o = File.open("#{$corpora_path}#{ARGV[0].split(".")[0]}.conllu","w:utf-8")

f.each_line do |line|
  line1 = line.strip
  if line1[0] != "#"
    if line1 != ""
      line1 = line1.split("\t")
      line1[3] = line1[5]
      
      
      if line1[7] != "_" #msd
        line1[4] = "#{line1[3]}.#{line1[7]}"
      else 
        line1[4] = line1[3]
      end
      line1[5] = "_" #pos
      line1[7] = "_"
      line1[8] = "_"
      line1[9] = "_"
      #line1[1] = line1[1].split(".")[0]
      line1 = line1.join("\t")
    end
    o.puts line1
  end
end  