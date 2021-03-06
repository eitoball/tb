require 'tb'
require 'test/unit'

class TestTbLTSV < Test::Unit::TestCase
  def test_parse
    r = Tb::LTSVReader.new("a:1\tb:2\na:3\tb:4\n")
    result = []
    r.with_header {|header|
      result << header
    }.each {|obj|
      result << obj
    }
    assert_equal([nil, {"a"=>"1", "b"=>"2"}, {"a"=>"3", "b"=>"4"}], result)
  end

  def test_parse2
    ltsv = "a:1\tb:2\n"
    t = Tb.parse_ltsv(ltsv)
    records = []
    t.each_record {|record|
      records << record.to_h_with_reserved
    }
    assert_equal(
      [{"_recordid"=>0, "a"=>"1", "b"=>"2"}],
      records)
  end

  def test_generate_ltsv
    tbl = Tb.new %w[a b], %w[foo bar]
    tbl.generate_ltsv(out="")
    assert_equal("a:foo\tb:bar\n", out)
  end

  def test_generate_ltsv_with_block
    tbl = Tb.new %w[a b], %w[foo bar], %w[q w]
    tbl.generate_ltsv(out="") {|recids| recids.reverse }
    assert_equal("a:q\tb:w\na:foo\tb:bar\n", out)
  end

end
