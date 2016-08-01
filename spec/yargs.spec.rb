#! /usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))

require 'bundler/setup'
require 'yargs'

describe "Yargs" do
  describe "#flag(key) | #flag?(key) {}" do
    it "Accepts flags with two leading hyphens" do
      yargs = Yargs.new %w[--simpleflag]
      expect(yargs.flag('simpleflag')).to eql(true)
    end
    
    it "Accepts flags with hyphens in the name" do
      yargs = Yargs.new %w[--split-flag]
      expect(yargs.flag('split-flag')).to eql(true)
    end
    
    it "Accepts flags with one leading hyphen" do
      yargs = Yargs.new %w[-single-dash-flag]
      expect(yargs.flag('single-dash-flag')).to eql(true)
    end
    
    it "removes the flag from the remaining args." do
      yargs = Yargs.new %w[--flags-are-consumed 1]
      unless yargs.flag('flags-are-consumed') && yargs.value('flags-are-consumed').nil?
        fail("Flags should be consumed when read")
      end
    end
    
    it "Doesn't match another flag with a common prefix" do
      yargs = Yargs.new(%w[--test])
      fail('Matched by prefix') if yargs.flag?('t')
    end
  end
  
  describe "#value" do
    it "Accepts = seprated key value pairs (--value=1)" do
      yargs = Yargs.new %w[--simplevalue=1]
      expect(yargs.value('simplevalue')).to eql('1')
    end
    
    it "Reads all characters after the first = as the value (--value=test=ing)" do
      yargs = Yargs.new ["--longvalue=make sure WE are R3ading = @ll (harcacter5"]
      expect(yargs.value('longvalue')).to eql('make sure WE are R3ading = @ll (harcacter5')
    end
    
    it "Accepts values that are supplied as a separate argument (i.e. space sepearated: --value 1)" do
      yargs = Yargs.new ["--longvalue", "make sure WE are R3ading @ll (harcacter5"]
      expect(yargs.value('longvalue')).to eql('make sure WE are R3ading @ll (harcacter5')
    end
    
    it "Accepts a single argument with space separated key and value ('--value 1')" do
      yargs = Yargs.new %w[--space-sep-value 2]
      expect(yargs.value('space-sep-value')).to eql('2')
    end
    
    it "Accepts values whose key has only a single leading hyphen (-value=1)" do
      yargs = Yargs.new %w[-single-dash-value=3]
      expect(yargs.value('single-dash-value')).to eql('3')
    end
    
    it "removes the value form the remaining args." do
      yargs = Yargs.new %w[--values-are-consumed 1]
      unless yargs.value('values-are-consumed') == '1' && !yargs.flag('values-are-consumed')
        fail("Flags should be consumed when read")
      end
    end
    
    it "Doesn't match another value with a common prefix" do
      yargs = Yargs.new(%w[--test ing])
      fail('Matched by prefix') if yargs.value('t')
      
      yargs = Yargs.new(%w[--test=ing])
      fail('Matched by prefix') if yargs.value('t')
    end
  end
  
  describe '::parse(argv, &block)' do
    it 'instance_evals the given block on a new Yargs instance created with argv' do
      opt = {}
      Yargs.parse(%w[-test=ing]) do
        opt[:test] = value(:test)
      end
      expect(opt[:test]).to eql('ing')
    end
  end
end