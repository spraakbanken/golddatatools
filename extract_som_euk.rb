#sbx_to_ud = Hash.new{|hash, key| hash[key] = Array.new}
corpus = "Talbanken"
f1 = File.open("C:\\Sasha\\D\\DGU\\UD\\UD215langs\\Swedish-#{corpus}.conllu","r:utf-8")
f2 = File.open("eukalyptus_all.conllu","r:utf-8")

lemmafreq_ud = Hash.new(0)
lemmafreq_euk = Hash.new(0)
poss_ud = Hash.new{|hash, key| hash[key] = Hash.new(0)}
poss_euk = Hash.new{|hash, key| hash[key] = Hash.new(0)}
final_ud = {}
final_euk = {}

o = File.open("comparison.tsv","w:utf-8")
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

poss_ud.each_pair |lemma, poss|
    final_ud[lemma] = poss.keys.sort.join("\t")

end



poss.each_pair do |pos,n|
    o.puts "#{pos}\t#{n}"
end