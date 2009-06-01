# encoding: utf-8

module Nanoc3::Tasks

  class Clean

    def initialize(site)
      @site = site
    end

    def run
      # Load site data
      @site.load_data

      # Delete all compiled item reps
      filenames.each do |filename|
        FileUtils.rm_f filename
      end
    end

  private

    def filenames
      @site.items.map do |item|
        item.reps.map do |rep|
          rep.raw_path
        end
      end.flatten
    end

  end

end