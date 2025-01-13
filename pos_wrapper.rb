eukposs = ["AB","AJ","EN","IJ","KO","NN","NU","PE","PO","SU","SY","UO","VB","??"]
#eukposs = ["??"]
eukposs.each do |pos|
    STDERR.puts pos
    system "ruby eukconllu_to_ud.rb eukalyptus_all #{pos}"
    
end