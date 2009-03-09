require 'test/helper'

class Nanoc::CompilerTest < MiniTest::Unit::TestCase

  def setup    ; global_setup    ; end
  def teardown ; global_teardown ; end

  def test_run_without_item
    # Create items
    pages = [
      Nanoc::Page.new('page one', {}, '/page1/'),
      Nanoc::Page.new('page two', {}, '/page2/')
    ]
    assets = [
      Nanoc::Asset.new(nil, {}, '/asset1/'),
      Nanoc::Asset.new(nil, {}, '/asset2/')
    ]

    # Mock reps
    pages[0].expects(:reps).returns([ mock ])
    pages[1].expects(:reps).returns([ mock, mock ])
    assets[0].expects(:reps).returns([ mock ])
    assets[1].expects(:reps).returns([ mock, mock ])

    # Create site
    site = mock
    site.expects(:config).returns({ :output_dir => 'foo/bar/baz' })
    site.expects(:pages).returns(pages)
    site.expects(:assets).returns(assets)

    # Set items' site
    (pages + assets).each { |item| item.site = site }

    # Create compiler
    compiler = Nanoc::Compiler.new(site)
    compiler.expects(:load_rules)
    compiler.expects(:build_reps_for).times(4)
    compiler.expects(:map_rep).times(6)
    compiler.expects(:compile_rep).times(6)

    # Run
    FileUtils.cd('tmp') { compiler.run }

    # Make sure output dir is created
    assert(File.directory?('tmp/foo/bar/baz'))

    # Check items
    assert_equal(4, compiler.instance_eval { @items }.size)
    assert_equal(6, compiler.instance_eval { @reps  }.size)
  end

  def test_run_with_page_rep
    # Create page
    page = Nanoc::Page.new('page one', {}, '/page1/')

    # Mock reps
    page.expects(:reps).returns([ mock, mock, mock ])

    # Create site and router
    site = mock
    site.expects(:config).returns({ :output_dir => 'foo/bar/baz' })

    # Set item's site
    page.site = site

    # Create compiler
    compiler = Nanoc::Compiler.new(site)
    compiler.expects(:load_rules)
    compiler.expects(:build_reps_for).times(1)
    compiler.expects(:map_rep).times(3)
    compiler.expects(:compile_rep).times(3)

    # Run
    FileUtils.cd('tmp') { compiler.run([ page ]) }

    # Make sure output dir is created
    assert(File.directory?('tmp/foo/bar/baz'))

    # Check items
    assert_equal(1, compiler.instance_eval { @items }.size)
    assert_equal(3, compiler.instance_eval { @reps  }.size)
  end

  def test_run_with_asset_rep
    # Create asset
    asset = Nanoc::Asset.new('asset one', {}, '/asset1/')

    # Mock reps
    asset.expects(:reps).returns([ mock, mock, mock ])

    # Create site
    site = mock
    site.expects(:config).returns({ :output_dir => 'foo/bar/baz' })

    # Set item's site
    asset.site = site

    # Create compiler
    compiler = Nanoc::Compiler.new(site)
    compiler.expects(:load_rules)
    compiler.expects(:build_reps_for).times(1)
    compiler.expects(:map_rep).times(3)
    compiler.expects(:compile_rep).times(3)

    # Run
    FileUtils.cd('tmp') { compiler.run([ asset ]) }

    # Make sure output dir is created
    assert(File.directory?('tmp/foo/bar/baz'))

    # Check items
    assert_equal(1, compiler.instance_eval { @items }.size)
    assert_equal(3, compiler.instance_eval { @reps  }.size)
  end

  def test_load_rules_with_existing_rules_file
    # Mock site
    site = mock

    # Create compiler
    compiler = Nanoc::Compiler.new(site)

    FileUtils.cd('tmp') do
      # Create rules file
      File.open('Rules', 'w') do |io|
        io.write <<-EOF
page '*' do |p|
  p.write
