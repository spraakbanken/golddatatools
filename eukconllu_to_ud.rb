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

#TODO1: finish prepositions. Either exclude certain that are never ADVs or use sec.edges

#TODO3: DO when syntax. SCONJ vs PRON vs ADV (som). Identify Advcl (esp. när, då, där). Deal with än and som
#vilket fall som helst: CCONJ
#ASK: advcl (sv-ud-train-3749, sv-ud-train-166) -- should be SCONJ. 

#TODO2: coordination
#TODO2: Särskilt


@matchingp = {"PE" => "PP"}
@matchfeats = {"-.-.-" => "_", "IND" => "Definite=Ind", "DEF" => "Definite=Def", "POS" => "Degree=Pos", "KOM" => "Degree=Cmp", "SUV"=> "Degree=Sup", "UTR" => "Gender=Com", "NEU" => "Gender=Neut", "MAS" => "Gender=Masc", "SIN" => "Number=Sing", "PLU" => "Number=Plur", "SUB" => "Case=Nom", "OBJ" => "Case=Acc"}
#"UTR/NEU" => "Gender=Com,Neut", "IND/DEF" => "Definite=Ind,Def", "SIN/PLU" => "Number=Sing,Plur", "SUB/OBJ" => "Case=Acc,Nom" Decided not to add. Usually covers the full range of possible values (and thus not recommended). Exception: Gender (Masc), but it's marginal. Syncretic case in EUK applies (mostly?) to determiners, so not relevant either.

@matchvbfeats = {"IND" => "Mood=Ind", "AKT" => "Voice=Act", "PRS" => "Tense=Pres", "PRT" => "Tense=Past", "SFO" =>"Voice=Pass", "KON" => "Mood=Sub", "IMP" => "Mood=Imp", "INF" => "VerbForm=Inf", "SPM" => "VerbForm=Sup", "SIN" => "Number=Sing", "PLU" => "Number=Plur", "SUB" => "Case=Nom", "OBJ" => "Case=Acc", "UTR" => "Gender=Com", "NEU" => "Gender=Neut", "MAS" => "Gender=Masc"}
#TODO3: Deal with ESM in msd2
#TODO3: Misc for MWEs?
#TODO3: PL => compound:prt. Current UD inconsistent

#TODO3: Arbt_Fackfientlig.7 -- ask Gerlof

#TODO3: Arbt_Fackfientlig.2, 1003: 1008:

#TODO2: många and mycket
#TODO2: den här

#DIM (DOC, IGNORE, MANUALLY, LATER)
# allting annat
# EN: numeral
# Typo should be style, too
# AUX-VERB
# FRL -- use to find SUBORDINATORS?
# PSS: can be used?
# Underproduction of PROPN (turn back on the capitalization-based method?)
# annat fint
# lemmatization of "andra" 
# NumType
# ASK: verbal particles: when ADV, when ADP? Also in texts, but there the rule is clearer
# över: if NUM?

@auxlist = ["böra", "få", "komma", "kunna", "lär", "må", "måste", "skola", "torde",  "vilja", "bli", "ha", "vara"]   #from https://quest.ms.mff.cuni.cz/udvalidator/cgi-bin/unidep/langspec/specify_auxiliary.pl?lcode=sv with changes discussed in https://github.com/UniversalDependencies/docs/issues/1082
@adverbial_heads = ["AJ","VB"] 
@determiners = ["den", "en", "all", "någon", "denna", "vilken", "ingen", "varannan", "varenda","de","varje"]
@posslemmas = {"min" => "jag", "din" => "du", "vår" => "vi", "er" => "ni", "sin" => "sig"}
@lemmacorrections = {"en viss" => "viss"}
@uposcorrections = {"viss" => "ADJ"}
@adpnotadv = ["från", "av", "i", "mot", "på", "genom", "mellan", "utan", "å", "hos", "bland", "inom", "utom", "per"]

