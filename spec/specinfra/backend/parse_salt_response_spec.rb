require "spec_helper"

RSpec.describe Specinfra::Backend::Salt do
  before(:all) do
    set :backend, :salt
    set :host, 'localhost'
  end

  describe '#parse_salt_response' do
    subject { Specinfra.backend.send(:parse_salt_response, response) }

    context 'with json string' do
      context 'normal response' do
        let(:response) { { :stdout => "{\r\n    \"localhost\": \"test\"\r\n}\r\n", :stderr => '', :exit_status => 0 } }
        it { expect(subject).to include(:stdout => 'test', :stderr => '', :exit_status => 0) }
      end
      context 'failed response' do
        let(:response) { { :stdout => "{\r\n    \"localhost\": \"Minion did not return. [Not connected]\"\r\n}\r\n", :stderr => '', :exit_status => 0 } }
        it { expect { subject }.to raise_error(RuntimeError) }
      end
    end

    context 'with not json string' do
      let(:response) { { :stdout => 'not json string', :stderr => '', :exit_status => 1 } }
      it { expect { subject }.to raise_error(RuntimeError) }
    end
  end
end
