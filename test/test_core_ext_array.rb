require 'test/unit'

require File.dirname(__FILE__) + '/test_helper.rb'

class CoreExtArrayTest < Test::Unit::TestCase

  def setup
    $quiet = true unless ENV['QUIET'] == 'false'
  end

  def teardown
    $quiet = false
  end

  def test_array_ensure_single
    assert_raise(SystemExit) do
      [ ].ensure_single('moofs', 'blargh')
    end
    assert_raise(SystemExit) do
      [ 1, 2 ].ensure_single('moofs', 'blargh')
    end
    assert_nothing_raised() do
      [ 1 ].ensure_single('moofs', 'blargh')
    end
  end

  def test_array_pushing
    arr = []
    arr.pushing('foo') do
      assert_equal([ 'foo' ], arr)
      arr.pushing('bar') do
        assert_equal([ 'foo', 'bar' ], arr)
      end
      assert_equal([ 'foo' ], arr)
    end
    assert_equal([], arr)
  end

end