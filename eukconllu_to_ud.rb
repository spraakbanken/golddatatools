mode = "convert"
list_out_pos = false
lemma_per_pos2 = Hash.new{|hash, key| hash[key] = Array.new}

filename = ARGV[0]
inputfile = File.open("#{filename}.conllu","r:utf-8")

if mode == "convert"
    
    outputfile = File.open("#{filename}_ud.conllu","w:utf-8")
elsif mode == "list_pos"
    ref_pos = ARGV[1]
    if ref_pos == "??"
        ref_pos2 = "QQ"
    else
        ref_pos2 = ref_pos
    end
    pos_outputfile = File.open("#{ref_pos2}_#{filename}.txt","w:utf-8")
    #lemmas_per_pos = Hash.new{|hash, key| hash[key] = Hash.new(true)}
    lemmas_per_pos = Hash.new(true)
end

@matchingu = {"PE" => "ADP","AJ" => "ADJ","NN"=>"NOUN","EN"=>"PROPN", "SY"=>"PUNCT", "IJ"=>"INTJ", "KO" => "CCONJ", "AB" => "ADV", "NU" => "NUM", "PO" => "PRON", "SU" => "SCONJ", "UO" => "X", "VB" => "VERB"}
#dealt separately: PART, SYM, PUNCT

@matchingp = {"PE" => "PP"}
@matchfeats = {"-.-.-" => "_", "IND" => "Definite=Ind", "DEF" => "Definite=Def", "POS" => "Degree=Pos", "KOM" => "Degree=Cmp", "SUV"=> "Degree=Sup", "UTR" => "Gender=Com", "NEU" => "Gender=Neut", "SIN" => "Number=Sing", "PLU" => "Number=Plur"}

#Arbt_Fackfientlig.7 -- ask Gerlof
#case: check whether it spreads somewhere it shouldn't. Do any syncretic cases disappear?
#lexical mismatches
#syncretism: just disappear (like now)? Or comma?
#Deal with coordination (ADJ vs ADV)
#TODO: proper nouns in the beginning of the sentence or (partial) abbreviations (JO-ombudsman) or numbers in the beginning
#TODO: check the PART vs SCONJ heuristics for "att"
#TODO: Arbt_Fackfientlig.2, 1003: 1008:

#!TODO: VERB vs AUX
#!DET
#!PRONOUNS, som...
#lemma: en_viss

#To ignore or manually
# - as minus can potentially get labelled as PUNCT. But interval dashes are much more frequent, and they are PUNCT, so I am disabling the minus detector
# : as division can potentially get labelled as PUNCT

@adverbial_heads = ["AJ","VB"] #TODO: Are there misleading cases of "vara" as head? 
@punctuation = [".", ",", "‘", "-", "?", "(", ")", ":", "*", ";", "\"","!","'","`","•","–","—","”","[","]","…","“"]

def complex_punctuation(form)
    combinable_punctuation = [".", "?", "!"]
    combinable_punctuation.each do |symbol|
        form.gsub!(symbol,"")
        if form.length == 0
            break
        end
    end
    if form.length == 0
        punctuation = true
    else
        punctuation = false
    end
    return punctuation
end

