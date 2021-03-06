# coding: utf-8

module Omglog
  VERSION = '0.0.8'

  def run_on system
    Omglog::Base.run
    on_terminal_resize { Omglog::Base.run }
    system.on_change { Omglog::Base.run }
  end
  module_function :run_on

  def on_terminal_resize &block
    rendering = true
    trap("WINCH") {
      # A dragging resize fires lots of WINCH events; this throttles the redraw
      # and should cause it to (usually) line up with the final dimensions.
      if rendering
        rendering = false
        sleep 0.5
        rendering = true
        yield
      end
    }
  end
  module_function :on_terminal_resize

  class Base
    CLEAR = "\n----\n"
    GREEN, YELLOW, BLUE, GREY, HIGHLIGHT = '0;32', '0;33', '0;34', '0;90', '1;30;47'
    SHORTEST_MESSAGE = 12
    LOG_CMD = %{git log --all --date-order --graph --color --pretty="format: \2%h\3\2%d\3\2 %an, %ar\3\2 %s\3"}
    LOG_REGEX = /(.*)\u0002(.*)\u0003\u0002(.*)\u0003\u0002(.*)\u0003\u0002(.*)\u0003/

    def self.log_cmd
      @log_cmd ||= [LOG_CMD].concat(ARGV).join(' ')
    end

    def self.run
      rows, cols = `tput lines; tput cols`.scan(/\d+/).map(&:to_i)
      `#{log_cmd} -#{rows}`.tap {|log|
        log_lines = Array.new(rows, '')
        log_lines.unshift *log.split("\n")

        print CLEAR + log_lines[0...(rows - 1)].map {|l|
          commit = l.scan(LOG_REGEX).flatten.map(&:to_s)
          commit.any? ? render_commit(commit, cols) : l
        }.join("\n") + "\n" + "\e[#{GREY}mupdated #{Time.now.strftime("%a %H:%M:%S")}\e[m ".rjust(cols + 8)
      }
    end

    def self.render_commit commit, cols
      row_highlight = commit[2][/[^\/]HEAD\b/] ? HIGHLIGHT : YELLOW
      [nil, row_highlight, GREEN, '', GREY].map {|c| "\e[#{c}m" if c }.zip(
        arrange_commit(commit, cols)
      ).join + "\e[m"
    end

    def self.arrange_commit commit, cols
      commit[0].chomp!(' ')
      commit[-2].sub!(/(\d+)\s(\w)[^\s]+ ago/, '\1\2 ago')
      room = [cols - [commit[0].gsub(/\e\[[\d;]*m/, ''), commit[1..-2]].flatten.map(&:length).inject(&:+), SHORTEST_MESSAGE].max
      commit.tap {|commit|
        commit[-1, 0] = if commit[-1].length > room
          commit.pop[0...(room - 1)] + '…'
        else
          commit.pop.ljust(room)
        end
      }
    end
  end
end
