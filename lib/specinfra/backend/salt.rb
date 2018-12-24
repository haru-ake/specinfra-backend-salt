require 'specinfra/backend/base'
require 'specinfra/backend/exec'
require 'pty'
require 'expect'
require 'open3'
require 'json'

module Specinfra
  module Backend
    class Salt < Exec
      def run_command(cmd, opts={})
        if get_config(:host) =~ /,/
          fail 'DO NOT INCLUDE COMMA IN HOSTNAME!'
        end

        cmd = build_command(cmd)
        ret = salt_exec!(cmd)

        if @example
          @example.metadata[:command] = cmd
          @example.metadata[:stdout]  = ret[:stdout]
        end

        CommandResult.new ret
      end

      def send_file(from, to)
        fail 'not implemented'
      end

      def send_directory(from, to)
        fail 'not implemented'
      end

      def build_command(cmd)
        cmd = build_salt_command(cmd)

        case get_config(:salt_become_method)
        when :none
          cmd
        when :su
          cmd = "/bin/sh -c #{cmd.shellescape} 2> /dev/null"
          "#{su} #{cmd.shellescape}"
        else
          "#{sudo} /bin/sh -c #{cmd.shellescape}"
        end
      end

      private

      def build_salt_command(cmd)
        options = "env='#{load_env}'"

        user = get_config(:salt_user)
        options = "#{options} runas='#{user}'" if user
        shell = get_config(:shell) || '/bin/sh'
        options = "#{options} shell='#{shell}'"

        # avoid failing commands by removing trailing whitespace by salt command.
        cmd += ';'

        pre_cmd = get_config(:pre_command)
        cmd = "#{pre_cmd} && #{cmd}" if pre_cmd

        "salt -L #{get_config(:host)} --out=json cmd.run #{options} #{cmd.shellescape}"
      end

      def load_env
        env = get_config(:env) || {}
        env[:LANG] ||= 'C'
        env.to_json
      end

      def salt_error_message_regexp
        /^Minion\ did\ not\ return\.\ \[.*\]$/
      end

      def sudo_fail_message_regexp
        /(Sorry,\ try\ again\.|sudo:\ [0-9]+\ incorrect\ password\ attempts)\R/
      end

      def su_prompt_regexp
        /^Password:\s*/
      end

      def su_fail_message_regexp
        /^su:\ (Authentication\ failure|Sorry)\R/
      end

      def parse_salt_response(response)
        stdout_data = JSON.parse(response[:stdout])[get_config(:host)]
        if stdout_data =~ salt_error_message_regexp
          fail "salt command failed. #{response.to_s}"
        end

        stderr_data = response[:stderr]
        exit_status = response[:exit_status]

        { :stdout => stdout_data, :stderr => stderr_data, :exit_status => exit_status }
      rescue JSON::ParserError
        fail "salt command failed. #{response.to_s}"
      end

      def salt_exec!(cmd)
        r = get_config(:salt_become_method) == :su ? \
          exec_with_pty!(cmd) : exec_with_open3!(cmd)
        parse_salt_response(r)
      end

      def exec_with_open3!(cmd)
        sudo_password = nil
        if get_config(:salt_become_method) != :none && get_config(:salt_sudo_password)
          sudo_password = get_config(:salt_sudo_password) + "\n"
        end

        stdout_data, stderr_data, status = Open3.capture3(cmd, :stdin_data => sudo_password)
        if stderr_data =~ sudo_fail_message_regexp
          fail 'Wrong sudo password! Please confirm your password.'
        end

        { :stdout => stdout_data, :stderr => stderr_data, :exit_status => status.exitstatus }
      end

      def exec_with_pty!(cmd)
        stdout_data, stderr_data = '', ''
        exit_status = nil

        PTY.spawn({'LANG' => 'C'}, cmd) do |r, w, pid|
          w.sync = true

          unless Process.uid == 0
            r.expect(su_prompt_regexp) do
              w.puts get_config(:salt_su_password)
            end
          end

          begin
            r.each do |line|
              if line =~ su_fail_message_regexp
                fail 'Wrong su password! Please confirm your password.'
              end
              stdout_data << line
            end
          rescue Errno::EIO
          ensure
            p = Process.wait2 pid
            exit_status = p[1].exitstatus
          end
        end

        { :stdout => stdout_data, :stderr => stderr_data, :exit_status => exit_status }
      end

      def sudo
        sudo_path = 'sudo'
        sudo_path = "#{get_config(:salt_sudo_path)}/#{sudo_path}" if get_config(:salt_sudo_path)
        sudo_user = get_config(:salt_sudo_user) || 'root'

        "#{sudo_path} -S -u #{sudo_user}"
      end

      def su
        su_path = 'su'
        su_path = "#{get_config(:salt_su_path)}/#{su_path}" if get_config(:salt_su_path)
        su_user = get_config(:salt_su_user) || 'root'

        "#{su_path} #{su_user} -c"
      end
    end
  end
end
