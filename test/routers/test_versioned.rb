require 'test/helper'

class Nanoc::Routers::VersionedTest < MiniTest::Unit::TestCase

  def setup    ; global_setup    ; end
  def teardown ; global_teardown ; end

  def test_path_for_page_rep_with_default_rep
    # Create versioned router
    router = Nanoc::Routers::Versioned.new(nil)

    # Create site
    site = mock

    # Get page
    page = Nanoc::Page.new(
      'some content',
      {
        :filename   => 'home',
        :extension  => 'htm',
        :version    => 123
      },
      '/foo/'
    )
    page_rep = Nanoc::PageRep.new(page, :default)

    # Check
    assert_equal('/foo/home.htm', router.path_for_page_rep(page_rep))
  end

  def test_path_for_page_rep_with_custom_rep
    # Create versioned router
    router = Nanoc::Routers::Versioned.new(nil)

    # Create site
    site = mock

    # Get page
    page = Nanoc::Page.new(
      'some content',
      {
        :filename   => 'home',
        :extension  => 'htm',
        :version    => 123
      },
      '/foo/'
    )
    page_rep = Nanoc::PageRep.new(page, :raw)

    # Check
    assert_equal('/foo/home-raw.htm', router.path_for_page_rep(page_rep))
  end

  def test_path_for_asset_rep_with_default_rep
    # Create site
    site = mock
    site.expects(:config).returns({ :assets_prefix => '/imuhgez' })

    # Create versioned router
    router = Nanoc::Routers::Versioned.new(site)

    # Get asset
    asset = Nanoc::Asset.new(
      nil,
      {
        :extension => 'png',
        :version   => 123
      },
      '/foo/'
    )
    asset_rep = Nanoc::AssetRep.new(asset, :default)

    # Check
    assert_equal(
      '/imuhgez/foo-v123.png',
      router.path_for_asset_rep(asset_rep)
    )
  end

  def test_path_for_asset_rep_with_custom_rep
    # Create site
    site = mock
    site.expects(:config).returns({ :assets_prefix => '/imuhgez' })

    # Create versioned router
    router = Nanoc::Routers::Versioned.new(site)

    # Get asset
    asset = Nanoc::Asset.new(
      nil,
      {
        :extension => 'png', 
        :version => 123
      },
      '/foo/'
    )
    asset_rep = Nanoc::AssetRep.new(asset, :raw)

    # Check
    assert_equal(
      '/imuhgez/foo-v123-raw.png',
      router.path_for_asset_rep(asset_rep)
    )
  end

  def test_path_for_asset_rep_with_default_rep_without_version
    # Create site
    site = mock
    site.expects(:config).returns({ :assets_prefix => '/imuhgez' })

    # Create versioned router
    router = Nanoc::Routers::Versioned.new(site)

    # Get asset
    asset = Nanoc::Asset.new(
      nil,
      { :extension => 'png' },
      '/foo/'
    )
    asset_rep = Nanoc::AssetRep.new(asset, :default)

    # Check
    assert_equal(
      '/imuhgez/foo.png',
      router.path_for_asset_rep(asset_rep)
    )
  end

  def test_path_for_asset_rep_with_custom_rep_without_version
    # Create site
    site = mock
    site.expects(:config).returns({ :assets_prefix => '/imuhgez' })

    # Create versioned router
    router = Nanoc::Routers::Versioned.new(site)

    # Get asset
    asset = Nanoc::Asset.new(
      nil,
      {
        :extension => 'png'
      },
      '/foo/'
    )
    asset_rep = Nanoc::AssetRep.new(asset, :raw)

    # Check
    assert_equal(
      '/imuhgez/foo-raw.png',
      router.path_for_asset_rep(asset_rep)
    )
  end

end
