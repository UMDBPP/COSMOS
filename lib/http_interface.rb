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
    # @param readSecondInterval [readSecondInterval] Interval in seconds between calling read_interface()
    # @param testFlag [testFlag] Flag indicating testing mode, true for fake data and additional verbosity
    def initialize(baseURL, secretKey, readSecondInterval = 1, testFlag = false)
      super()

      # store the arguments as class members for later use
      @baseURL = baseURL
      @secretKey = secretKey
      @testFlag = (testFlag == "true") # explicitly convert string to boolean
      @readSecondInterval = readSecondInterval.to_i

      # create read time field for second interval
      @previous_read_time = Time.now.to_i
    end

    # initialize()

    # Called connect to the interface
    def connect()
      # HTTP doesn't use a static connection, so there's really nothing to do other then call the connect method of the super
      super()
    end

    # connect()

    def connected?()
      # since HTTP doesn't use connections, always return true
      return true
    end

    # connected?()

    def disconnect()
      # HTTP doesn't use a static connection, so there's really nothing to do other than call the disconnect method of the super
      super
    end

    # disconnect()

    # Handles HTTP status code
    # @param code [code] The status code to handle
    # @return [okFlag] True if code was ok, false if code indicates error
    def handleHTTPStatus(code)
      case code
      when 200 # Ok
        Logger.info "HTTP request successful"
        return true
      when 204
        Logger.error "HTTP Error: No Content"
        return false
      when 401
        Logger.error "HTTP Error: Server rejected authentication."
        return false
      else
        Logger.error "Unhandled HTTP status: #{code}"
        return false
      end # case code
    end

    # handleHTTPStatus()

    # Retrieves the data packet from the interface using HTTP GET.
    # @return [data] Data read from the interface, or nil if read failed
    def read_interface()
      # enforce desired read second interval
      if (Time.now.to_i - @previous_read_time >= @readSecondInterval)
        @previous_read_time = Time.now.to_i

        if (@testFlag)
          Logger.info('testing HTTP read_interface()')
        else
          response = RestClient.get(@baseURL)

          # handle response
          if (handleHTTPStatus(response.code))
            # response is good, return it for the protocol to process
            Logger.info(response.body)
            #return response.body
          end
        end
      end

      # COSMOS interprets nil as a clean disconnect, so just return an empty string that the protocol wont process
      return ''
    end

    # read_interface()

    # Method to write data on the interface using HTTP POST.
    # @param data [data] Dictionary of data to send out the interface
    def write_interface(data)
      # debug output
      if (@testFlag)
        Logger.info 'testing HTTP write_interface()'
      else
        response = RestClient.post(@baseURL, data)

        # handle response
        if (handleHTTPStatus(response.code))
          # print body of response
          Logger.info response.body
        end
      end
    end
    # write_interface()

  end
  # class HttpProtocol

end
# module Cosmos