@prontypes = {"all" => "Tot", "annan" => "Ind", "denna" => "Dem", "densamma" => "Dem", "en" => "Art", "hon" => "Prs", "ingen" => "Neg", "ingenting" => "Neg", "man" => "Ind", "någon" => "Ind", "sig" => "Prs", "som" => "Rel", "var" => "Tot", "varandra" => "Rcp", "vardera" => "Tot", "varje" => "Tot", "vem" => "Int", "the" => "Art", "vars" => "Rel", "vilka" => "Rel", "du" => "Prs", "vi" => "Prs", "han" => "Prs", "jag" => "Prs", "ni" => "Prs", "vår" => "Prs", "mitt" => "Prs", "mycken" => "Ind", "någonting" => "Ind", "mången" => "Ind", "mycket" => "Ind", "sån" => "Ind", "somlig" => "Ind", "många" => "Ind", "varannan" => "Ind", "nånting" => "Ind", "flera" => "Ind", "fler" => "Ind", "få" => "Ind", "två" => "Ind", "vissa" => "Ind", "båda" => "Tot", "vilket" => "Tot", "bådadera" => "Tot", "allting" => "Tot", "envar" => "Tot", "bägge" => "Tot", "samtlig" => "Tot", "alltihop" => "Tot", "ingendera" => "Neg", "varann" => "Rcp", "vad" => "Int,Rel", "vilken" => "Int,Rel", "litet" => "Ind", "allihopa" => "Tot", "alltihopa" => "Tot", "varsin" => "Tot", "varenda" => "Tot", "allesammans" => "Tot"} #Based on Talbanken + corrections from https://github.com/UniversalDependencies/docs/issues/1083#issuecomment-2677651632
#TODO2: #vad, vilken (+vem? det?) and other ambiguous +den här
#DIM: possible overproduction of pronouns, especially "Tot"

@partpenult = "abcdfghjklmnpqrstvwxz"
@unvoiced_partpenult  = "cfhkpqstxz"
@notparticiples = ["ökänd", "mången", "glad", "gedigen", "liten", "hård", "sen", "mycken", "välkommen", "öppen", "ilsken", "egen", "osund", "enskild", "blåögd", "ond", "medveten", "angelägen", "okänd", "kristen", "vuxen", "rädd", "jätte|ond", "jätte|ledsen", "lessen", "sugen", "synd", "ledsen", "mild", "obenägen", "ren", "nämnvärd", "jättesugen", "vaken", "stenhård", "naken", "nyfiken", "högljudd", "galen", "värd", "toppen", "oerhörd", "omedveten", "helhjärtad", "vild", "lyhörd", "avsevärd", "sund", "belägen", "folkvald", "blond", "trogen", "förmögen", "färgglad", "sorgsen", "överlägsen", "outvecklad", "önskvärd", "rund", "belåten", "härsken", "moloken", "grund", "blå|mild", "plikttrogen", "oönskad", "len", "säregen", "mogen", "avlägsen", "älskvärd", "medfaren", "ljummen", "först", "korrekt", "främst", "direkt", "fast", "indirekt", "gôtt", "rätt", "näst", "trist", "exakt", "sist", "glatt", "övertrött", "perfekt", "tyst", "flott", "förtjust", "platt", "nätt", "sankt", "terrest", "ogift", "rödlätt", "storväxt", "kroknäst", "kompakt", "knäppt", "smått"]
@nonsfolemmas = ["tycka", "möta", "fordra", "känna", "tränga"] #both from Talbanken and LinES with manual filtering

def finddaughters(sentence,nodeofinterest)
    #STDERR.puts "nodeofinterest: #{nodeofinterest}"
    #STDERR.puts "finddaughters: #{sentence}"
    daughters = []
    sentence.each_pair do |id, infohash|
        #STDERR.puts id
        #STDERR.puts infohash
        if infohash["head"] == nodeofinterest
            
            daughters << id
        end
    end
    return daughters

end

def detectparticiple(pos,upos,lemma,head,deprel,sentence)
    feats = []
    if pos == "AJ" 
        if ((lemma[-1] == "d" and @partpenult.include?(lemma[-2])) or (lemma[-2..-1] == "en") or (lemma[-1] == "t" and @unvoiced_partpenult.include?(lemma[-2]))) and !@notparticiples.include?(lemma)
            if !sentence[head].nil?
                if sentence[head]["lemma"] == "bli" and deprel == "SP"
                    upos = "VB"
                    feats << "Voice=Pass"
                    #TODO3: change the structure, add aux:pass deprel, change POS of bli to "aux"
                end
            end
            feats << "Tense=Past"
            feats << "VerbForm=Part"
        elsif lemma[-4..-1] == "ande" or lemma[-4..-1] == "ende" 
            feats << "Tense=Pres"
            feats << "VerbForm=Part"
        end
    end
    return upos,feats
end


