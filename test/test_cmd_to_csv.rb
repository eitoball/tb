require 'test/unit'
require 'tb/cmdtop'
require 'tmpdir'

class TestTbCmdToCSV < Test::Unit::TestCase
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

  def with_stdin(io)
    save = $stdin
    $stdin = io
    begin
      yield
    ensure
      $stdin = save
    end
  end

  def with_stdout(io)
    save = $stdout
    $stdout = io
    begin
      yield
    ensure
      $stdout = save
    end
  end

  def test_basic
    File.open(i="i.tsv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a\tb\tc
      0\t1\t2
      4\t5\t6
    End
    Tb::Cmd.main_to_csv(['-o', o="o.csv", i])
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), File.read(o))
      a,b,c
      0,1,2
      4,5,6
    End
  end

  def test_complement_header
    File.open(i="i.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a,b
      0,1,2
      4,5,6
    End
    Tb::Cmd.main_to_csv(['-o', o="o.csv", i])
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), File.read(o))
      a,b,1
      0,1,2
      4,5,6
    End
  end

  def test_numeric
    File.open(i="i.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a
      0,1,2
      4,5,6
    End
    Tb::Cmd.main_to_csv(['-o', o="o.csv", '-N', i])
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), File.read(o))
      a,,
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
    o = nil
    File.open(i) {|input|
      with_stdin(input) {
        Tb::Cmd.main_to_csv(['-o', o="o.csv"])
      }
    }
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), File.read(o))
      a,b,c
      0,1,2
      4,5,6
    End
  end

  def test_pipeout
    File.open(i="i.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a,b,c
      0,1,2
      4,5,6
    End
    r, w = IO.pipe
    th = Thread.new { r.read }
    with_stdout(w) {
      Tb::Cmd.main_to_csv([i])
      w.close
    }
    result = th.value
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), result)
      a,b,c
      0,1,2
      4,5,6
    End
  ensure
    r.close if r && !r.closed?
    w.close if w && !w.closed?
  end

  def test_twofile
    File.open(i1="i1.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a,b
      1,2
      3,4
    End
    File.open(i2="i2.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      b,a
      5,6
      7,8
    End
    Tb::Cmd.main_to_csv(['-o', o="o.csv", i1, i2])
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), File.read(o))
      a,b
      1,2
      3,4
      6,5
      8,7
    End
  end

  def test_output_extension
    File.open(i="i.tsv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a\tb\tc
      0\t1\t2
      4\t5\t6
    End
    Tb::Cmd.main_to_csv(['-o', o="o.json", i])
    assert_equal(<<-"End".gsub(/^[ \t]+/, ''), File.read(o))
      a,b,c
      0,1,2
      4,5,6
    End
  end

end
