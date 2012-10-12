#!/usr/bin/env ruby

$: << File.expand_path("lib", File.dirname(__FILE__))
require 'optparse'
require 'base_check'
require 'net/http'
require 'net/https'
require 'uri'
require 'rubygems'
require 'bundler/setup'
Bundler.require

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename $0} [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-w", "--warn RANGE", "Set warning alert range") do |w|
    options[:warning] = w
  end

  opts.on("-c", "--critical RANGE", "Set critical alert range") do |c|
    options[:critical] = c
  end
end.parse!

module MingleNagiosChecks
  class ThreadUsage < BaseCheck
    attr_reader :uri, :warning, :critical

    def initialize(uri, options={})
      @uri = uri
      @warning = options[:warning] || "7"
      @critical = options[:critical] || "11"
      @verbose = options[:verbose]
    end

    def report
      doc = Nokogiri::HTML(read_status)
      threads = (doc.css('td').select{ |cell| cell.text.strip =~ /Number of threads accessing the runtime/ }).first.next.text.strip.to_i
      if alert_for_range? critical, threads
        log "Critical - thread count: #{threads}"
        2
      elsif alert_for_range? warning, threads
        log "Warning - thread count: #{threads}"
        1
      else
        log "OK - thread count: #{threads}"
        0
      end
    end

    private

    def read_status
      location = URI.parse(uri)
      http = Net::HTTP.new(location.host, location.port).tap do |http|
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new(location.request_uri)

      response = http.request(request)

      if response.code != "200"
        puts "reading #{uri} failed"
        exit 3
      end

      response.body
    end
  end
end

if __FILE__ == $0
  begin
    raise "You must provide a uri!" if ARGV.size < 1
    exit(MingleNagiosChecks::ThreadUsage.new(ARGV[0], options).report)
  rescue => e
    puts e.message
    exit 3
  end
end