#sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
corpus = "Talbanken"
f1 = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
f2 = File.open("eukalyptus_all_ud.conllu","r:utf-8")

lemmafreq_ud = Hash.new(0)
lemmafreq_euk = Hash.new(0)
poss_ud = Hash.new{|hash, key| hash[key] = Hash.new(0)}
poss_euk = Hash.new{|hash, key| hash[key] = Hash.new(0)}
final_ud = {}
final_euk = {}
freqs_ud = {}
freqs_euk = {}

o = File.open("comparison.tsv","w:utf-8")
o.puts "lemma\tpos_ud\tpos_freqs_ud\tpos_euk\tpos_freqs_euk\tlemmafreq_ud\tlemmafreq_euk\ttotal_freq"
#o1 = File.open("#{corpus}_aen_sconj.txt","w:utf-8")
#o2 = File.open("#{corpus}_aen_adp.txt","w:utf-8")
sent_id = ""
text = ""

f1.each_line do |line|
    line = line.strip
    if line.include?("# sent_id")
        sent_id = line.split("=")[1].strip
    elsif line.include?("# text")
        text = line.split("=")[1].strip
    elsif line != "" and line[0] != "#"
        line1 = line.split("\t")
        lemma = line1[2]
        ud_pos = line1[3]
        poss_ud[lemma][ud_pos] += 1
        lemmafreq_ud[lemma] += 1
    end
end

poss_ud.each_pair do |lemma, poss|
    final_ud[lemma] = poss.keys.sort.join(";")
    
end


f2.each_line do |line|
    line = line.strip
    if line.include?("# sent_id")
        sent_id = line.split("=")[1].strip
    elsif line.include?("# text")
        text = line.split("=")[1].strip
    elsif line != "" and line[0] != "#"
        line1 = line.split("\t")
        lemma = line1[2]
        ud_pos = line1[3]
        poss_euk[lemma][ud_pos] += 1
        lemmafreq_euk[lemma] += 1
    end
end

poss_euk.each_pair do |lemma, poss|
    final_euk[lemma] = poss.keys.sort.join(";")
end

final_ud.each_pair do |lemma, poss|
    if poss.include?("ADJ") and poss.include?("PRON")
        STDOUT.puts lemma
    end
    if !final_euk[lemma].nil?
        if poss != final_euk[lemma]
            o.puts "#{lemma}\t#{poss_ud[lemma].keys.join(";")}\t#{poss_ud[lemma].values.join(";")}\t#{poss_euk[lemma].keys.join(";")}\t#{poss_euk[lemma].values.join(";")}\t#{lemmafreq_ud[lemma]}\t#{lemmafreq_euk[lemma]}\t#{lemmafreq_ud[lemma]+lemmafreq_euk[lemma]}"
        end
    end
end