# Copyright (C) 2011 Tanaka Akira  <akr@fsij.org>
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#  3. The name of the author may not be used to endorse or promote products
#     derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.

Tb::Cmd.subcommands << 'git-log'

Tb::Cmd.default_option[:opt_git_log_git_command] = nil
Tb::Cmd.default_option[:opt_git_log_debug_git_log_file] = nil

def (Tb::Cmd).op_git_log
  op = OptionParser.new
  op.banner = "Usage: tb git-log [OPTS]\n" +
    "Show the SVN log as a table."
  define_common_option(op, "hNo", "--no-pager")
  op.def_option('--git-command COMMAND', 'specify the git command (default: git)') {|command| Tb::Cmd.opt_git_log_git_command = command }
  op.def_option('--debug-git-log-file FILE', 'specify the result git log (for debug)') {|filename| Tb::Cmd.opt_git_log_debug_git_log_file = filename }
  op
end

Tb::Cmd::GIT_LOG_PRETTY_FORMAT = 'format:%x01commit-separator%x01%n' + <<'End'.gsub(/%.*/, '%w(0,1,1)\&%w(0,0,0)').gsub(/\n/, '%n')
commit:%H
tree:%T
parents:%P
author-name:%an
author-email:%ae
author-date:%ai
committer-name:%cn
committer-email:%ce
committer-date:%ci
ref-names:%d
encoding:%e
subject:%s
body:%b
raw-body:%B
notes:%N
reflog-selector:%gD
reflog-subject:%gs
end-commit
End

Tb::Cmd::GIT_LOG_HEADER = %w[
  commit
  tree
  parents
  author-name
  author-email
  author-date
  committer-name
  committer-email
  committer-date
  ref-names
  encoding
  body
  raw-body
  notes
  reflog-selector
  reflog-subject
  files
]

def (Tb::Cmd).git_log_with_git_log
  if Tb::Cmd.opt_git_log_debug_git_log_file
    File.open(Tb::Cmd.opt_git_log_debug_git_log_file) {|f|
      yield f
    }
  else
    git = Tb::Cmd.opt_svn_log_svn_command || 'git'
    IO.popen([git, 'log', "--name-only", "--decorate=full", "--pretty=#{Tb::Cmd::GIT_LOG_PRETTY_FORMAT}"]) {|f|
      yield f
    }
  end
end

def (Tb::Cmd).git_log_unescape_filename(filename)
  if /\A"/ =~ filename
    $'.chomp('"').gsub(/\\((\d\d\d)|[abtnvfr"\\])/) {
      str = $1
      if $2
        [str.to_i(8)].pack("C")
      else
        case str
        when 'a' then "\a"
        when 'b' then "\b"
        when 't' then "\t"
        when 'n' then "\n"
        when 'v' then "\v"
        when 'f' then "\f"
        when 'r' then "\r"
        when 'a' then "\a"
        when '"' then '"'
        when '\\' then "\\"
        else
          warn "unexpected escape: #{str.inspect}"
        end
      end
    }
  else
    filename
  end
end

def (Tb::Cmd).git_log_parse_commit(commit_info, files)
  commit_info = commit_info.split(/\n(?=[a-z])/)
  files = files.split(/\n/).map {|filename| git_log_unescape_filename(filename) }
  h = {}
  commit_info.each {|s|
    if /:/ !~ s
      warn "unexpected git-log output"
      next
    end
    k = $`
    v = $'.sub(/\A /, '')
    case k
    when /\A(?:author-date|committer-date)/
      v = v.sub(/\A(\d+-\d\d-\d\d) (\d\d:\d\d:\d\d) ([-+]\d\d\d\d)\z/, '\1T\2\3')
    when /\Aparents\z/
      v = ['parent', *v.split(/ /)].map {|s| s + "\n" }.join("")
    when /\Aref-names\z/
      v = v.strip.gsub(/\A\(|\)\z/, '')
      v = ['ref-name', *v.split(/, /)].map {|s| s + "\n" }.join("")
    end
    h[k] = v
  }
  h['files'] = ['filename', *files].map {|s| s + "\n" }.join("") 
  h
end

def (Tb::Cmd).git_log_each_commit(f)
  while chunk = f.gets("\x01commit-separator\x01\n")
    chunk.chomp!("\x01commit-separator\x01\n")
    next if chunk.empty? # beginning of the output
    if /\nend-commit\n\n/ !~ chunk
      warn "unexpected git-log output"
      next
    end
    h = git_log_parse_commit($`, $')
    yield h
  end

end

def (Tb::Cmd).main_git_log(argv)
  op_git_log.parse!(argv)
  exit_if_help('git-log')
  with_table_stream_output {|gen|
    git_log_with_git_log {|f|
      gen.output_header Tb::Cmd::GIT_LOG_HEADER
      f.set_encoding("ASCII-8BIT") if f.respond_to? :set_encoding
      git_log_each_commit(f) {|h|
        gen << h.values_at(*Tb::Cmd::GIT_LOG_HEADER)
      }
    }
  }
end

