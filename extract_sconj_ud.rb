#sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
corpus = "Talbanken"
f = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
#f = File.open("eukalyptus_all.conllu","r:utf-8")

o = File.open("talbanken_cconj.tsv","w:utf-8")
sent_id = ""
lemmas = []
f.each_line do |line|
    line = line.strip
    if line.include?("# sent_id")
        sent_id = line.split("=")[1].strip
    elsif line != "" and line[0] != "#"
        line1 = line.split("\t")
        lemma = line1[2]
        ud_pos = line1[3]
        #sbx_pos = line1[4].split("|")[0]
        #feats = line1[5].split("|")
        if ud_pos == "CCONJ"
            lemmas << lemma
            lemmas.uniq!
        end        
        
    end
end

o.puts lemmas