require 'test/unit'
require 'tb/cmdtop'
require 'tmpdir'

class TestTbCmdCSV < Test::Unit::TestCase
  def setup
    Tb::Cmd.reset_option
    @curdir = Dir.pwd
    @tmpdir = Dir.mktmpdir
    Dir.chdir @tmpdir
  end
  def teardown
    Tb::Cmd.reset_option
    Dir.chdir @curdir
    FileUtils.rmtree @tmpdir
  end

  def test_basic
    File.open(i="i.tsv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a\tb\tc
      0\t1\t2
      4\t5\t6
    End
    assert_equal(true, Tb::Cmd.main_csv(['-o', o="o.csv", i]))
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), File.read(o))
      a,b,c
      0,1,2
      4,5,6
    End
  end

  def test_noarg
    File.open(i="i.tsv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a,b,c
      0,1,2
      4,5,6
    End
    save = STDIN.dup
    input = File.open(i)
    STDIN.reopen(input)
    assert_equal(true, Tb::Cmd.main_csv(['-o', o="o.csv"]))
    STDIN.reopen(save)
    save.close
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), File.read(o))
      a,b,c
      0,1,2
      4,5,6
    End
  ensure
    save.close if save && !save.closed?
    input.close if input && !input.closed?
  end

end