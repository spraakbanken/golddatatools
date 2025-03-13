#sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
corpus = "Lines"
f = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
#f = File.open("eukalyptus_all.conllu","r:utf-8")

o1 = File.open("#{corpus}_aen_sconj.txt","w:utf-8")
o2 = File.open("#{corpus}_aen_adp.txt","w:utf-8")
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
        #feats = line1[5].split("|")
        if lemma == "än"
            if ud_pos == "SCONJ"
                o1.puts "#{text} #{sent_id}"
            elsif ud_pos == "ADP"
                o2.puts "#{text} #{sent_id}"
            end
        end        
        
    end
end