def convert(id, sentence, sent_id)
    pos = sentence[id]["pos"]
    form = sentence[id]["form"]
    msd = sentence[id]["msd"]
    msd2 = sentence[id]["msd2"]
    head = sentence[id]["head"]
    deprel = sentence[id]["deprel"]
    firsttoken = sentence.keys.min
    
    #if id == "1017" 
    #    STDERR.puts pos, msd, sentence[head]["pos"], sentence[head]["lemma"]
    #end

    if ["inte","icke","ej"].include?(form.downcase)
        upos = "PART"
    elsif "att" == form.downcase
        if !sentence[id+1].nil?
            if sentence[id+1]["pos"] == "VB" and sentence[id+1]["msd"].include?("INF")
                upos = "PART"
            else
                upos = "SCONJ"
            end
        else
            STDOUT.puts "#{sent_id} att at the end of a sentence"
        end

    elsif (pos == "AJ" and msd.include?("SIN") and msd.include?("IND") and msd.include?("NEU")) and (sentence[head].nil? or (@adverbial_heads.include?(sentence[head]["pos"]) and sentence[head]["lemma"] != "vara"))
        #STDERR.puts "#{sent_id} #{form}"
        upos = "ADV" 
    elsif pos == "NN"
        if form[0] == form[0].upcase and id != firsttoken and !(id == (firsttoken+1) and sentence[firsttoken]["pos"] == "SY") and !msd2.include?("FKN")
            upos = "PROPN"
            #STDERR.puts "#{sent_id} #{form}"
        else
            upos = "NOUN"
        end
    elsif pos == "SY"
        if @punctuation.include?(form)
            #if form == "-" or form == "–" and "0123456789,".include?(sentence[id+1]["form"][0])
            #    upos = "SYM"
            #else
            upos = "PUNCT"
            #end
        elsif complex_punctuation(form)
            upos = "PUNCT"
        elsif form == "--" or form == "---"
            upos = "PUNCT"
        else 
            upos = "SYM"
        end

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
    feats = feats.split("|").sort.join("|")
    return upos, feats
end


output = []
sentence = {}
sent_id = ""
dtlist = []
inputfile.each_line do |line|
    line1 = line.strip
    if line1 != ""
        if line1[0] == "#"
            if mode == "convert"
                output << line1
            end
            if line1.include?("sent_id")
                sent_id = line1.split(" = ")[1]
                STDERR.puts sent_id
            end
        else
            line2 = line1.split("\t")
            id = line2[0].to_i
            form = line2[1]
            lemma = line2[2].gsub("|","")
            pos = line2[3]
            msd2 = line2[4].split(".")
            msd = line2[5].split(".")[1..-1]
            head = line2[6]
            deprel = line2[7]
            extra1 = line2[8]
            extra2 = line2[9]
            if mode == "list_pos"
                if pos == ref_pos
                    #lemmas_per_pos[pos][lemma] = true
                    if lemma != "_"
                        lemmas_per_pos[lemma] = true
                    else
                        lemmas_per_pos[form] = true
                    end
                end
            end

            if mode == "convert"
                sentence[id] = {"form"=>form,"msd"=>msd,"msd2"=>msd2,"head"=>head,"deprel"=>deprel,"lemma"=>lemma, "extra1"=>extra1, "extra2"=>extra2, "pos" => pos} 
            end

            if mode == "other"
                if pos == "PO" and deprel == "DT" and !dtlist.include?(lemma)
                    dtlist << lemma
                end
            end
            
        end
    else
        if mode == "convert"
            counter = 1
            idhash = {}
            sentence.keys.sort.each do |id|
                idhash[id] = counter
                counter += 1
            end
            idhash[0] = 0

            sentence2 = {}
            sentence.each_pair do |id, senthash|
                newid = idhash[id]
                newhead = idhash[senthash[head]]
                sentence2[newid] = senthash
                sentence2[newid]["head"] = newhead
            end
            sentence = sentence2.clone 

            sentence.each_pair do |id,senthash|
                upos, feats = convert(id, sentence, sent_id)
                line3 = [id, senthash["form"], senthash["lemma"], upos, "_", feats, senthash["head"], senthash["deprel"], senthash["extra1"], senthash["extra2"]].join("\t")
                output << line3

                    if list_out_pos
                        if senthash["lemma"] != "_"
                            lemma_per_pos2[upos] << senthash["lemma"]
                        else
                            lemma_per_pos2[upos] << senthash["form"]
                        end
                    end
                end
            
            
            outputfile.puts output
            outputfile.puts ""
            output = []
            sentence = {}
        end
    end
end

if mode == "list_pos"
    lemmas_per_pos.each_key do |lemma|
        pos_outputfile.puts lemma
    end
end

if list_out_pos
    outpos = File.open("outposs.tsv","w:utf-8")
    lemma_per_pos2.each_pair do |upos,lemmas|
        outpos.puts "#{upos}\t#{lemmas.uniq.join("\t")}"
    end
end

if mode == "other"
    STDERR.puts dtlist
end