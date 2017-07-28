require 'spec_helper'

shared_examples 'security plugin logging' do |plugin, logfile, tests|
  describe "security logging configuration file for #{plugin}" do
    tests.each_pair do |param_type, params|
      context "with no security plugin defined for #{param_type}" do
        let(:params) do
          { "security_logging_#{param_type}" => params[:manifest] }
        end

        it { should_not compile.with_all_deps }
      end

      context "parameter #{param_type}" do
        let(:params) do
          {
            :security_plugin => plugin,
            "security_logging_#{param_type}" => params[:manifest]
          }
        end

        it { should contain_file("/etc/elasticsearch/#{plugin}")
          .with_ensure('directory')}

        case param_type
        when 'source'
          it 'sets the source for the file resource' do
            should contain_file("/etc/elasticsearch/#{plugin}/#{logfile}")
              .with_source(params[:value])
          end
        when 'content'
          it 'sets logging file yaml content' do
            should contain_file("/etc/elasticsearch/#{plugin}/#{logfile}")
              .with_content(params[:value])
          end
        end
      end
    end
  end
end

describe 'elasticsearch', :type => 'class' do
  let(:facts) do
    {
      :common => '',
      :hostname => 'foo',
      :kernel => 'Linux',
      :os => {
        :family => 'RedHat',
        :name => 'CentOS',
        :release => {
          :major => '6'
        }
      },
      :scenario => ''
    }
  end

  include_examples 'security plugin logging',
                   'shield',
                   'logging.yml',
                   'content' => {
                     :manifest => "one: two\nfoo: bar\n",
                     :value => "one: two\nfoo: bar\n"
                   },
                   'source' => {
                     :manifest => '/foo/bar.yml',
                     :value => '/foo/bar.yml'
                   }

  include_examples 'security plugin logging',
                   'x-pack',
                   'log4j2.properties',
                   'content' => {
                     :manifest => "one = two\nfoo = bar\n",
                     :value => "one = two\nfoo = bar\n"
                   },
                   'source' => {
                     :manifest => '/foo/bar.properties',
                     :value => '/foo/bar.properties'
                   }
end
