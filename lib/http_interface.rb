# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/interface'
require 'net/http'
require 'uri'

module Cosmos
  # Interface to communicate via HTTP requests
  class HttpInterface < Interface

    # Initializes the interface
    # @param baseURL [baseURL] the url to send the request to
    # @param secretKey [secretKey] Authetication token to send to server
    # @param testFlag [testFlag] Flag indicating testing mode, true for fake data and additional verbosity
    def initialize(baseURL, secretKey, testFlag = false)
      super()

      # store the arguments as class members for later use
      @baseURL = baseURL
      @secretKey = secretKey
      @testFlag = testFlag
    end

    # initialize()

    # Called connect to the interface
    def connect()
      # HTTP doesnt use a static connection, so there's really nothing to do then call the connect method of the Interface class:
      super()
    end

    # connect()

    def connected?()
      # since HTTP doesnt use connections, always return true
      return true
    end

    # connected?()

    def disconnect()
      # HTTP doesnt use a static connection, so there's really nothing to do then call the disconnect method of the Interface class:
      super()
    end

    # disconnect()

    # Retrieves the data packet from the interface.
    # @param code [code] The HTTP status code to handle
    # @return [okFlag] True if code was ok, false if code indicates error
    def handleHTTPStatus(code)
      case code
      when Net::HTTPSuccess, Net::HTTPRedirection # 200 Ok
        # request succeeded
        # return the data for processing by the protocol
        return true
      when 204 # No Content
        # return no data
        return false
      when 401 # Unauthorized
        puts "Server rejected authentication!"
        return false
      else
        puts "Unhandled HTTP status: #{code}"
        return false
      end # case code
    end

    # handleHTTPStatus()

    # Retrieves the data packet from the interface using HTTP GET.
    # @return [data] Data read from the interface, or nil if read failed
    def read_interface()
      # create an HTTP request
      uri = URI(@baseURL)

      # open connection with ::start
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri

        response = http.request request # Net:HTTPResponse object
      end

      # handle response
      if (@testFlag)
        # print body of response
        puts response.body
      elsif (handleHTTPStatus(response.code))
        # response is good, return it for the protocol to process
        return response.body
      else
        # COSMOS interprets nil as a failure, so just return an empty string that the protocol wont process
        return ''
      end
    end

    # read_interface()

    # Method to write data on the interface using HTTP POST.
    # @param data [data] The data to send out the interface
    def write_interface(data)
      # create an HTTP request
      uri = URI(@baseURL)

      imei = 'test'
      momsn = 'test'
      transmit_time = 'test'
      iridium_latitude = 'test'
      iridium_longitude = 'test'
      iridium_cep = 'test' # in km
      data = 'test'

      # instantiate new Post form
      request = Net::HTTP::Post.new(uri)

      # populate POST form
      request.set_form_data(uri, 'imei' => imei,
                            'momsn' => momsn,
                            'transmit_time' => transmit_time,
                            'iridium_latitude' => iridium_latitude,
                            'iridium_longitude' => iridium_longitude,
                            'iridium_cep' => iridium_cep,
                            'data' => data
      )

      # debug output
      if (@testFlag)
        # print hash of request headers instead of sending over HTTP
        puts request.to_hash
      else
        # open connection with ::start
        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end
      end

      # handle response
      if (@testFlag)
        # print body of response
        puts response.body
      else
        handleHTTPStatus(response.code)
      end
    end
    # write_interface()

  end
  # class HttpProtocol

end
# module Cosmos
