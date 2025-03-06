inputfile = File.open("eukalyptus_all.conllu","r:utf-8")

partpenult = "abcdfghjklmnpqrstvwxz"
unvoiced_partpenult = "cfhkpqstxz"
lemmas = {}
inputfile.each_line do |line|
    line1 = line.strip
    if line1 != "" and line1[0] != "#"
        line2 = line1.split("\t")
        #if line2[3] == "AJ" and ((line2[2][-1] == "d" and partpenult.include?(line2[2][-2])) or (line2[2][-2..-1] == "en"))
        #    lemmas[line2[2]] = true
        #end
        #if line2[3] == "AJ" and ((line2[2][-3..-1] == "nde" or line2[2][-4..-1] == "ndes"))
        #    lemmas[line2[2]] = true
        #end
        if line2[3] == "AJ" and (line2[2][-1] == "t" and unvoiced_partpenult.include?(line2[2][-2]))
            lemmas[line2[2]] = true
        end
        
    end

end

STDOUT.puts lemmas.keys