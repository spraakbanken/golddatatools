mode = "convert"

filename = ARGV[0]
inputfile = File.open("#{filename}.conllu","r:utf-8")
if mode == "convert"
    outputfile = File.open("#{filename}_ud.conllu","w:utf-8")
end

@matchingu = {"PE" => "ADP","AJ" => "ADJ","NN"=>"NOUN","EN"=>"PROPN", "SY"=>"PUNCT", "IJ"=>"INTJ"}
@matchingp = {"PE" => "PP"}
@matchfeats = {"-.-.-" => "_", "IND" => "Definite=Ind", "DEF" => "Definite=Def", "POS" => "Degree=Pos", "KOM" => "Degree=Cmp", "SUV"=> "Degree=Sup", "UTR" => "Gender=Com", "NEU" => "Gender=Neut", "SIN" => "Number=Sing", "PLU" => "Number=Plur"}

#case: check whether it spreads somewhere it shouldn't. Do any syncrectic cases disappear?
#lexical mismatches
#syncretism: just disappear (like now)? Or comma?
#Deal with coordination (ADJ vs ADV)
#TODO: proper nouns in the beginning of the sentence or (partial) abbreviations (JO-ombudsman) or numbers in the beginning


@adverbial_heads = ["AJ","VB"] #TODO: Are there misleading cases of "vara" as head? 
@punctuation = [".", ",", "‘", "-", "?", "(", ")", ":", "*", ";"]

def convert(id, sentence, sent_id)
    pos = sentence[id]["pos"]
    form = sentence[id]["form"]
    msd = sentence[id]["msd"]
    msd2 = sentence[id]["msd2"]
    head = sentence[id]["head"]
    deprel = sentence[id]["deprel"]
    
    #if id == "1017" 
    #    STDERR.puts pos, msd, sentence[head]["pos"], sentence[head]["lemma"]
    #end

    if pos == "AJ" and msd.include?("SIN") and msd.include?("IND") and msd.include?("NEU") and @adverbial_heads.include?(sentence[head]["pos"]) and sentence[head]["lemma"] != "vara"
        upos = "ADV" 
    elsif pos == "NN"
        if form[0] == form[0].upcase and id != "1001" and !(id == "1002" and sentence["1001"]["pos"] == "SY") and !msd2.include?("FKN")
            upos = "PROPN"
            STDERR.puts "#{sent_id} #{form}"
        end
    elsif pos == "SY"

    else
        upos = @matchingu[pos]
    end
    
    feats = ""
    msd.each do |msdunit|
        if !@matchfeats[msdunit].nil?
            feats << "#{@matchfeats[msdunit]}|"
            
        end
    end
    if ["NOUN","PROPN","ADJ"].include?(upos)
        if msd2[1] == "GEN"
            feats << "Case=Gen"
        else
            feats << "Case=Nom"
        end
    end

    
    if feats[-1] == "|"
        feats = feats[0..-2]
    end
    return upos, feats
end


output = []
sentence = {}
sent_id = ""
inputfile.each_line do |line|
    line1 = line.strip
    if line1 != ""
        if line1[0] == "#"
            if mode == "convert"
                output << line1
            end
            if line1.include?("sent_id")
                sent_id = line1.split(" = ")[1]
            end
        else
            line2 = line1.split("\t")
            id = line2[0]
            form = line2[1]
            lemma = line2[2].gsub("|","")
            pos = line2[3]
            msd2 = line2[4].split(".")
            msd = line2[5].split(".")[1..-1]
            head = line2[6]
            deprel = line2[7]
            extra1 = line2[8]
            extra2 = line2[9]

            if mode == "convert"
                sentence[id] = {"form"=>form,"msd"=>msd,"msd2"=>msd2,"head"=>head,"deprel"=>deprel,"lemma"=>lemma, "extra1"=>extra1, "extra2"=>extra2, "pos" => pos} 
            end
            
        end
    else
        if mode == "convert"
            sentence.each_pair do |id,senthash|
                upos, feats = convert(id, sentence, sent_id)
                line3 = [id, senthash["form"], senthash["lemma"], upos, "_", feats, senthash["head"], senthash["deprel"], senthash["extra1"], senthash["extra2"]].join("\t")
                output << line3
                end
            
            
            outputfile.puts output
            outputfile.puts ""
            output = []
            sentence = {}
        end
    end
end