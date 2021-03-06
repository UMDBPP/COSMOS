# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/interface'
require 'rest-client'

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

    # Handles HTTP status code
    # @param code [code] The status code to handle
    # @return [okFlag] True if code was ok, false if code indicates error
    def handleHTTPStatus(code)
      case code
      when 200 # Ok
        puts "HTTP request successful"
        return true
      when 204
        puts "HTTP Error: No Content"
        return false
      when 401
        puts "HTTP Error: Server rejected authentication."
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
      uri = URI(@baseURL)

      if (@testFlag)
        return 'testing HTTP read_interface()'
      else
        response = RestClient.get(uri)

        # handle response
        if (handleHTTPStatus(response.code))
          # response is good, return it for the protocol to process
          return response.body
        else
          # COSMOS interprets nil as a failure, so just return an empty string that the protocol wont process
          return ''
        end
      end
    end

    # read_interface()

    # Method to write data on the interface using HTTP POST.
    # @param data [data] Dictionary of data to send out the interface
    def write_interface(data)
      uri = URI(@baseURL)

      # debug output
      if (@testFlag)
        # print hash of request headers instead of sending over HTTP
        puts 'testing HTTP write_interface()'
      else
        response = RestClient.post(uri, form_data)

        # handle response
        if (handleHTTPStatus(response.code))
          # print body of response
          puts response.body
        end
      end
    end
    # write_interface()

  end
  # class HttpProtocol

end
# module Cosmos
