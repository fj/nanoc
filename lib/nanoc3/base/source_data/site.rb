# encoding: utf-8

module Nanoc3

  # The in-memory representation of a nanoc site. It holds references to the
  # following site data:
  #
  # * {#items}         — the list of items         ({Nanoc3::Item})
  # * {#layouts}       — the list of layouts       ({Nanoc3::Layout})
  # * {#code_snippets} — the list of code snippets ({Nanoc3::CodeSnippet})
  # * {#data_sources}  — the list of data sources  ({Nanoc3::DataSource})
  #
  # In addition, each site has a {#config} hash which stores the site
  # configuration.
  #
  # The physical representation of a {Nanoc3::Site} is usually a directory
  # that contains a configuration file, site data, a rakefile, a rules file,
  # etc. The way site data is stored depends on the data source.
  class Site

    # The default configuration for a data source. A data source's
    # configuration overrides these options.
    DEFAULT_DATA_SOURCE_CONFIG = {
      :type         => 'filesystem_unified',
      :items_root   => '/',
      :layouts_root => '/',
      :config       => {}
    }

    # The default configuration for a site. A site's configuration overrides
    # these options: when a {Nanoc3::Site} is created with a configuration
    # that lacks some options, the default value will be taken from
    # `DEFAULT_CONFIG`.
    DEFAULT_CONFIG = {
      :text_extensions    => %w( css erb haml htm html js less markdown md php rb sass scss txt xhtml xml ),
      :output_dir         => 'output',
      :data_sources       => [ {} ],
      :index_filenames    => [ 'index.html' ],
      :enable_output_diff => false
    }

    # Creates a site object for the site specified by the given
    # `dir_or_config_hash` argument.
    #
    # @param [Hash, String] dir_or_config_hash If a string, contains the path
    #   to the site directory; if a hash, contains the site configuration.
    def initialize(dir_or_config_hash)
      build_config(dir_or_config_hash)
    end

    # Compiles the site.
    #
    # @return [void]
    def compile
      compiler.run
    end

    # Returns the compiler for this site. Will create a new compiler if none
    # exists yet.
    #
    # @return [Nanoc3::Compiler] The compiler for this site
    def compiler
      @compiler ||= Compiler.new(self)
    end

    # Returns the data sources for this site. Will create a new data source if
    # none exists yet.
    #
    # @return [Array<Nanoc3::DataSource>] The list of data sources for this
    #   site
    #
    # @raise [Nanoc3::Errors::UnknownDataSource] if the site configuration
    #   specifies an unknown data source
    def data_sources
      load_code_snippets

      @data_sources ||= begin
        @config[:data_sources].map do |data_source_hash|
          # Get data source class
          data_source_class = Nanoc3::DataSource.named(data_source_hash[:type])
          raise Nanoc3::Errors::UnknownDataSource.new(data_source_hash[:type]) if data_source_class.nil?

          # Warn about deprecated data sources
          # TODO [in nanoc 4.0] remove me
          case data_source_hash[:type]
            when 'filesystem'
              warn "Warning: the 'filesystem' data source has been renamed to 'filesystem_verbose'. Using 'filesystem' will work in nanoc 3.1.x, but it will likely not work anymore in a future release of nanoc. Please update your data source configuration and replace 'filesystem' with 'filesystem_verbose'."
            when 'filesystem_combined', 'filesystem_compact'
              warn "Warning: the 'filesystem_combined' and 'filesystem_compact' data source has been merged into the new 'filesystem_unified' data source. Using 'filesystem_combined' and 'filesystem_compact' will work in nanoc 3.1.x, but it will likely not work anymore in a future release of nanoc. Please update your data source configuration and replace 'filesystem_combined' and 'filesystem_compact with 'filesystem_unified'."
          end

          # Create data source
          data_source_class.new(
            self,
            data_source_hash[:items_root],
            data_source_hash[:layouts_root],
            data_source_hash[:config] || {}
          )
        end
      end
    end

    # Returns this site’s code snippets.
    #
    # @return [Array<Nanoc3::CodeSnippet>] The list of code snippets in this
    #   site
    def code_snippets
      load
      @code_snippets
    end

    # Returns this site’s items.
    #
    # @return [Array<Nanoc3::Item>] The list of items in this site
    def items
      load
      @items
    end

    # Returns this site’s layouts.
    #
    # @return [Array<Nanoc3::Layouts>] The list of layout in this site
    def layouts
      load
      @layouts
    end

    # Returns the site configuration. It has the following keys:
    #
    # * `text_extensions` (`Array<String>`) - A list of file extensions that
    #   will cause nanoc to threat the file as textual instead of binary. When
    #   the data source finds a content file with an extension that is
    #   included in this list, it will be marked as textual.
    #
    # * `output_dir` (`String`) - The directory to which compiled items will
    #   be written. This path is relative to the current working directory,
    #   but can also be an absolute path.
    #
    # * `data_sources` (`Array<Hash>`) - A list of data sources for this site.
    #   See below for documentation on the structure of this list. By default,
    #   there is only one data source of the filesystem  type mounted at `/`.
    #
    # * `index_filenames` (`Array<String>`) - A list of filenames that will be
    #   stripped off full item paths to create cleaner URLs. For example,
    #   `/about/` will be used instead of `/about/index.html`). The default
    #   value should be okay in most cases.
    #
    # * `enable_output_diff` (`Boolean`) - True when diffs should be generated
    #   for the compiled content of this site; false otherwise.
    #
    # The list of data sources consists of hashes with the following keys:
    #
    # * `:type` (`String`) - The type of data source, i.e. its identifier.
    #
    # * `:items_root` (`String`) - The prefix that should be given to all
    #   items returned by the {#items} method (comparable to mount points
    #   for filesystems in Unix-ish OSes).
    #
    # * `:layouts_root` (`String`) - The prefix that should be given to all
    #   layouts returned by the {#layouts} method (comparable to mount
    #   points for filesystems in Unix-ish OSes).
    #
    # * `:config` (`Hash`) - A hash containing the configuration for this data
    #   source. nanoc itself does not use this hash. This is especially
    #   useful for online data sources; for example, a Twitter data source
    #   would need the username of the account from which to fetch tweets.
    #
    # @return [Hash] The site configuration
    def config
      # Add reference to config if necessary
      if !@config.respond_to?(:reference)
        def @config.reference
          :config
        end
      end

      # Add data to config if necessary
      if !@config.respond_to?(:data)
        def @config.data
          self.inspect
        end
      end

      @config
    end

    # Fills each item's parent reference and children array with the
    # appropriate items. It is probably not necessary to call this method
    # manually; it will be called when appropriate.
    #
    # @return [void]
    def setup_child_parent_links
      # Clear all links
      @items.each do |item|
        item.parent = nil
        item.children = []
      end

      @items.each do |item|
        # Get parent
        parent_identifier = item.identifier.sub(/[^\/]+\/$/, '')
        parent = @items.find { |p| p.identifier == parent_identifier }
        next if parent.nil? or item.identifier == '/'

        # Link
        item.parent = parent
        parent.children << item
      end
    end

    # Prevents all further modifications to itself, its items, its layouts etc.
    #
    # @return [void]
    def freeze
      super

      config.freeze_recursively
      items.each         { |i|  i.freeze  }
      layouts.each       { |l|  l.freeze  }
      code_snippets.each { |cs| cs.freeze }
    end

    # @deprecated It is no longer necessary to explicitly load site data. It
    #   is safe to remove all {#load_data} calls.
    def load_data(force=false)
      warn 'It is no longer necessary to call Nanoc3::Site#load_data. This method no longer has any effect. All calls to this method can be safely removed.'
    end

    # Loads the site data. It is not necessary to call this method explicitly;
    # it will be called when it is necessary.
    #
    # @api private
    #
    # @return [void]
    def load
      return if @data_loaded
      @data_loaded = true

      # Load all data
      load_code_snippets
      data_sources.each { |ds| ds.use }
      load_items
      load_layouts
      data_sources.each { |ds| ds.unuse }
      setup_child_parent_links

      # Load compiler too
      # FIXME this should not be necessary
      compiler.load
    end

  private

    # Loads this site’s code and executes it.
    def load_code_snippets
      @code_snippets_loaded ||= false
      return if @code_snippets_loaded
      @code_snippets_loaded = true

      # Get code snippets
      @code_snippets = Dir['lib/**/*.rb'].sort.map do |filename|
        Nanoc3::CodeSnippet.new(
          File.read(filename),
          filename
        )
      end

      # Execute code snippets
      @code_snippets.each { |cs| cs.load }
    end

    # Loads this site’s items, sets up item child-parent relationships and
    # builds each item's list of item representations.
    def load_items
      @items_loaded ||= false
      return if @items_loaded
      @items_loaded = true

      # Get items
      @items = []
      data_sources.each do |ds|
        items_in_ds = ds.items
        items_in_ds.each { |i| i.identifier = File.join(ds.items_root, i.identifier) }
        @items.concat(items_in_ds)
      end
    end

    # Loads this site’s layouts.
    def load_layouts
      @layouts_loaded ||= false
      return if @layouts_loaded
      @layouts_loaded = true

      # Get layouts
      @layouts = []
      data_sources.each do |ds|
        layouts_in_ds = ds.layouts
        layouts_in_ds.each { |i| i.identifier = File.join(ds.layouts_root, i.identifier) }
        @layouts.concat(layouts_in_ds)
      end
    end

    # Builds the configuration hash based on the given argument. Also see
    # {#initialize} for details.
    def build_config(dir_or_config_hash)
      if dir_or_config_hash.is_a? String
        # Check whether it is supported
        if dir_or_config_hash != '.'
          warn 'WARNING: Calling Nanoc3::Site.new with a directory that is not the current working directory is not supported. It is recommended to change the directory before calling Nanoc3::Site.new. For example, instead of Nanoc3::Site.new(\'abc\'), use Dir.chdir(\'abc\') { Nanoc3::Site.new(\'.\') }.'
        end

        # Read config from config.yaml in given dir
        config_path = File.join(dir_or_config_hash, 'config.yaml')
        @config = DEFAULT_CONFIG.merge(YAML.load_file(config_path).symbolize_keys)
        @config[:data_sources].map! { |ds| ds.symbolize_keys }
      else
        # Use passed config hash
        @config = DEFAULT_CONFIG.merge(dir_or_config_hash)
      end

      # Merge data sources with default data source config
      @config[:data_sources] = @config[:data_sources].map { |ds| DEFAULT_DATA_SOURCE_CONFIG.merge(ds) }
    end

  end

end
