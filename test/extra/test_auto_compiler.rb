require 'test/helper'

class Nanoc3::Extra::AutoCompilerTest < MiniTest::Unit::TestCase

  include Nanoc3::TestHelpers

  def test_handle_request_with_item_rep
    # Create items and reps
    item_reps = [ mock, mock, mock ]
    item_reps[0].stubs(:path).returns('/foo/1/')
    item_reps[1].stubs(:path).returns('/foo/2/')
    item_reps[2].stubs(:path).returns('/bar/')
    items = [ mock, mock ]
    items[0].stubs(:reps).returns([ item_reps[0], item_reps[1] ])
    items[1].stubs(:reps).returns([ item_reps[2] ])

    # Create site
    site = mock
    site.stubs(:load_data).with(true)
    site.stubs(:items).returns(items)
    site.stubs(:config).returns({ :output_dir => 'output/', :index_filenames => [ 'index.html' ] })

    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(site)
    autocompiler.expects(:serve_rep).with(item_reps[1])
    autocompiler.stubs(:build_reps)

    # Run
    autocompiler.instance_eval { call('PATH_INFO' => '/foo/2/') }
  end

  def test_handle_request_with_broken_url
    # Create items and reps
    item_reps = [ mock, mock, mock ]
    item_reps[0].expects(:path).at_most_once.returns('/foo/1/')
    item_reps[1].expects(:path).returns('/foo/2/')
    item_reps[2].expects(:path).at_most_once.returns('/bar/')
    items = [ mock, mock ]
    items[0].expects(:reps).returns([ item_reps[0], item_reps[1] ])
    items[1].expects(:reps).returns([ item_reps[2] ])

    # Create site
    site = mock
    site.expects(:load_data).with(true)
    site.expects(:items).returns(items)
    site.expects(:config).returns({ :output_dir => 'output/', :index_filenames => [ 'index.html' ] })

    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(site)
    autocompiler.expects(:serve_404).with('/foo/2')
    autocompiler.stubs(:build_reps)

    # Run
    autocompiler.instance_eval { call('PATH_INFO' => '/foo/2') }
  end

  def test_handle_request_with_file
    # Create items and reps
    item_reps = [ mock, mock, mock ]
    item_reps[0].expects(:path).returns('/foo/1/')
    item_reps[1].expects(:path).returns('/foo/2/')
    item_reps[2].expects(:path).returns('/bar/')
    items = [ mock, mock ]
    items[0].expects(:reps).returns([ item_reps[0], item_reps[1] ])
    items[1].expects(:reps).returns([ item_reps[2] ])

    # Create site
    site = mock
    site.expects(:load_data).with(true)
    site.expects(:items).returns(items)
    site.expects(:config).at_least_once.returns({ :output_dir => 'out/', :index_filenames => [ 'index.html' ] })

    # Create file
    FileUtils.mkdir_p('out')
    File.open('out/somefile.txt', 'w') { |io| }

    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(site)
    autocompiler.expects(:serve_file).with('out/somefile.txt')
    autocompiler.stubs(:build_reps)

    # Run
    autocompiler.instance_eval { call('PATH_INFO' => 'somefile.txt') }
  end

  def test_handle_request_with_dir_with_slash_with_index_file
    # Create site
    site = mock
    site.expects(:load_data).with(true)
    site.expects(:items).returns([])
    site.expects(:config).at_least_once.returns({ :output_dir => 'out/', :index_filenames => [ 'index.html' ] })

    # Create file
    FileUtils.mkdir_p('out/foo/bar')
    File.open('out/foo/bar/index.html', 'w') { |io| }

    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(site)
    autocompiler.expects(:serve_file).with('out/foo/bar/index.html')
    autocompiler.stubs(:build_reps)

    # Run
    autocompiler.instance_eval { call('PATH_INFO' => 'foo/bar/') }
  end

  def test_handle_request_with_dir_with_slash_without_index_file
    # Create site
    site = mock
    site.expects(:load_data).with(true)
    site.expects(:items).returns([])
    site.expects(:config).at_least_once.returns({ :output_dir => 'out/', :index_filenames => [ 'index.html' ] })

    # Create file
    FileUtils.mkdir_p('out/foo/bar')
    File.open('out/foo/bar/someotherfile.txt', 'w') { |io| }

    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(site)
    autocompiler.expects(:serve_404).with('foo/bar/')
    autocompiler.stubs(:build_reps)

    # Run
    autocompiler.instance_eval { call('PATH_INFO' => 'foo/bar/') }
  end

  def test_handle_request_with_dir_without_slash_with_index_file
    # Create site
    site = mock
    site.expects(:load_data).with(true)
    site.expects(:items).returns([])
    site.expects(:config).at_least_once.returns({ :output_dir => 'out/', :index_filenames => [ 'index.html' ] })

    # Create file
    FileUtils.mkdir_p('out/foo/bar')
    File.open('out/foo/bar/index.html', 'w') { |io| }

    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(site)
    autocompiler.expects(:serve_404).with('foo/bar')
    autocompiler.stubs(:build_reps)

    # Run
    autocompiler.instance_eval { call('PATH_INFO' => 'foo/bar') }
  end

  def test_handle_request_with_dir_without_slash_without_index_file
    # Create site
    site = mock
    site.expects(:load_data).with(true)
    site.expects(:items).returns([])
    site.expects(:config).at_least_once.returns({ :output_dir => 'out/', :index_filenames => [ 'index.html' ] })

    # Create file
    FileUtils.mkdir_p('out/foo/bar')
    File.open('out/foo/bar/someotherfile.txt', 'w') { |io| }

    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(site)
    autocompiler.expects(:serve_404).with('foo/bar')
    autocompiler.stubs(:build_reps)

    # Run
    autocompiler.instance_eval { call('PATH_INFO' => 'foo/bar') }
  end

  def test_handle_request_with_404
    # Create site
    site = mock
    site.expects(:load_data).with(true)
    site.expects(:items).returns([])
    site.expects(:config).at_least_once.returns({ :output_dir => 'out/', :index_filenames => [ 'index.html' ] })

    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(site)
    autocompiler.expects(:serve_404).with('someotherfile.txt')
    autocompiler.stubs(:build_reps)

    # Run
    autocompiler.instance_eval { call('PATH_INFO' => 'someotherfile.txt') }
  end

  def test_h
    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(nil)

    # Check HTML escaping
    assert_equal(
      '&lt; &amp; &gt; \' &quot;',
      autocompiler.instance_eval { h('< & > \' "') }
    )
  end

  def test_mime_type_of
    if_have('mime/types') do
      # Create autocompiler
      autocompiler = Nanoc3::Extra::AutoCompiler.new(nil)

      # Create known test file
      File.open('foo.html', 'w') { |io| }
      assert_equal(
        'text/html',
        autocompiler.instance_eval { mime_type_of('foo.html', 'huh') }
      )

      # Create unknown test file
      File.open('foo', 'w') { |io| }
      assert_equal(
        'huh',
        autocompiler.instance_eval { mime_type_of('foo', 'huh') }
      )
    end
  end

  def test_serve_400
    # Create autocompiler
    autocompiler = Nanoc3::Extra::AutoCompiler.new(nil)

    # Fill response for 404
    response = autocompiler.instance_eval { serve_404('/foo/bar/baz/') }

    # Check response
    assert_equal(404,                   response[0])
    assert_equal('text/html',           response[1]['Content-Type'])
    assert_match(/404 File Not Found/,  response[2][0])
  end

  def test_serve_rep_with_working_item
    if_have('mime/types') do
      # Create item and item rep
      item = mock
      item_rep = mock
      item_rep.expects(:raw_path).at_least_once.returns('somefile.html')
      item_rep.expects(:item).returns(item)
      item_rep.expects(:content_at_snapshot).with(:post).returns('compiled item content')

      # Create file
      File.open(item_rep.raw_path, 'w') { |io| }

      # Create compiler
      compiler = Object.new
      def compiler.run(items, params={})
        File.open('somefile.html', 'w') { |io| io.write("... compiled item content ...") }
      end

      # Create site
      site = mock
      site.expects(:compiler).returns(compiler)

      # Create autocompiler
      autocompiler = Nanoc3::Extra::AutoCompiler.new(site)

      begin
        # Serve
        response = autocompiler.instance_eval { serve_rep(item_rep) }

        # Check response
        assert_equal(200,                     response[0])
        assert_equal('text/html',             response[1]['Content-Type'])
        assert_match(/compiled item content/, response[2][0])
      ensure
        # Clean up
        FileUtils.rm_rf(item_rep.raw_path)
      end
    end
  end

  def test_serve_rep_with_broken_item
    if_have('mime/types') do
      # Create item and item rep
      item = mock
      item_rep = mock
      item_rep.expects(:item).returns(item)

      # Create site
      stack = []
      compiler = mock
      compiler.expects(:run).raises(RuntimeError, 'aah! fail!')
      site = mock
      site.expects(:compiler).at_least_once.returns(compiler)

      # Create autocompiler
      autocompiler = Nanoc3::Extra::AutoCompiler.new(site)

      # Serve
      assert_raises(RuntimeError) do
        autocompiler.instance_eval { serve_rep(item_rep) }
      end
    end
  end

  def test_serve_file
    if_have('mime/types') do
      # Create test files
      File.open('test.css', 'w') { |io| io.write("body { color: blue; }")  }
      File.open('test',     'w') { |io| io.write("random blah blah stuff") }

      # Create autocompiler
      autocompiler = Nanoc3::Extra::AutoCompiler.new(self)

      # Serve file 1
      response = autocompiler.instance_eval { serve_file('test.css') }

      # Check response for file 1
      assert_equal(200,         response[0])
      assert_equal('text/css',  response[1]['Content-Type'])
      assert(response[2][0].include?('body { color: blue; }'))

      # Serve file 2
      response = autocompiler.instance_eval { serve_file('test') }

      # Check response for file 2
      assert_equal(200,                         response[0])
      assert_equal('application/octet-stream',  response[1]['Content-Type'])
      assert(response[2][0].include?('random blah blah stuff'))
    end
  end

end
