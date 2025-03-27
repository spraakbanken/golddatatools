#sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
#corpus = "Lines"
#f = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
f = File.open("eukalyptus_all.conllu","r:utf-8")
@auxlist = ["böra", "få", "komma", "kunna", "lär", "må", "måste", "skola", "torde",  "vilja", "bli", "ha", "vara"]   
o1 = File.open("euk_coords2.txt","w:utf-8")
#o2 = File.open("#{corpus}_aen_adp.txt","w:utf-8")
sent_id = ""
text = ""
buffer = []
f.each_line do |line|
    line = line.strip
    if line.include?("# sent_id")
        sent_id = line.split("=")[1].strip
    elsif line.include?("# text ")
        text = line.split("=")[1].strip
    elsif line != "" and line[0] != "#"
        line1 = line.split("\t")
        form = line1[1]
        lemma = line1[2]
        pos = line1[3]
        deprel = line1[7]
        if (pos == "PE" or @auxlist.include?(lemma)) and buffer.length == 0
            buffer << form
        elsif buffer.length == 1
            if deprel == "KL"
                buffer << form
            else
                buffer = []
            end
        elsif buffer.length == 2
            buffer << form
            o1.puts "#{sent_id}\t#{buffer.join(" ")}"
            buffer = []
            #if pos == "KO"
            #    buffer << form
            #    o1.puts "#{sent_id}\t#{buffer.join(" ")}"
            #end
            #buffer = []
        end
    end
end

