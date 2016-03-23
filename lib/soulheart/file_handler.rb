module Soulheart
  class FileHandler < Base
    def initialize(params={})
      @batch_size = params[:batch_size] || 1000
      @no_all = params[:no_all] || false
      @no_combinatorial = params[:no_combinatorial] || false
      @normalize_regex = params[:normalize_regex] || false
      @normalize_no_sym = params[:normalize_no_sym] || false
      @remove_results = params[:remove_results] || false
      @no_log = params[:no_log] || false
      @count = 0
    end

    def open_file(file)
      require 'uri'
      if file =~ URI.regexp
        require 'open-uri'
        open(file)
      elsif File.exist?(file)
        File.open(file)
      else
        raise StandardError, "Couldn't open file: #{file}"
      end
    end

    def load(filename)
      f = open_file(filename)
      start_time = Time.now.to_i
      @loader ||= Soulheart::Loader.new({no_all: @no_all, no_combinatorial: @no_combinatorial})
      begin
        case filename.downcase
        when /(c|t)sv\z/
          load_spreadsheet(f)
        when /json\z/
          load_json(f)
        else
          log 'unknown File type' 
        end
      ensure
        f.close
      end
      log "Total time to load:                                  #{Time.now.to_i - start_time} second(s)" 
    end

    def load_json(f)
      log 'Reading JSON'
      log "Loading items in batches of #{@batch_size} ..."
      pp f
      begin
        fail if f.readlines.size > 2
        load_json_stream(f) 
      rescue
        pp 'rescued'
        load_non_stream_json(f)
      end
    end

    def stop_words(filename)
      f = open_file(filename)
      Soulheart.stop_words = f.readlines.map(&:strip).reject(&:empty?)
    end

    def normalize(filename=nil)
      if @normalize_regex
        f = open_file(filename)
        log "Updating normalizer: regular expression - " + f.readlines.map(&:strip).reject(&:empty?).first 
        Soulheart.normalizer = f.readlines.map(&:strip).reject(&:empty?).first
      elsif @normalize_no_sym
        log "Updating normalizer: allow symbols" 
        Soulheart.normalizer = ''
      else
        log "Updating normalizer: default settings"     
        Soulheart.normalizer = Soulheart.default_normalizer
      end
    end


    protected

    def spreadsheet_seperator(line='')
      line.match("\t") ? "\t" : ','
    end

    def header_map(header_line=nil, sep=nil, header: nil)
      header_line.parse_csv(col_sep: sep).compact.map(&:strip)
    end

    # This handles a bunch of different issues with csvs
    def load_spreadsheet(f)
      require 'csv'
      sep, header = nil, nil
      until sep || f.eof?
        line = f.gets
        next unless line && line.strip != ''
        unless header && header.any?
          sep = spreadsheet_seperator(line)
          header = header_map(line, sep)
          next # Because either no header, or this line is a header
        end
      end
      log "Reading a CSV"
      lines = []
      CSV.foreach(f, headers: true, col_sep: sep) do |row|
        lines << row.to_hash
        @count += 1
      end
      @loader.load(lines)
    end

    def load_json_stream(f)
      until f.eof?
        lines = []
        @batch_size.times do
          break if f.eof?
          line = f.gets
          next unless line && line.strip != ''
          lines << MultiJson.load(line)
          @count += 1
        end
        @loader.load(lines)
      end
    end

    def load_non_stream_json(f)
      f.rewind
      @loader.load(MultiJson.load(f))
      log "Using line delineated JSON streams uses less memory and allows batch loading.\nConsider using them, particularly with larger data sets.\nhttps://sethherr.github.io/soulheart/loading_data/"
    end
  end
end