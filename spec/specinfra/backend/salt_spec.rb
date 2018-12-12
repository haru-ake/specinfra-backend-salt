require "spec_helper"

RSpec.describe Specinfra::Backend::Salt do
  it "has a version number" do
    expect(Specinfra::SaltBackend::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
