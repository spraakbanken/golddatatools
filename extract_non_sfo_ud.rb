#sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
tb = ["tyckas", "finnas", "synas", "hoppas", "utspelas", "mötas", "tvinga", "fattas", "vistas", "fordras", "brottas", "trivas", "kräkas", "lyckas", "andas", "mattas", "töras", "läsa", "kännas", "trängas", "slåss", "rymmas", "handskas", "minnas", "låtsas", "samsas", "täckas"]
corpus = "lines"
f = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
#f = File.open("eukalyptus_all.conllu","r:utf-8")

o = File.open("lines_nonsfo.tsv","w:utf-8")
sent_id = ""
lemmas = []
f.each_line do |line|
    line = line.strip
    if line.include?("# sent_id")
        sent_id = line.split("=")[1].strip
    elsif line != "" and line[0] != "#"
        line1 = line.split("\t")
        form = line1[1]
        lemma = line1[2]
        ud_pos = line1[3]
        #sbx_pos = line1[4].split("|")[0]
        feats = line1[5]
        if ud_pos == "VERB" or ud_pos == "AUX"
            if form[-1].downcase == "s" and !feats.include?("Voice=Pass") and !tb.include?(lemma)
                lemmas << lemma
            end
            lemmas.uniq!
        end        
        
    end
end

#lemmas = [tb,lemmas].flatten.uniq


o.puts "[\"#{lemmas.join("\", \"")}\"]"