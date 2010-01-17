# encoding: utf-8

module Nanoc3::Helpers

  # Nanoc3::Helpers::LinkTo contains functions for linking to items.
  #
  # To activate this helper, `include Nanoc3::Helpers::LinkTo`.
  module LinkTo

    require 'nanoc3/helpers/html_escape'
    include Nanoc3::Helpers::HTMLEscape

    # Creates a HTML link to the given path or item representation, and with
    # the given text. All attributes of the `a` element, including the `href`
    # attribute, will be HTML-escaped; the contents of the `a` element, which
    # can contain markup, will not be HTML-escaped.
    #
    # @param [String] text The visible link text
    #
    # @param [String, Nanoc3::Item, Nanoc3::ItemRep] target The path/URL,
    #   item or item representation that should be linked to
    #
    # @param [Hash] attributes A hash containing HTML attributes (e.g.
    #   `rel`, `title`, …) that will be added to the link.
    #
    # @return [String] The link text
    #
    # @example Linking to a path
    #   link_to('Blog', '/blog/')
    #   # => '<a href="/blog/">Blog</a>'
    #
    # @example Linking to an item
    #   about = @items.find { |i| i.identifier == '/about/' }
    #   link_to('About Me', about)
    #   # => '<a href="/about.html">About Me</a>'
    #
    # @example Linking to an item representation
    #   about = @items.find { |i| i.identifier == '/about/' }
    #   link_to('My vCard', about.rep(:vcard))
    #   # => '<a href="/about.vcf">My vCard</a>'
    #
    # @example Linking with custom attributes
    #   link_to('Blog', '/blog/', :title => 'My super cool blog')
    #   # => '<a href="/blog/" title="My super cool blog">Blog</a>
    def link_to(text, target, attributes={})
      # Find path
      path = target.is_a?(String) ? target : target.path

      # Join attributes
      attributes = attributes.inject('') do |memo, (key, value)|
        memo + key.to_s + '="' + h(value) + '" '
      end

      # Create link
      "<a #{attributes}href=\"#{h path}\">#{text}</a>"
    end

    # Creates a HTML link using link_to, except when the linked item is the
    # current one. In this case, a span element with class “active” and with
    # the given text will be returned. The HTML-escaping rules for
    # {#link_to} apply here as well.
    #
    # @param [String] text The visible link text
    #
    # @param [String, Nanoc3::Item, Nanoc3::ItemRep] target The path/URL,
    #   item or item representation that should be linked to
    #
    # @param [Hash] attributes A hash containing HTML attributes (e.g.
    #   `rel`, `title`, …) that will be added to the link.
    #
    # @return [String] The link text
    #
    # @example Linking to a different page
    #   link_to_unless_current('Blog', '/blog/')
    #   # => '<a href="/blog/">Blog</a>'
    #
    # @example Linking to the same page
    #   link_to_unless_current('This Item', @item)
    #   # => '<span class="active" title="You're here.">This Item</span>'
    def link_to_unless_current(text, target, attributes={})
      # Find path
      path = target.is_a?(String) ? target : target.path

      if @item_rep && @item_rep.path == path
        # Create message
        "<span class=\"active\" title=\"You're here.\">#{text}</span>"
      else
        link_to(text, target, attributes)
      end
    end

    # Returns the relative path from the current item to the given path or
    # item representation. The returned path will not be HTML-escaped.
    #
    # @param [String, Nanoc3::Item, Nanoc3::ItemRep] target The path/URL,
    #   item or item representation to which the relative path should be
    #   generated
    #
    # @return [String] The relative path to the target
    #
    # @example
    #   # if the current item's path is /foo/bar/
    #   relative_path('/foo/qux/')
    #   # => '../qux/'
    def relative_path_to(target)
      require 'pathname'

      # Find path
      path = target.is_a?(String) ? target : target.path

      # Get source and destination paths
      dst_path   = Pathname.new(path)
      src_path   = Pathname.new(@item_rep.path)

      # Calculate elative path (method depends on whether destination is a
      # directory or not).
      if src_path.to_s[-1,1] != '/'
        relative_path = dst_path.relative_path_from(src_path.dirname).to_s
      else
        relative_path = dst_path.relative_path_from(src_path).to_s
      end

      # Add trailing slash if necessary
      if dst_path.to_s[-1,1] == '/'
        relative_path += '/'
      end

      # Done
      relative_path
    end

  end

end
