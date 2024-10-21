require 'io/console'

# reverse head-dependent for content words
# coordination
# aux-main verb (subject predicative)

#? Decide the systematic way to deal with coordination (## multiple heads in coordination?)

#check labels in general and heads of MWEs in particular (currently just inheriting head node automatically, should be OK) 
#check if we need @reversed_labels2 (yes we do for 17 and 34, but what do we actually want for them?), check if labels for MWE non-heads are OK
#Check Romn_Lundqvist-Ingentobak.45: HD in secondary edges

#?: do embedded *Ms exist? Yes: Romn_Holmsen-Polynesiskpassad.102 and 376. Are they correct, though?
#the third type of MWEs: seems to be OK?

#questions to Gerlof that are already sent

#17 and 34 fixed by dispreferring PH-roots: but is it reliable?
#headless: treat more systematically depending on type? (NPs)
## other stragegies: use first, use root, go down? Maybe not needed?

#conversion:
#convert ids
#tokenization
#proper names: restore info
#verbal particles
#adjectives: adverbs? masc, fem?
#graphical connection


verbose = ARGV[1]
if verbose.nil?
    verbose = false
end

require "Nokogiri"

def nodeid_to_integer(sent_id,node_id)
    #STDERR.puts "..#{node_id}"
    if node_id.nil?
        id = "9999"
    elsif node_id != 0
        id = node_id.gsub("#{sent_id}.","")
        #id = id.to_i - 1000
    else
        id = node_id
    end
    return id
end

def deal_with_mwes(primary_tree, current_id, phrases, term_ids, words, verbose)
    if verbose then STDERR.puts "New method" end
    until false == true do
        next_level = primary_tree[current_id]
        if verbose then STDERR.puts "Current_id: #{current_id}" end
        if verbose then STDERR.puts "Current_id: #{current_id} Next level: #{next_level}" end
        #STDIN.getch
        next_level.each.with_index do |node,nodeindex|
            if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node}" end
            if !term_ids.include?(node)
                if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal" end
                cat = phrases[node]
                #STDIN.getch
                if cat[2] == "M" #MWE
                    if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal MWE" end
                    #STDIN.getch
                    mwe = primary_tree[node].clone
                    if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal MWE #{mwe}" end
                    if mwe.length > 1 #non_analyzable
                        head = nil
                        mwe.each do |mwenode|
                            if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal MWE Non-analyzable Looking for head" end
                            if words[mwenode]["pos"] == cat[0..1]
                                #flag = true
                                head = mwenode.clone
                                if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal MWE Non-analyzable Head #{head}" end
                                break
                            end
                        end
                        if head.nil? #assign head even if there was no pos match
                            head = mwe[0].clone
                            if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal MWE Non-analyzable No real head found #{head}" end
                        end
                        
                        if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal MWE Restructuring the tree" end
                                
                        #@primary_tree[current_id] << head
                        #@primary_labels[current_id][nodeindex] = @primary_labels[node].clone
                        
                        #@reversed_labels[head] = @primary_labels[node].clone
                        #@primary_tree[head] = []
                        #change labels, too
                        mwe.each.with_index do |mwenode, mwenodeindex|
                            if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal MWE Reassigning heads" end
                                
                            if mwenode != head
                                #@primary_tree[head] << mwenode
                                @reversed_tree[mwenode] = head #next_level[head_label_index]
                                #@reversed_labels[mwenode] = "HD-#{cat}"
                                @reversed_labels[mwenode] = @primary_labels[node][mwenodeindex]
                            end
                        end
                    else
                        if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal MWE Analyzable" end
                        head = mwe[0].clone
                    end
                    @primary_tree[current_id][nodeindex] = head.clone
                    @primary_tree.delete(node)
                    @mwes_replaced[node] = head.clone
                else
                    if verbose then STDERR.puts "Current_id: #{current_id} Node: #{node} Nonterminal Usual" end
                    #STDIN.getch
                    deal_with_mwes(primary_tree, node, phrases, term_ids, words, verbose)
                end
                
            end
        end
        if verbose then STDERR.puts "Current_id: #{current_id} Going up" end
        break
    end
end