def convert(id, sentence, sent_id)
    #STDERR.puts "convert: #{sentence}"
    pos = sentence[id]["pos"]
    form = sentence[id]["form"]
    lemma = sentence[id]["lemma"]
    msd = sentence[id]["msd"]
    msd2 = sentence[id]["msd2"]
    head = sentence[id]["head"]
    deprel = sentence[id]["deprel"]
    misc = sentence[id]["misc"]
    firsttoken = sentence.keys.min
    
    #if id == "1017" 
    #    STDERR.puts pos, msd, sentence[head]["pos"], sentence[head]["lemma"]
    #end

    if !@lemmacorrections[lemma].nil? 
        lemma = @lemmacorrections[lemma]
    end

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
    elsif (pos == "AJ" and msd.include?("SIN") and msd.include?("IND") and msd.include?("NEU")) and (sentence[head].nil? or (@adverbial_heads.include?(sentence[head]["pos"]) and sentence[head]["lemma"] != "vara") and deprel == "MD") or (pos == "AJ" and lemma == "först")
        #TODO2: Add verbal features for participles? Or exclude them from the participle function?
        upos = "ADV" 
    #elsif pos == "NN"
    #    if form[0] == form[0].upcase and id != firsttoken and !(id == (firsttoken+1) and sentence[firsttoken]["pos"] == "SY") and !msd2.include?("FKN")
            #upos = "PROPN"
            #STDOUT.puts "#{sent_id} #{form}"
    #    else
    #        upos = "NOUN"
    #    end
    elsif pos == "SY"
        if msd.include?("DEL")
            upos = "PUNCT"
        else
            upos = "SYM"
        end
    elsif pos == "PE"
        daughters = finddaughters(sentence,id)
        if deprel == "PL" or @adpnotadv.include?(lemma) #1) for now, I am preserving the Euk classification of "particles", since the UD one is inconsistent 2) a rather barbaric way to avoid overproduction of ADV
            prepflag = true
        else
            prepflag = false
            daughters.each do |daughter|
                if sentence[daughter]["deprel"] == "OO" or sentence[daughter]["deprel"] == "ME" or sentence[daughter]["deprel"] == "MD" #remove the second condition?
                    if lemma == "över"
                        if sentence[daughter]["pos"] == "NU"
                            
                            break
                        else
                            overflag = true
                            granddaughters = finddaughters(sentence,daughter)
                            granddaughters.each do |granddaughter|
                                if sentence[daughter]["pos"] == "NU"
                                    overflag = false
                                    break
                                end
                            end
                            if overflag
                                prepflag = true
                            end
                            break
                        end
                    else
                        prepflag = true
                        break
                    end
                end
            end
        end
        if prepflag 
            upos = "ADP"
        else
            upos = "ADV"
        end

    else
        upos = @matchingu[pos]
    end

    

    
    if deprel == "DT"
        if @determiners.include?(lemma)
            upos = "DET"
        end
    end
    
    if lemma == "mycket" or lemma == "mycken" or lemma == "litet"
        if deprel == "DT"
            upos = "ADJ"
        elsif deprel == "MD"
            upos = "ADV"
        else
            upos = "PRON"
        end

    end

    if !@uposcorrections[lemma].nil? 
        upos = @uposcorrections[lemma]
    end


    feats = []
    partresults = detectparticiple(pos,upos,lemma,head,deprel,sentence) 
    feats << partresults[1]
    feats.flatten!
    upos = partresults[0]

    if pos == "VB"

        

        #DIM: AUX vs VERB add "det" disambiguation
        #DIM: AUX vs VERB add "vara" disambiguation
        
        
        if @auxlist.include?(lemma)
            #STDERR.puts "AUXLIST!"
            auxflag = false
            daughters = finddaughters(sentence,id)
            #STDERR.puts daughters
            if lemma == "bli"
                
                daughters.each do |daughter|
                    daughterupos,daughterfeats = detectparticiple(sentence[daughter]["pos"],"",sentence[daughter]["lemma"],sentence[daughter]["head"],sentence[daughter]["deprel"],sentence)
 
                    if daughterfeats.include?("VerbForm=Part") and daughterfeats.include?("Tense=Past") and sentence[daughter]["deprel"] == "SP"
                        auxflag = true
                        break
                    end
                end

            elsif lemma == "ha"
                daughters.each do |daughter|
                    #STDERR.puts daughter
                    if sentence[daughter]["msd"].include?("SPM") and sentence[daughter]["deprel"] == "IV"
                        auxflag = true
                        break
                    end
                end

            elsif lemma == "vara"
                daughters.each do |daughter|
                    if sentence[daughter]["deprel"] == "SP"
                        auxflag = true
                        break
                    end
                end
            else
                #STDERR.puts "OTHER!"
                daughters.each do |daughter|
                    #STDERR.puts daughter
                    if ((sentence[daughter]["msd"].include?("INF") or sentence[daughter]["lemma"] == "att")) or (sentence[daughter]["msd"].include?("SPM")) and sentence[daughter]["deprel"] == "IV"
                        auxflag = true
                        break
                    end
                end
                
            end
            if auxflag
                #STDERR.puts "AUX!"
                upos = "AUX"
            end
        end
    end



    msd.each do |msdunit|
        if pos == "VB"
            relevant_feats = @matchvbfeats.clone
        else
            relevant_feats = @matchfeats.clone
        end

        if !relevant_feats[msdunit].nil?
            feats << "#{relevant_feats[msdunit]}"
            
        end
    end
    if ["NOUN","PROPN","ADJ"].include?(upos)
        if msd2[1] == "GEN"
            feats << "Case=Gen"
        else
            feats << "Case=Nom"
        end
    end

    
    if upos == "PRON" or upos == "DET"
        if !@posslemmas[lemma].nil?
            lemma = @posslemmas[lemma]
        end

        if (lemma == "de" or lemma == "den") and upos == "PRON"
            prontype = "Prs"
        elsif (lemma == "de" or lemma == "den") and upos == "DET"
            prontype = "Art"
        else
            prontype = @prontypes[lemma]
        end
        if prontype == "" or prontype.nil?
            STDOUT.puts "Unknown prontype! #{lemma} #{sent_id}"
        else
            feats << "PronType=#{prontype}"
        end
    end

    if upos == "VERB" and !feats.join.include?("VerbForm")
        feats << "VerbForm=Fin"
    end

    if pos == "UO"
        feats << "Foreign=Yes"
    end
    if upos == "PART" and (lemma == "inte" or lemma == "icke" or lemma == "ej")
       feats << "Polarity=Neg"
    end    

    if pos == "VB"
        if feats.include?("Voice=Pass") 
            if lemma[-1] == "s" 
                feats.delete("Voice=Pass")
            elsif @nonsfolemmas.include?(lemma)
                feats.delete("Voice=Pass")
                lemma = "#{lemma}s"
                #STDOUT.puts lemma
            end
        end
            
        if lemma == "må"
            if feats.include?("Mood=Sub")
                feats.delete("Mood=Sub")
                feats << "Mood=Ind"
            end
        end
            

    end

    if form.downcase == "vare" and sentence[id+1]["form"].downcase == "sig" and sentence[id-1]["form"].to_s.downcase != "tack"
        lemma = "vare"
        upos = "CCONJ"
        feats = []
    end

    if lemma == "ju"
        if head > id
            upos = "CCONJ"
            feats = []
        end
    end

    if ["ömsom","dels"].include?(lemma)
        upos = "CCONJ"
        feats = []
    end

    if msd2.include?("FKN")
        feats << "Abbr=Yes"
    end

    if misc.include?("CorrectForm")
        feats << "Typo=Yes"
    end

    #feats.gsub!("||","|")
    #if feats[-1] == "|"
    #    feats = feats[0..-2]
    #end
    #if feats[0] == "|"
    #   feats = feats[1..-1]
    #end

    #feats = feats.split("|").sort.join("|")
    feats = feats.uniq.sort.join("|")
    if feats == ""
        feats = "_"
    end

    if upos != "PUNCT" and upos != "SYM"
        lemma.gsub!("|","")
    end

    if lemma == "_" or lemma == ""
        lemma = form.clone
    end

    if upos == "" or upos.nil?
        STDOUT.puts "Empty UPOS #{lemma} #{id} #{sent_id}"
    end

    return upos, feats, lemma
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
                #STDERR.puts sent_id
            end
        else
            line2 = line1.split("\t")
            id = line2[0].to_i
            form = line2[1]
            lemma = line2[2].gsub("|","")
            pos = line2[3]
            msd2 = line2[4].split(".")
            msd = line2[5].split(".")[1..-1]
            head = line2[6].to_i
            deprel = line2[7]
            extra1 = line2[8]
            misc = line2[9].to_s
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
                sentence[id] = {"form"=>form,"msd"=>msd,"msd2"=>msd2,"head"=>head,"deprel"=>deprel,"lemma"=>lemma, "extra1"=>extra1, "misc"=> misc, "pos" => pos} 
            end
            #STDERR.puts sentence[id]["head"]

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
                newhead = idhash[senthash["head"]]
                sentence2[newid] = senthash
                sentence2[newid]["head"] = newhead
            end
            sentence = sentence2.clone
            #STDERR.puts "#{sentence}"

            sentence.each_pair do |id,senthash|
                upos, feats, lemma = convert(id, sentence, sent_id)
                line3 = [id, senthash["form"], lemma, upos, "_", feats, senthash["head"], senthash["deprel"], senthash["extra1"], senthash["misc"]].join("\t")
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