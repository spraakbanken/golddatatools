#sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
corpus = "Talbanken"
f = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
#f = File.open("eukalyptus_all.conllu","r:utf-8")

#o1 = File.open("euk_coords.txt","w:utf-8")
o2 = File.open("#{corpus}_ordnum.tsv","w:utf-8")
sent_id = ""
text = ""
lemmas = []
f.each_line do |line|
    line = line.strip
    if line.include?("# sent_id")
        sent_id = line.split("=")[1].strip
    elsif line.include?("# text ")
        text = line.split("=")[1].strip
    elsif line != "" and line[0] != "#"
        line1 = line.split("\t")
        
        lemma = line1[2]
        ud_pos = line1[3]
        #sbx_pos = line1[4].split("|")[0]
        feats = line1[5].split("|")
        
        if feats.include?("NumType=Ord")
            if !lemmas.include?(lemma)
                lemmas << lemma
			    
                o2.puts "#{lemma}\t#{ud_pos}"
            end
        end        
        
    end
end

