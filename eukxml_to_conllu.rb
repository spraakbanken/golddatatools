#Nonsense with 20. Replace head tests with Cat test and deal with headless by assigning a dummy head?
#multiple roots: currently dealing through forbidding coordination. Find better solution? Multiword units?
#headless phrases etc.
#secondary tree
#conversion
#tokenization, MWE etc.
verbose = ARGV[1]
if verbose.nil?
    verbose = false
end

require "Nokogiri"

def nodeid_to_integer(sent_id,node_id)
    if node_id != 0
        id = node_id.gsub("#{sent_id}.","")
        #id = id.to_i - 1000
    else
        id = node_id
    end
    return id
end


def process_primary_tree(primary_tree, primary_labels, current_id, term_ids,phrases,root, sent_id, phraselabel,verbose)
    #current_id = "#{sent_id}.0"
    #root = 0
    cat = phrases[current_id]
    #STDERR.puts "current_id", current_id
    #gets
    if verbose then STDERR.puts "Current_id: #{current_id}" end
    until false == true do
        next_level = primary_tree[current_id]
        labels = primary_labels[current_id]
        head_label_index = labels.index("HD")
        if head_label_index.nil?
            head_label_index = labels.index("PH")
        end

        if !head_label_index.nil?
            head = next_level[head_label_index]
        else
            if cat == "Top"
                head = nil 
            else
                next_level.each.with_index do |node|
                    if term_ids.include?(node)
                        head = node
                        break
                    end
                end
            end
        end

        next_level.each.with_index do |node,nodeindex|
            if verbose then STDERR.puts "  Terminal run. Node: #{node}" end
            if term_ids.include?(node)
                if verbose then STDERR.puts "    Terminal node" end
                if cat == "Top" #head.nil?#root == 0
                    if verbose then STDERR.puts "    Terminal under 0" end
                    #@reversed_tree[node] = root
                    @reversed_labels[node] = labels[nodeindex]
                    @underoldroot[node] = true
                else
                    if verbose then STDERR.puts "    Terminal not under 0" end
                    if verbose then STDERR.puts "    Root #{root}" end

                    if node == head #nodeindex == head_label_index
                        if root == 0 and @newroot.nil? and cat != "KoP"
                            if verbose then STDERR.puts "    New root!" end
                            @newroot = node.clone#.gsub("#{sent_id}.","").to_i
                        end
                        if verbose then STDERR.puts "    Phrase head" end
                        @reversed_tree[node] = root
                        if root == 0
                            @under0 << node
                        end
                        #root = node.gsub("#{sent_id}.","").to_i
                        @reversed_labels[node] = "#{labels[nodeindex]}-#{cat}-#{phraselabel}"
                    else
                        if verbose then STDERR.puts "    Not a head" end
                        @reversed_tree[node] = head #next_level[head_label_index]
                        @reversed_labels[node] = labels[nodeindex]
                    end
                end
            end
        end
        next_level.each.with_index do |node,nodeindex|
            if verbose then STDERR.puts "  Nonterminal run. Node: #{node}" end
            if !term_ids.include?(node)
                if verbose then STDERR.puts "    Nonterminal node" end
                #root = current_id.gsub("#{sent_id}.","").to_i
                if cat != "Top" #!head.nil?
                    root = head.clone#.gsub("#{sent_id}.","").to_i
                end
                phraselabel = labels[nodeindex]

                #if root != 0
                #    root = next_level[head_label_index].gsub("#{sent_id}.","").to_i
                #end
                if verbose then STDERR.puts "    Root #{root}" end
                process_primary_tree(primary_tree, primary_labels, node, term_ids, phrases, root, sent_id, phraselabel,verbose)
            end
        end
        break
    end 
    @underoldroot.keys.each do |node|
        @reversed_tree[node] = @newroot
    end
    if @under0.length > 1
        @under0.each do |node|
            if node != @newroot
                @reversed_tree[node] = @newroot
            end
        end
    end
    #return [reversed_tree,reversed_labels]
end


PATH = "C:\\Sasha\\D\\DGU\\SBX_resources\\Eukalyptus-1.0.0\\Annotations\\"
#PATH = "D:\\DGU\\SBX_resources\\Eukalyptus\\Eukalyptus-1.0.0\\Annotations\\"
filename = ARGV[0]
outputfile = File.open("#{filename}.conllu","w:utf-8")


STDERR.puts "Parsing xml..."
file = Nokogiri::XML(File.read("#{PATH}#{filename}.xml"))
STDERR.puts "Looking for subcorpora..."
subcorpora = file.css("subcorpus").to_a
subcorpora.each do |subcorpus|
    subcorpus_id = subcorpus["name"]
    
    STDERR.puts subcorpus_id
    sentences = subcorpus.css("s").to_a
    sentences.each do |sentence|
        primary_tree = Hash.new{|hash, key| hash[key] = Array.new}
        primary_labels = Hash.new{|hash, key| hash[key] = Array.new}
        secondary_tree = Hash.new{|hash, key| hash[key] = Array.new}
        sent_id = sentence["id"]
        STDERR.puts sent_id
        words = Hash.new{|hash, key| hash[key] = Hash.new}
        phrases = {}
        
        #graph = sentence.css("graph")
        #tpart = graph.css("terminals")
        #STDERR.puts tpart
        terminals = sentence.css("t").to_a
        
        terminals.each do |terminal|
            term_id = terminal["id"]
            words[term_id]["word"] = terminal["word"]
            words[term_id]["pos"] = terminal["pos"]
            words[term_id]["msd"] = terminal["msd"]
            words[term_id]["msd2"] = terminal["msd2"]
            words[term_id]["lemma"] = terminal["lemma"]
            
        end
        term_ids = words.keys

        nonterminals = sentence.css("nt").to_a
        nonterminals.each do |nonterminal|
            nonterm_id = nonterminal["id"]
            cat = nonterminal["cat"]
            phrases[nonterm_id] = cat
            edges = nonterminal.css("edge").to_a
            #STDERR.puts nonterm_id
            edges.each do |edge|
                label = edge["label"]
                idref = edge["idref"]
                primary_tree[nonterm_id] << idref
                primary_labels[nonterm_id] << label
            end
            
        end
        #STDERR.puts primary_tree
        @underoldroot = {}
        @reversed_tree = {}
        @reversed_labels = {}
        @newroot = nil
        @under0 = []
        process_primary_tree(primary_tree, primary_labels, "#{sent_id}.0", term_ids, phrases, 0, sent_id,"",verbose)
        outputfile.puts "# corpus = #{filename}"
        outputfile.puts "# subcorpus = #{subcorpus_id}"
        outputfile.puts "# sent_id = #{sent_id}"
        term_ids.sort.each do |term_id|
            #STDERR.puts term_id
            info = words[term_id]
            
            outputfile.puts "#{nodeid_to_integer(sent_id,term_id)}\t#{info["word"]}\t#{info["lemma"]}\t#{info["pos"]}\t#{info["msd2"]}\t#{info["msd"]}\t#{nodeid_to_integer(sent_id,@reversed_tree[term_id])}\t#{@reversed_labels[term_id]}\t\t"
        end
#STDERR.puts @reversed_tree
        #STDERR.puts @reversed_labels
        #abort
        outputfile.puts ""
    end


end