def process_primary_tree(primary_tree, primary_labels, current_id, term_ids, phrases, root, sent_id, phraselabel,verbose)
    #current_id = "#{sent_id}.0"
    #root = 0
    cat = phrases[current_id]
    #STDERR.puts "current_id", current_id
    #gets
    if verbose then STDERR.puts "Current_id: #{current_id}" end
    #STDERR.puts "*** #{primary_tree["Romn_Lundqvist-Ingentobak.20.5"]} ***"

    until false == true do
        next_level = primary_tree[current_id]
        if verbose then STDERR.puts "Current_id: #{current_id} Next level: #{next_level}" end
        labels = primary_labels[current_id]
        head_label_index = labels.index("HD") 

        
  
        
        if cat == "Top"
            #root = 0
            if verbose then STDERR.puts "Current_id: #{current_id} Cat: #{cat}" end
        else
            if verbose then STDERR.puts "Current_id: #{current_id} Cat: #{cat}" end
            head_label_index = labels.index("HD") 
            
            if head_label_index.nil?
                head_label_index = labels.index("PH")
            else
                if verbose then STDERR.puts "Current_id: #{current_id} HD found: #{next_level[head_label_index]}" end
            end
            if !head_label_index.nil?
                if verbose then STDERR.puts "Current_id: #{current_id} HD or PH found: #{next_level[head_label_index]}" end
                temphead = next_level[head_label_index].clone
                if term_ids.include?(temphead)
                    head = temphead.clone
                    if verbose then STDERR.puts "Current_id: #{current_id} HD or PH confirmed as terminal: #{next_level[head_label_index]}" end
                else
                    if verbose then STDERR.puts "Current_id: #{current_id} HD or PH erased: non-terminal" end
                    head_label_index = nil
                end
            else
                if verbose then STDERR.puts "Current_id: #{current_id} No HD or PH found" end
            end
            if head_label_index.nil?
                if verbose then STDERR.puts "Current_id: #{current_id} Assigning first node as a head" end
                next_level.each.with_index do |node, nodeindex|
                    if term_ids.include?(node)
                        head = node.clone
                        head_label_index = nodeindex
                        if verbose then STDERR.puts "Current_id: #{current_id} Assigned first node as a head: #{head}" end
                        #STDERR.puts "Current_id: #{current_id} FIRST NODE AS HEAD #{head}"
                        break
                    end
                end
                if head_label_index.nil?
                    if verbose then STDERR.puts "Current_id: #{current_id} No first node found. Assigning root #{root} as head" end
                    head = root.clone
                    #STDERR.puts "Current_id: #{current_id} ROOT AS HEAD #{head}"
                    #abort
                end
            end
        end
        @head_by_nt[current_id] = head.clone
        if verbose then STDERR.puts "  Current_id: #{current_id} Root: #{root}" end
        if verbose then STDERR.puts "  Current_id: #{current_id} Head: #{head}" end
        #if verbose then STDERR.puts "Next level: #{next_level}" end

        next_level.each.with_index do |node,nodeindex|
            if verbose then STDERR.puts "  Current_id: #{current_id}. Terminal run. Node: #{node}" end
            if term_ids.include?(node)
                if verbose then STDERR.puts "    Current_id: #{current_id}. Node: #{node}. Terminal node" end
                if cat == "Top" #head.nil?#root == 0
                    if verbose then STDERR.puts "    Current_id: #{current_id}. Terminal under 0" end
                    #@reversed_tree[node] = root
                    @reversed_labels[node] = labels[nodeindex]
                    @underoldroot[node] = true
                else
                    #if verbose then STDERR.puts "    Current_id: #{current_id}. Terminal not under 0" end
                    

                    if node == head #nodeindex == head_label_index
                        
                        if root == 0 and @newroot.nil? #and cat != "KoP"
                            if verbose then STDERR.puts "    Current_id: #{current_id}. New root!" end
                            @newroot = node.clone#.gsub("#{sent_id}.","").to_i
                        end
                        if verbose then STDERR.puts "    Current_id: #{current_id}. Phrase head" end
                        if verbose then STDERR.puts "    Current_id: #{current_id}. Ends up under ('root') #{root}" end
                        @reversed_tree[node] = root
                        if root == 0
                            @under0 << node
                        end
                        #root = node.gsub("#{sent_id}.","").to_i
                        @reversed_labels[node] = phraselabel #"#{labels[nodeindex]}-#{cat}-#{phraselabel}"
                        @reversed_labels2[node] = "#{labels[nodeindex]}-#{cat}-#{phraselabel}"
                    else
                        if verbose then STDERR.puts "    Current_id: #{current_id}. Not a head" end
                        if verbose then STDERR.puts "    Current_id: #{current_id}. Ends up under ('head') #{head}" end
                        @reversed_tree[node] = head #next_level[head_label_index]
                        @reversed_labels[node] = labels[nodeindex]
                    end
                end
            end
        end
        #if verbose then STDERR.puts "Next level: #{next_level}" end
       
        next_level.each.with_index do |node,nodeindex|
            if verbose then STDERR.puts "  Current_id: #{current_id}. Nonterminal run. Node: #{node}" end
            if !term_ids.include?(node)
                if verbose then STDERR.puts "    Current_id: #{current_id}. Node: #{node}. Nonterminal node" end
                #root = current_id.gsub("#{sent_id}.","").to_i
                if cat != "Top" #!head.nil?
                    root = head.clone#.gsub("#{sent_id}.","").to_i
                end
                phraselabel = labels[nodeindex]

                #if root != 0
                #    root = next_level[head_label_index].gsub("#{sent_id}.","").to_i
                #end
                if verbose then STDERR.puts "    Current_id: #{current_id}. Going down. Root #{root}" end
                process_primary_tree(primary_tree, primary_labels, node, term_ids, phrases, root, sent_id, phraselabel,verbose)
            end
        end
        if verbose then STDERR.puts "    Current_id: #{current_id}. Going up" end
        break
    end 
    mainroot = 0
    if @under0.length > 1
        @under0.each do |node|
            if !@reversed_labels2[node].include?("PH")
                mainroot = node.clone
                break
            end
        end
        @under0.each do |node|
            if node != mainroot
                @reversed_tree[node] = mainroot
            end
        end
    else
        mainroot = @newroot.clone
    end
    if @newroot.nil?
        mainroot = root.clone
    end
    @underoldroot.keys.each do |node|
        @reversed_tree[node] = mainroot
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
#excluded_sents = {"Romn_Holmsen-Polynesiskpassad.102" => true, "Romn_Holmsen-Polynesiskpassad.376" => true}

