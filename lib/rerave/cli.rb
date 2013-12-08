require 'thor'
require 'fileutils'
require 'mechanize'

module Rerave
  class CLI < Thor

    desc "top", "Create local archive of top scores"
    def top
      top_scores = {}
      dir = "#{Dir.home}/.rerave/"

      FileUtils.mkdir_p(dir)

      top_file = "#{dir}/top_scores.dump"
      unless Pathname.new(top_file).exist?
        top_scores = scrape_scores

        File.open(top_file,'wb') do |f|
          f.write Marshal.dump(top_scores)
        end
      else
	puts "Cached top scores exist, loading from cache."
        top_scores = Marshal.load (File.binread(top_file))
      end
    end

    desc "scores [username]", "Create local archive of your scores"
    def scores(username)
    end

    desc "next [username]", "Calculate top songs to play next"
    def next(username)
      top
      scores(username)
    end

    private

      def scrape_scores
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


  end
end
