#Train a converter
#?HA

sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
corpus = "Talbanken"
f = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
o = File.open("unamb_prontype_by_lemma-#{corpus}.tsv","w:utf-8")

prontypes = Hash.new{|hash, key| hash[key] = Hash.new(0)}
lemmata = Hash.new{|hash, key| hash[key] = Array.new}
sent_ids =  Hash.new{|hash, key| hash[key] = Hash.new{|hash, key| hash[key] = Array.new}}

sent_id = ""
f.each_line do |line|
    line = line.strip
    if line.include?("# sent_id")
        sent_id = line.split("=")[1].strip
    elsif line != "" and line[0] != "#"
        line1 = line.split("\t")
        lemma = line1[2]
        ud_pos = line1[3]
        sbx_pos = line1[4].split("|")[0]
        if ud_pos == "DET" or ud_pos == "PRON"
            feats = line1[5].split("|")
            prontype = ""
            feats.each do |feat|
                name = feat.split("=")[0]
                value = feat.split("=")[1]
                if name == "PronType"
                    prontype = value
                    break
                end
            end
            prontypes[prontype][lemma] += 1
            sent_ids[prontype][lemma] << sent_id
            lemmata[lemma] << prontype
        end
        
        
    end
end

prontypes.each_pair do |prontype,lemmas|
    #lemmata = lemmas.keys
    #o.puts "#{prontype}\t\"#{lemmata.join("\", \"")}\""
    lemmas.each_pair do |lemma,count|
        if lemmata[lemma].uniq.length == 1
            if count <= 50
                o.puts "\"#{lemma}\"\t\"#{prontype}\"\t#{count}\t#{sent_ids[prontype][lemma].join("\t")}"
            else
                o.puts "\"#{lemma}\"\t\"#{prontype}\"\t#{count}"
            end
        end
    end
end