end
EOF
      end

      # Load rules
      compiler.load_rules

      # Check rule counts
      assert_equal(1, compiler.instance_eval { @page_compilation_rules  }.size)
      assert_equal(0, compiler.instance_eval { @asset_compilation_rules }.size)

      # Check rule
      rule = compiler.instance_eval { @page_compilation_rules }[0]
      assert_equal(:default,  rule.rep_name)
      assert_equal(/^(.*?)$/, rule.identifier_regex)
    end
  end

  def test_load_rules_with_broken_rules_file
    # Mock site
    site = mock

    # Create compiler
    compiler = Nanoc::Compiler.new(site)

    FileUtils.cd('tmp') do
      # Create rules file
      File.open('Rules', 'w') do |io|
        io.write <<-EOF
some_function_that_doesn_really_exist(
  weird_param_number_one,
  mysterious_param_number_two
)
EOF
      end

      # Try loading rules
      error = assert_raises(NameError) do
        compiler.load_rules
      end

      # Check error
      assert_match 'Rules', error.backtrace.join(', ')
    end
  end

  def test_load_rules_with_missing_rules_file
    # Mock site
    site = mock

    # Create compiler
    compiler = Nanoc::Compiler.new(site)

    FileUtils.cd('tmp') do
      # Try loading rules
      assert_raises(Nanoc::Errors::NoRulesFileFoundError) do
        compiler.load_rules
      end
    end
  end

  def test_build_reps_for
    # TODO implement
  end

  def test_map_rep
    # TODO implement
  end

  def test_compile_rep
    # TODO implement
  end

  def test_compilation_rule_for
    # TODO implement
  end

  def test_filter_name_for_layout_with_existant_layout
    # Mock site
    site = mock

    # Create compiler
    compiler = Nanoc::Compiler.new(site)
    compiler.add_layout_compilation_rule('*', :erb)

    # Mock layout
    layout = MiniTest::Mock.new
    layout.expect(:identifier, 'some_layout')

    # Check
    assert_equal(:erb, compiler.filter_name_for_layout(layout))
  end

  def test_filter_name_for_layout_with_existant_layout_and_unknown_filter
    # Mock site
    site = mock

    # Create compiler
    compiler = Nanoc::Compiler.new(site)
    compiler.add_layout_compilation_rule('*', :some_unknown_filter)

    # Mock layout
    layout = MiniTest::Mock.new
    layout.expect(:identifier, 'some_layout')

    # Check
    assert_equal(:some_unknown_filter, compiler.filter_name_for_layout(layout))
  end

  def test_filter_name_for_layout_with_nonexistant_layout
    # Mock site
    site = mock

    # Create compiler
    compiler = Nanoc::Compiler.new(site)
    compiler.add_layout_compilation_rule('foo', :erb)

    # Mock layout
    layout = MiniTest::Mock.new
    layout.expect(:identifier, 'bar')

    # Check
    assert_equal(nil, compiler.filter_name_for_layout(layout))
  end

  def test_add_page_compilation_rule
    # TODO implement
  end

  def test_add_asset_compilation_rule
    # TODO implement
  end

  def test_add_layout_compilation_rule
    # TODO implement
  end

  def test_identifier_to_regex_without_wildcards
    # Create compiler
    compiler = Nanoc::Compiler.new(nil)

    # Check
    assert_equal(
      /^foo$/,
      compiler.instance_eval { identifier_to_regex('foo') }
    )
  end

  def test_identifier_to_regex_with_one_wildcard
    # Create compiler
    compiler = Nanoc::Compiler.new(nil)

    # Check
    assert_equal(
      /^foo\/(.*?)\/bar$/.to_s,
      compiler.instance_eval { identifier_to_regex('foo/*/bar') }.to_s
    )
  end

  def test_identifier_to_regex_with_two_wildcards
    # Create compiler
    compiler = Nanoc::Compiler.new(nil)

    # Check
    assert_equal(
      /^foo\/(.*?)\/bar\/(.*?)\/qux$/.to_s,
      compiler.instance_eval { identifier_to_regex('foo/*/bar/*/qux') }.to_s
    )
  end

end
