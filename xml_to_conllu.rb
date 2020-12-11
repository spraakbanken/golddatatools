### Conversion of Språkbanken xml files to (pseudo-) CONLLU. Aleksandrs Berdicevskis, 2020-06-09 ###

#require_relative 'paths.rb'
require "Nokogiri"

STDERR.puts "Usage: ruby xml_to_conllu.rb xml_file_name convert_upos? [corpus_type]. The xml file has to be in the same directory. Set convert_upos? to 1 if you want to convert POS into UPOS (in a very simple and imperfect way), 0 otherwise (if you want to use the SUC-style POS as UPOS). Set corpus_type to suc only if you are converting suc3.xml and want to preserve text ids."

#filename = "#{$corpora_path}#{ARGV[0]}"
filename = ARGV[0]
corpus_type = ARGV[2]
if corpus_type == "suc"
    top_level_unit = "text"
else
    top_level_unit = "corpus"
end


create_feats = true
output_non_converted_msds = false
syntax = true
lemma = true
convert_upos = ARGV[1]

# provided by Leif-Jöran Olsson
@upos_mappings = {"NN" => "NOUN", "PM" => "PROPN", "VB" => "VERB", "IE" => "PART", "PC" => "VERB", "PL" => "PART", "PN" => "PRON", "PS" => "PRON", "HP"=> "PRON", "HS" => "PRON", "DT" => "DET", "HD" => "DET", "JJ" => "ADJ", "HA" => "ADV", "KN" => "CONJ", "SN" => "SCONJ", "PP" => "ADP", "RG" => "NUM", "RO" => "ADJ", "IN" => "INTJ", "UO" => "X", "MAD" => "PUNCT", "PAD" => "PUNCT"}

#LJo: PS, HS => DET, "AB" => "ADV",
#Potential improvements:
#UO should in most cases be tagged according to the original POS, but we opt for X
#Not all cases when MID becomes SYM are currently captures (e.g. 228:218, where the colon is mathematical operator)

#SUC-issues:
#kl and kl. are AB in SUC, but does it make sense? I'm making them NOUN in UD

#TO-DO:
#go through UD github
#AB: lemmas, some misannotations where they should in fact be JJ
#VB: create heuristics for AUX (if there is an infinitive dependent?). No, give up.
#PL: reda (asked); ADP-ADV (in principle, all PL should be ADVs, but many of them seem rather ADPs. Bakom-ADV is meaningless, av and efter should be ADV; emot ???)
#PC: keep as ADJ, but change lemmas: ange, nämna (or give up?). UD principle seems to be: if they are amods, make them ADJs


@msds = {"UTR" => "Gender=Com", "NEU" => "Gender=Neut", "MAS" => "Gender=Masc", "UTR+NEU" => "Gender=Com,Neut",    "SIN" => "Number=Sing", "PLU" => "Number=Plur", "SIN+PLU" => "Number=Plur,Sing", "IND" => "Definite=Ind", "DEF" => "Definite=Def", "IND+DEF" => "Definite=Def,Ind", "NOM" => "Case=Nom", "GEN" => "Case=Gen", "POS" => "Degree=Pos", "KOM" => "Degree=Cmp", "SUV" => "Degree=Sup", "PRS" => "Tense=Pres", "PRT" => "Tense=Past", "INF" => "VerbForm=Inf", "SUP" => "VerbForm=Sup", "IMP" => "Mood=Imp", "AKT" => "Voice=Act", "SFO" => "Voice=Pass", "KON" => "Mood=Sub", "PRF" => "Tense=Past", "AN" => "Abbr=Yes", "SMS" => "Compound=Yes", "SUB" => "Case=Nom", "OBJ" => "Case=Acc", "SUB+OBJ" => "Case=Acc,Nom"}

@non_mapping_msds_for_debug = []

def findfeat(feats,to_find)
    found = false
    feats.each do |feat|
        if feat.include?("#{to_find}=")
            found = true
            break
        end
    end
    return found
end

def convert_msd(msd)
    feats = "_"
    msd = msd.split(".")
    pos = msd[0]
    msd = msd[1..-1]
    msd.delete("-")
    if !["MAD", "MID", "PAD"].include?(pos) and msd.length >= 1 ##if it's not punctuation and if there are msds apart from POS
        feats = []
        msd.each do |msd1|
            if !@msds[msd1].nil?
                feats << @msds[msd1] 
            else
                if !@non_mapping_msds_for_debug.include?(msd1)
                    @non_mapping_msds_for_debug << msd1
                end
            end
        end
        if pos == "PC"
            feats << "VerbForm=Part"
        end
        if pos == "VB" and !feats.include?("Abbr=Yes") and !feats.include?("Compound=Yes") and !findfeat(feats, "VerbForm")
            feats << "VerbForm=Fin"
            
            if !findfeat(feats, "Mood") 
                feats << "Mood=Ind"
            end
        end
        feats.sort!
        feats = feats.join("|")
    end
    
    return feats
end

STDERR.puts "Parsing xml..."
file = Nokogiri::XML(File.read(filename))
STDERR.puts "Searching xml..."
texts = file.css("#{top_level_unit}").to_a

output = File.open("#{filename.split(".")[0]}.conllu","w:utf-8")

STDERR.puts "Converting..."
texts.each do |text|
    if corpus_type == "suc"
        text_id = text["id"]
        if text_id.length == 4 
            output.puts "# newfile id = #{text_id[0..3]}" #File id in SUC (there are 500 files)
        else 
            if text_id[4] == "a"
                output.puts "# newfile id = #{text_id[0..3]}" 
            end 
            output.puts "# newtext id = #{text_id[4]}" #Text id in SUC (there are 1040 texts, some files consist of >1).
        end
    end
    
    sentences = text.css("sentence").to_a
    sentences.each do |sentence|
        sentence_id = sentence["id"].to_s
        output.puts "# sent_id = #{sentence_id}"
        #I am leaving the text field empty so far
        words = sentence.css("w").to_a
        words.each do |word|
            id = word["ref"].to_i
            form = word.text
         
            if lemma
            lemma = word["lemma"].split("|")[1]
                if lemma.nil?
                    lemma = form
                end
            end
            if convert_upos == "1"
                if @upos_mappings[word["pos"]].nil?
                    if word["pos"] == "AB"
                        if ["ej", "icke", "inte"].include?(word["lemma"])
                            upos = "PART"
                        elsif ["kl", "kl."].include?(word["lemma"])
                            upos = "NOUN"
                        else
                            upos = "ADV"
                        end
                    elsif word["pos"] == "MID"
                        if ["-", "/", "+"].include?(word["lemma"])
                            upos = "SYM"
                        else
                            upos = "PUNCT"
                        end
                    elsif word["pos"] == "PL"
                        if word["lemma"] == "reda"
                            upos = "NOUN"
                        end
 
                    end
                else
                    upos = @upos_mappings[word["pos"]]
                end
            else
                upos = word["pos"] 
            end
            xpos = word["msd"] 
            if create_feats 
                feats = convert_msd(xpos)
            else
                feats = "_"
            end
            if syntax
                head = word["dephead"].to_i
                rel = word["deprel"]
                deps = "#{head}:#{rel}"
            else
                head = "_"
                rel = "_"
                deps = "_"
            end
            output.puts "#{id}\t#{form}\t#{lemma}\t#{upos}\t#{xpos}\t#{feats}\t#{head}\t#{rel}\t#{deps}\t_"
        end
        output.puts ""
    end
end

if output_non_converted_msds then STDOUT.puts @non_mapping_msds_for_debug end