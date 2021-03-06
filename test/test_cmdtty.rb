require 'test/unit'
require 'tb/cmdtop'
require 'tmpdir'
begin
  require 'pty'
  require 'io/console'
rescue LoadError
end

class TestTbCmdTTY < Test::Unit::TestCase
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

  def with_env(k, v)
    save = ENV[k]
    begin
      ENV[k] = v
      yield
    ensure
      ENV[k] = save
    end
  end

  def with_real_stdout(io)
    save = $stdout.dup
    $stdout.reopen(io)
    begin
      yield
    ensure
      $stdout.reopen(save)
      save.close
    end
  end

  def reader_thread(io)
    th = Thread.new {
      r = ''
      loop {
        begin
          r << io.readpartial(4096)
        rescue EOFError, Errno::EIO
          break
        end
      }
      r
    }
    sleep 0.1 if /freebsd/ =~ RUBY_PLATFORM # FreeBSD 8.2-RELEASE-p3 (amd64) hang ???
    th
  end

  def test_ttyout_multiscreen
    return unless IO.instance_methods.include?(:raw!)
    File.open(i="i.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a,b,c
      0,1,2
      4,5,6
    End
    with_env('PAGER', 'sed "s/^/foo:/"') {
      PTY.open {|m, s|
        s.raw!
        s.winsize = [2, 80]
        th = reader_thread(m)
        with_real_stdout(s) {
          Tb::Cmd.main_to_csv([i])
        }
        s.close
        result = th.value
        assert_equal(<<-"End".gsub(/^[ \t]+/, ''), result)
          foo:a,b,c
          foo:0,1,2
          foo:4,5,6
        End
      }
    }
  end

  def test_ttyout_singlescreen
    return unless IO.instance_methods.include?(:raw!)
    File.open(i="i.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a,b,c
      0,1,2
      4,5,6
    End
    with_env('PAGER', 'sed "s/^/foo:/"') {
      PTY.open {|m, s|
        s.raw!
        s.winsize = [24, 80]
        th = reader_thread(m)
        with_real_stdout(s) {
          Tb::Cmd.main_to_csv([i])
        }
        s.close
        result = th.value
        assert_equal(<<-"End".gsub(/^[ \t]+/, ''), result)
          a,b,c
          0,1,2
          4,5,6
        End
      }
    }
  end

  def test_ttyout_tab
    return unless IO.instance_methods.include?(:raw!)
    File.open(i="i.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a,b,c
      0,\t,2
    End
    with_env('PAGER', 'sed "s/^/foo:/"') {
      PTY.open {|m, s|
        s.raw!
        s.winsize = [3, 10]
        th = reader_thread(m)
        with_real_stdout(s) {
          Tb::Cmd.main_to_csv([i])
        }
        s.close
        result = th.value
        assert_equal(<<-"End".gsub(/^[ \t]+/, ''), result)
          foo:a,b,c
          foo:0,\t,2
        End
      }
    }
  end

  def test_ttyout_nottysize
    return unless IO.instance_methods.include?(:raw!)
    File.open(i="i.csv", "w") {|f| f << <<-"End".gsub(/^[ \t]+/, '') }
      a,b,c
      0,1,2
    End
    with_env('PAGER', 'sed "s/^/foo:/"') {
      PTY.open {|m, s|
        s.raw!
        s.winsize = [0, 0]
        th = reader_thread(m)
        with_real_stdout(s) {
          Tb::Cmd.main_to_csv([i])
        }
        s.close
        result = th.value
        assert_equal(<<-"End".gsub(/^[ \t]+/, ''), result)
          a,b,c
          0,1,2
        End
      }
    }
  end

end if defined?(PTY) && defined?(PTY.open)
