# coding: utf-8

module Romglog
  VERSION = '0.0.8'

  def run_on system
    Romglog::Base.run
    on_terminal_resize { Romglog::Base.run }
    system.on_change { Romglog::Base.run }
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
    YELLOW, BLUE, GREY, HIGHLIGHT = '0;33', '0;34', '0;90', '1;30;47'
    CMD = %{git reflog}

    def self.log_cmd
      @log_cmd ||= [CMD].concat(ARGV).join(' ')
    end

    def self.run
      rows, cols = `tput lines; tput cols`.scan(/\d+/).map(&:to_i)
      `#{log_cmd}`.tap {|log|
        log_lines = Array.new(rows, '')
        log_lines.unshift(*log.split("\n"))

        print CLEAR + log_lines[0...(rows - 1)].map {|l|
          render_line(l)
        }.join("\n") + "\n" + "\e[#{GREY}mupdated #{Time.now.strftime("%a %H:%M:%S")}\e[m ".rjust(cols + 8)
      }
    end

    def self.render_line line
      cols = line.split(' ')
      (["\e[#{YELLOW}m#{cols.shift}\e[m"] + cols).join(' ')
    end

  end
end
