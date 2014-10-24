require 'yaml'
require 'countries'

module ISO

  # SWIFT
  #
  # Usage
  # =====
  #
  class SWIFT

    # Swift regular expression
    Regex = /^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$/

    # Attributes
    AttrReaders = [
      :formatted_swift,
      :bank_code,
      :bank_name,
      :country_code,
      :country_name,
      :location_code,
      :location_name,
      :branch_code,
      :branch_name
    ]

    AttrReaders.each do |meth|
      define_method meth do
        @data[meth.to_s]
      end
    end

    attr_reader :data
    attr_reader :errors

    # @param [String] swift
    #   The SWIFT in either compact or human readable form.
    #
    # @return [ISO::SWIFT]
    #   A new instance of ISO::SWIFT 
    def initialize(swift)
      @data = {}
      @errors = []
      swift = parse(swift)
      validate(swift)
      if @errors.empty?
        feed_codes(swift)
        feed_lookup_info(swift)
      end
    end

    # @param [String] swift
    #   The SWIFT in either compact or human readable form.
    #
    # Extracts bank, country, location and branch codes from the parameter 
    def feed_codes(swift)
      if @errors.empty?
        @data["formatted_swift"] = swift
        @data["bank_code"] = swift[0..3]
        @data["country_code"] = swift[4..5]
        country = ::Country.new(country_code)
        @data["country_name"] = country.name if country
        @data["location_code"] = swift[6..7]
        @data["branch_code"] = swift[8..10]
      end
    end

    # @param [String] swift
    #   The SWIFT in either compact or human readable form.
    #
    # Lookup for the formatted swift in data/*country_code*.yml
    # If found, extract the bank, location and branch names
    def feed_lookup_info(swift)
      cc = country_code.upcase
      db = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', cc + '.yml' ))
      lk = db[formatted_swift]
      if lk
        @data["bank_name"] = lk["institution"]
        @data["location_name"] = lk["city"]
        @data["branch_name"] = lk["branch"]
      end
    end

    # @return [String]
    #   Retuns the formatted swift from an ISO::SWIFT instance
    def formatted_swift
      @data["formatted_swift"].to_s
    end

    # @return [String]
    #   Retuns the bank code from an ISO::SWIFT instance
    def bank_code
      @data["bank_code"].to_s
    end

    # @return [String]
    #   Retuns the bank name from an ISO::SWIFT instance
    def bank_name
      @data["bank_name"].to_s
    end

    # @return [String]
    #   Retuns the country code from an ISO::SWIFT instance
    def country_code
      @data["country_code"].to_s
    end

    # @return [String]
    #   Retuns the country name from an ISO::SWIFT instance
    #   The country name was fetched using https://github.com/hexorx/countries
    def country_name
      @data["country_name"].to_s
    end

    # @return [String]
    #   Retuns the location code from an ISO::SWIFT instance
    def location_code
      @data["location_code"].to_s
    end

    # @return [String]
    #   Retuns the location name from an ISO::SWIFT instance
    def location_name
      @data["location_name"].to_s
    end

    # @return [String]
    #   Retuns the branch code from an ISO::SWIFT instance
    def branch_code
      @data["branch_code"].to_s
    end

    # @return [String]
    #   Retuns the branch name from an ISO::SWIFT instance
    def branch_name
      @data["branch_name"].to_s
    end

    # @return [Array<Sym>]
    #   Retuns an array of errors in symbol format from validation step, if any
    def errors
      @errors.to_a
    end

    # @return [Boolean]
    #   Returns if the current ISO::SWIFT instance if valid
    def valid?
      @errors.empty?
    end

    private

    # @param [String] swift
    #   The SWIFT in either compact or human readable form.
    #
    # Validation of the length and format of the formatted swift
    def validate(swift)
      @errors << :too_short if swift.size < 8
      @errors << :too_long if swift.size > 11
      @errors << :bad_chars unless swift =~ /^[A-Z0-9]+$/
      @errors << :bad_format unless swift =~ Regex
    end

    # @param [String] swift
    #   The SWIFT in either compact or human readable form.
    #
    # @return [String]
    #   The SWIFT in compact form, all whitespace and dashes stripped.
    def strip(swift)
      swift.delete("\n\r\t -")
    end

    # @param [String, nil] swift
    #   The SWIFT in either compact or human readable form.
    #
    # @return [String]
    #   The SWIFT in either compact or human readable form.
    def parse(swift)
      strip(swift || "").upcase
    end
  end
end