filename = ARGV[0]
inputfile = File.open("#{filename}.conllu","r:utf-8")
outputfile = File.open("#{filename}_ud.conllu","w:utf-8")

@matchingu = {"PE" => "ADP"}
@matchingp = {"PE" => "PP"}

def convert(pos, msd)


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
            msd = line2[5]
        end
    else
        outputfile.puts output
        output = []
    end
end