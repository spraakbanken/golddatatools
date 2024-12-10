filename = ARGV[0]
inputfile = File.open("#{filename}.conllu","r:utf-8")
outputfile = File.open("#{filename}_ud.conllu","w:utf-8")

@matchingu = {"PE" => "ADP","AJ" => "ADJ","NN"=>"NOUN"}
@matchingp = {"PE" => "PP"}
@matchfeats = {"-.-.-" => "_", "IND" => "Definite=Ind", "DEF" => "Definite=Def", "POS" => "Degree=Pos", "KOM" => "Degree=Cmp", "SUV"=> "Degree=Sup", "UTR" => "Gender=Com", "NEU" => "Gender=Neut", "SIN" => "Number=Sing", "PLU" => "Number=Plur"}

#case: check whether it spreads somewhere it shouldn't. Do any syncrectic cases disappear?
#lexical mismatches
#syncretism: just disappear (like now)? Or comma?


def convert(pos, msd, msd2)
    upos = @matchingu[pos]
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

inputfile.each_line do |line|
    line1 = line.strip
    if line1 != ""
        if line1[0] == "#"
            output << line1
        else
            line2 = line1.split("\t")
            pos = line2[3]
            msd2 = line2[4].split(".")
            msd = line2[5].split(".")[1..-1]
            upos, feats = convert(pos, msd, msd2)
            line3 = [line2[0..2].join("\t"), upos, "_", feats, line2[6..-1].join("\t")].join("\t")
            output << line3
        end
    else
        outputfile.puts output
        outputfile.puts ""
        output = []
    end
end