excluded_sents = {}
subcorpora.each do |subcorpus|
    subcorpus_id = subcorpus["name"]
    
    STDERR.puts subcorpus_id
    sentences = subcorpus.css("s").to_a
    sentences.each do |sentence|
        primary_tree = Hash.new{|hash, key| hash[key] = Array.new}
        primary_labels = Hash.new{|hash, key| hash[key] = Array.new}
        secondary_tree = Hash.new{|hash, key| hash[key] = Array.new}
        secondary_labels = Hash.new{|hash, key| hash[key] = Array.new}
        sent_id = sentence["id"]
        if !excluded_sents[sent_id]
            #STDERR.puts sent_id
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
                secedges = nonterminal.css("secedge").to_a
                #STDERR.puts nonterm_id
                edges.each do |edge|
                    label = edge["label"]
                    idref = edge["idref"]
                    primary_tree[nonterm_id] << idref
                    primary_labels[nonterm_id] << label
                end
                secedges.each do |secedge|
                    seclabel = secedge["label"]
                    secidref = secedge["idref"]
                    secondary_tree[nonterm_id] << secidref
                    secondary_labels[nonterm_id] << seclabel
                end
                
            end
            #STDERR.puts "*** #{primary_tree["Romn_Lundqvist-Ingentobak.20.5"]} ***"
            #abort
            @underoldroot = {}
            @reversed_tree = {}
            @reversed_labels = {}
            @reversed_labels2 = {}
            @reversed_secondary_tree = Hash.new{|hash, key| hash[key] = Array.new}
            @reversed_secondary_labels = Hash.new{|hash, key| hash[key] = Array.new}
            
            @newroot = nil
            @under0 = []
            @primary_tree = primary_tree.clone
            @primary_labels = primary_labels.clone
            @head_by_nt = {}
            @root_by_nt = {}
            @mwes_replaced = {}
            #@primary_tree.each_pair do |key,value|
            #    STDERR.puts "#{key},#{value},#{@primary_labels[key]}"
            #    
            #end
            #STDERR.puts ""
            deal_with_mwes(primary_tree, "#{sent_id}.0", phrases, term_ids, words, verbose)
            #@primary_tree.each_pair do |key,value|
            #    STDERR.puts "#{key},#{value},#{@primary_labels[key]}"
            #    
            #end
            #STDERR.puts ""
            #STDERR.puts @reversed_tree
            #STDERR.puts ""
            #STDERR.puts @reversed_labels
            #STDERR.puts ""
            primary_tree = @primary_tree.clone
            primary_labels = @primary_labels.clone
            #abort
            process_primary_tree(primary_tree, primary_labels, "#{sent_id}.0", term_ids, phrases, 0, sent_id,"",verbose)
            secondary_tree.each_pair do |nt, towardsarray|
                seclabelarray = secondary_labels[nt]
		    
                towardsarray.each.with_index do |towards, towardsindex|
                    seclabel = seclabelarray[towardsindex]
                    @reversed_secondary_labels[towards] << seclabel
                    if !@head_by_nt[nt].nil?
                        towardshead = @head_by_nt[nt].clone
                    else
                        towardshead = @mwes_replaced[nt]
                    end
		    
                    if term_ids.include?(towards)
                        @reversed_secondary_tree[towards] << towardshead
                    else
                        @reversed_secondary_tree[@head_by_nt[towards]] << towardshead
                    end
		    
                end
                
            end
		    
		    
            outputfile.puts "# corpus = #{filename}"
            outputfile.puts "# subcorpus = #{subcorpus_id}"
            outputfile.puts "# sent_id = #{sent_id}"
            term_ids.sort.each do |term_id|
                #STDERR.puts term_id
                info = words[term_id]
                head = nodeid_to_integer(sent_id,@reversed_tree[term_id])
                deprel = @reversed_labels[term_id]
                if @reversed_secondary_tree[term_id].length != 0
                    secdep = "#{head}:#{deprel}"
                    @reversed_secondary_tree[term_id].each.with_index do |from,fromindex|
                        seclabel = @reversed_secondary_labels[term_id][fromindex]
                        secdep << "|#{nodeid_to_integer(sent_id,from)}:#{seclabel}"
                    end
                    
                    
                end
                
                outputfile.puts "#{nodeid_to_integer(sent_id,term_id)}\t#{info["word"]}\t#{info["lemma"]}\t#{info["pos"]}\t#{info["msd2"]}\t#{info["msd"]}\t#{head}\t#{deprel}\t#{secdep}\t"
            end
#STDERR.    puts @reversed_tree
            #STDERR.puts @reversed_labels
            #abort
            outputfile.puts ""
        end
    end


end

