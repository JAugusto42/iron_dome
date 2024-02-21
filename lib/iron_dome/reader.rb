# frozen_string_literal: true

module IronDome
  # The Reader class is responsible for reading lock files from the project and generating SARIF reports.
  class Reader
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def call
      read_file
    end

    private

    def read_file
      # read the lockfile, Gemfile.lock for now
      lock_files = Dir.glob("Gemfile.lock")
      lock_files.map { |file| process_lock_file(file) }
    end

    def process_lock_file(file)
      file_lines = File.read(file).lines
      packages_and_versions = file_lines.flat_map { |line| line.scan(/\b(\w+) \(([\d.]+)\)/) }.to_h
      puts "Verifying vulnerabilities on osv database ..."
      results = Requester.osv_request(packages_and_versions)
      results.compact!
      system_output(results)
      output_sarif_file_format(results) if options[:sarif_output] == true
    end

    def output_sarif_file_format(results)
      # method to call the module to generate the sarif report
      puts "Generating the sarif output ..."
      IronDome::Sarif::Output.new.output_report(results)
      puts "Sarif file outputed"
    end

    def system_output(results)
      # method to call module to output the results on current shell.
      if results.empty?
        puts "No vulnerabilities founded".colorize(:green)
        return
      end

      build_output(results)
    end

    def build_output(results)
      # Build the terminal output but maybe we will need to improve this methods.
      total_vulns = 0

      puts ":: Vulnerabilities found:"
      results.each do |result|
        result["vulns"].each do |vuln|
          print_vulnerability_info(vuln)
          total_vulns += 1
        end
      end

      puts "#{total_vulns} vulnerabilities founded.".colorize(:red)
    end

    def print_vulnerability_info(vuln)
      package_name = extract_package_name(vuln)
      version_fixed = extract_version_fixed(vuln)
      summary = vuln["summary"]
      details = vuln["details"]

      print_info(package_name, version_fixed, summary, details)
    end

    def extract_package_name(vuln)
      affected_package = vuln["affected"].first
      affected_package["package"]["name"]
    end

    def extract_version_fixed(vuln)
      affected_package = vuln["affected"].first
      version_ranges = affected_package["ranges"].first
      version_ranges["events"].last["fixed"]
    end

    def print_info(package_name, version_fixed, summary, details)
      puts "-------------------------------------".colorize(:blue)
      puts "Package Name: #{package_name}".colorize(:magenta)
      puts "Summary: #{summary}".colorize(:yellow)
      puts "Details: #{details}".colorize(:cyan) if options[:detail] == true
      puts "Version fixed: #{version_fixed}".colorize(:green)
      puts "-------------------------------------".colorize(:blue)
    end
  end
end
