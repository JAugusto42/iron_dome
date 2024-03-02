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
      system_output(results) unless options[:sarif_output] == true
      output_sarif_file_format(results) if options[:sarif_output] == true
    end

    def output_sarif_file_format(results)
      # method to call the module to generate the sarif report
      puts "Generating the sarif output ..."
      IronDome::Sarif::Output.new.output_report(results)
      puts "Sarif file outputted"
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
      total_vulnerabilities = 0

      puts ":: Vulnerabilities found:".colorize(:red)
      results.each do |result|
        result["vulns"].each do |vulnerability|
          print_vulnerability_info(vulnerability)
          total_vulnerabilities += 1
        end
      end

      puts "#{total_vulnerabilities} vulnerabilities founded.".colorize(:light_red)
    end

    def print_vulnerability_info(vulnerabilities)
      package_name = extract_package_name(vulnerabilities)
      version_fixed = extract_version_fixed(vulnerabilities)
      summary = vulnerabilities["summary"]
      details = vulnerabilities["details"]

      print_info(package_name, version_fixed, summary, details)
    end

    def extract_package_name(vulnerability)
      affected_package = vulnerability["affected"].first
      affected_package["package"]["name"]
    end

    def extract_version_fixed(vulnerability)
      affected_package = vulnerability["affected"].first
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
