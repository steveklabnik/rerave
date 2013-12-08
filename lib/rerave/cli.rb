require 'thor'
require 'fileutils'
require 'mechanize'

module Rerave
  class CLI < Thor

    desc "clear", "Clear out the cached scores."
    def clear
      dir = "#{Dir.home}/.rerave/"
      FileUtils.rm_rf(dir)
    end

    desc "top", "Create local archive of top scores"
    def top
      top_scores = {}
      dir = "#{Dir.home}/.rerave/"

      FileUtils.mkdir_p(dir)

      top_file = "#{dir}/top_scores.dump"
      unless Pathname.new(top_file).exist?
        top_scores = scrape_top_scores

        File.open(top_file,'wb') do |f|
          f.write Marshal.dump(top_scores)
        end
      end
    end

    desc "scores [username]", "Create local archive of your scores"
    def scores(username)
      user_scores = {}
      dir = "#{Dir.home}/.rerave/"

      FileUtils.mkdir_p(dir)

      user_file = "#{dir}/#{username}_scores.dump"
      unless Pathname.new(user_file).exist?
        user_scores = scrape_scores(username)

        File.open(user_file,'wb') do |f|
          f.write Marshal.dump(user_scores)
        end
      end
    end

    desc "next [username]", "Calculate top songs to play next"
    def next(username)
      dir = "#{Dir.home}/.rerave/"

      top
      top_file = "#{dir}/top_scores.dump"
      top_scores = Marshal.load (File.binread(top_file))

      scores(username)
      user_file = "#{dir}/#{username}_scores.dump"
      user_scores = Marshal.load (File.binread(user_file))

      diff = {}

      top_scores.each do |name, scores|
        user_difficulties = user_scores[name]
        scores.each do |difficulty, score|
          diff["#{name}: #{difficulty}"] = score - user_difficulties[difficulty]
        end
      end

      puts "Here are the songs #{username} should play next:"

      diff.sort_by{|k, v| v }.reverse.take(20).each_with_index do |(name, difference), i|
        puts "##{i + 1}: #{name} (#{difference})"
      end
    end

    private

      def scrape_top_scores
        print "Scraping top scores"
        a = Mechanize.new
        scores = {}

        (1..10).each do |i|
          print "." 
          a.get("http://www.rerave.com/music/page/#{i}/") do |music_page|
            music_page.links_with(text: "Top iOS Scores").each do |score_link|
              easy, hard, master = nil, nil, nil

              score_page = a.click(score_link)
              name = score_page.search("#leaderboard_info h1").text

              easy_page = a.click(score_page.link_with(text: "Easy"))

              easy_page.search(".ranking_row").each do |row|
                easy = row.search(".score_easy + .score_easy").text.gsub(/\D/, "").to_i
              end

              hard_page = a.click(score_page.link_with(text: "Hard"))
              hard_page.search(".ranking_row").each do |row|
                hard = row.search(".score_hard + .score_hard").text.gsub(/\D/, "").to_i
              end

              master_page = a.click(score_page.link_with(text: "Master"))
              master_page.search(".ranking_row").each do |row|
                master = row.search(".score_master + .score_master").text.gsub(/\D/, "").to_i
              end

              scores[name] = {"easy" => easy, "hard" => hard, "master" =>  master}
            end
          end
        end

        puts "done."
        
        scores
      end

      def scrape_scores(username)
        puts "Scraping scores for #{username}"
        a = Mechanize.new
        scores = {}

        a.get("http://www.rerave.com/rankings/?rankings_search=#{username}&platform=iOS") do |my_page|
          my_page.search(".ranking_row .ranking_row").each do |row|
            print "."
            easy = row.search("span.score_easy.score_span").text.gsub(/\D/, "").to_i
            hard = row.search("span.score_hard.score_span").text.gsub(/\D/, "").to_i
            master = row.search("span.score_master.score_span").text.gsub(/\D/, "").to_i
            
            name = row.search(".ranking_data h1").text
            
            scores[name] = {"easy" => easy, "hard" => hard, "master" =>  master}
          end
        end

        puts "done."

        scores
      end
  end
end
