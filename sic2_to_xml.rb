f = File.open("C:\\Sasha\\D\\DGU\\SVN\\SVN_pub\\downloadable_corpora\\sic2\\sic2.conllu", "r:utf-8")
o = File.open("C:\\Sasha\\D\\DGU\\SVN\\SVN_pub\\downloadable_corpora\\sic2\\sic2.xml", "w:utf-8")

sexes = {188519 => "female", 5089 => "female", 54523 => "female", 13263 => "male", 265827 => "female"}
years = {188519 => 1966, 5089 => 1985, 54523 => 1980, 265827 => 1995}
cities = {188519 => "Jönköping", 5089 => "Karlshamn", 54523 => "Nynäshamn", 265827 => "Stockholm"}
current_blog = 0
current_post = 0
nameflag = 0
spaces = "        "
o.puts "<corpus>"
f.each_line.with_index do |line, index|
    line1 = line.strip
    if index > 0
        if line1[0] == "#"
            blog_id = line1[2..-1].split("-")[0]
            post_id = line1[2..-1].split("-")[1].split(":")[0]
            sent_id = line1[2..-1].split("-")[1].split(":")[1]

            if post_id != current_post
                if current_post != 0
                    o.puts "    </post>"
                end
                if blog_id != current_blog
                    if current_blog != 0
                        o.puts "  </blog>"
                    end
                    bloginfo = "  <blog id=\"#{blog_id}\" sex=\"#{sexes[blog_id.to_i]}\""
                    if !years[blog_id.to_i].nil?
                        bloginfo << " born=\"#{years[blog_id.to_i]}\" municipality=\"#{cities[blog_id.to_i]}\">"
                    end
                    bloginfo << ">"
                    #o.puts "  <blog id=\"#{blog_id}\" sex=\"#{sexes[blog_id.to_i]}\" born=\"#{years[blog_id.to_i]}\" municipality=\"#{cities[blog_id.to_i]}\">"
                    o.puts bloginfo
                    current_blog = blog_id
                end
                o.puts "    <post id=\"#{post_id}\">"
                current_post = post_id
            end
            o.puts "      <sentence id=\"#{sent_id}\">"
        elsif line1 == ""
            if nameflag > 0
                begin
                    nameflag -= 1
                    spaces = spaces[0..-3]
                    o.puts "#{spaces}</name>"
                end until nameflag == 0
            end
            o.puts "      </sentence>"
        else
            
            line2 = line1.split("\t")
            form = line2[1].gsub("\"","&quot;").gsub("&","&amp;")
            lemma = line2[2].gsub("\"","&quot;").gsub("&","&amp;")
            ne_tag= line2[10]
            
            if ne_tag == "B"
                o.puts "#{spaces}<name type=\"#{line2[11]}\">"
                nameflag += 1
                spaces << "  "
            end
            if nameflag > 0
                if ne_tag == "O"
                    spaces = spaces[0..-3]
                    o.puts "#{spaces}</name>"
                    nameflag -= 1
                end
            end

            output = "#{spaces}<token id=\"#{line2[0]}\" lemma=\"#{lemma}\" pos=\"#{line2[3]}\" msd=\"#{line2[4]}\""
            if line2[5] != "_"
                output << " feats=\"|#{line2[5]}|\""
            end
            #output << " ne_tag=\"#{line2[10]}\""
            #if line2[11] != "_"
            #    output << " ne_type=\"#{line2[11]}\""
            #end
            output << ">#{form}</token>"
            o.puts output
            
            #o.puts "<        token id=\"#{line2[0]}\" lemma=\"#{line2[2]}\" pos=\"#{line2[3]}\" msd=\"#{line2[4]}\" feats=\"|#{line2[5]}|\" ne_tag=\"#{line2[10]}\" ne_type=\"#{line2[11]}\">#{line2[1]}</token>"
        end
    end
end

o.puts "    </post>"
o.puts "  </blog>"
o.puts "</corpus>"