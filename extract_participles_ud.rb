sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
corpus = "Talbanken"
f = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
o = File.open("ud_participles.tsv","w:utf-8")

@partpenult = "abcdfghjklmnpqrstvwxz"
f.each_line do |line|
    line = line.strip
    if line.include?("# sent_id")
        sent_id = line.split("=")[1].strip
    elsif line != "" and line[0] != "#"
        line1 = line.split("\t")
        lemma = line1[2]
        ud_pos = line1[3]
        sbx_pos = line1[4].split("|")[0]
        feats = line1[5].split("|")
        if feats.include?("VerbForm=Part")
            if feats.include?("Tense=Past")
                if !((@partpenult.include?(lemma[-2]) and lemma[-1] == "d") or (lemma[-2..-1]=="en"))
                    o.puts "Past: #{lemma}"
                end
            elsif feats.include?("Tense=Pres")
                if lemma[-4..-1] != "ande" and lemma[-4..-1] != "ende"
                    o.puts "Pres: #{lemma}"
                end
            end
        end        
        
    end
end
