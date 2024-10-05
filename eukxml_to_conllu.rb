#ROOT ISSUES! #check? reroute punctuation to root rather than 0? Can be done later.
#OUTPUT TO PSEUDO conll
#headless phrases etc.
#secondary tree
#conversion
#tokenization
require "Nokogiri"

def process_primary_tree(primary_tree, primary_labels, current_id, term_ids,phrases,root, sent_id)
    #current_id = "#{sent_id}.0"
    #root = 0
    cat = phrases[current_id]
    STDERR.puts "current_id", current_id
    #gets
    until false == true do
        next_level = primary_tree[current_id]
        labels = primary_labels[current_id]
        head_label_index = labels.index("HD")
        if !head_label_index.nil?
            head = next_level[head_label_index]
        else
            head = nil
        end

        next_level.each.with_index do |node,nodeindex|
            STDERR.puts "node", node
            if term_ids.include?(node)
                STDERR.puts "Terminal node"
                if head.nil?#root == 0
                    STDERR.puts "Terminal under 0"
                    @reversed_tree[node] = root
                    @reversed_labels[node] = primary_labels[current_id][nodeindex]
                else
                    STDERR.puts "Terminal not under 0"
                    if node == head #nodeindex == head_label_index
                        STDERR.puts "Phrase head"
                        @reversed_tree[node] = root
                        #root = node.gsub("#{sent_id}.","").to_i
                        @reversed_labels[node] = "#{primary_labels[current_id][nodeindex]}-#{cat}"
                    else
                        STDERR.puts "Not a head"
                        @reversed_tree[node] = head #next_level[head_label_index]
                        @reversed_labels[node] = primary_labels[current_id][nodeindex]
                    end
                end
            else
                STDERR.puts "Nonterminal node"
                #root = current_id.gsub("#{sent_id}.","").to_i
                if !head.nil?
                    root = head.gsub("#{sent_id}.","").to_i
                end
                #if root != 0
                #    root = next_level[head_label_index].gsub("#{sent_id}.","").to_i
                #end
                process_primary_tree(primary_tree, primary_labels, node, term_ids, phrases, root, sent_id)
            end
        end
        break
    end 
    #return [reversed_tree,reversed_labels]
end


#PATH = "C:\\Sasha\\D\\DGU\\SBX_resources\\Eukalyptus-1.0.0\\Annotations\\"
PATH = "D:\\DGU\\SBX_resources\\Eukalyptus\\Eukalyptus-1.0.0\\Annotations\\"
filename = "Eukalyptus_Romaner.xml"
STDERR.puts "Parsing xml..."
file = Nokogiri::XML(File.read("#{PATH}#{filename}"))
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
            STDERR.puts nonterm_id
            edges.each do |edge|
                label = edge["label"]
                idref = edge["idref"]
                primary_tree[nonterm_id] << idref
                primary_labels[nonterm_id] << label
            end
            
        end
        STDERR.puts primary_tree
        @reversed_tree = {}
        @reversed_labels = {}
    
        process_primary_tree(primary_tree, primary_labels, "#{sent_id}.0", term_ids, phrases, 0, sent_id)
        STDERR.puts @reversed_tree
        STDERR.puts @reversed_labels
        abort
        
    end


end