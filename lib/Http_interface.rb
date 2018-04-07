# encoding: ascii-8bit

require 'cosmos'
require 'cosmos/interfaces/interfaces/interface'
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

    end # initialize()

    # Called connect to the interface
    def connect()
      
      # HTTP doesnt use a static connection, so there's really nothing to do
      
      # then call the connect method of the Interface class:
      super()
    end # connect()
    
    def connected?()
      # since HTTP doesnt use connections, always return true
      return true
    end # connected?()
    
    def disconnect()
      # HTTP doesnt use a static connection, so there's really nothing to do
      
      # then call the disconnect method of the Interface class:
      super()
    end # disconnect()
    
    # Retrieves the data packet from the interface.
    # @param code [code] The HTTP status code to handle
    # @return [okFlag] True if code was ok, false if code indicates error
    def handleHTTPStatus(code)
      case response.code
      when 200 # Ok
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
        puts "Unhandled HTTP status: #{response.code}"
        return false
      end # case response.code
    end handleHTTPStatus()
    
    # Retrieves the data packet from the interface.
    # @return [data] Data read from the interface, or nil if read failed
    def read_interface()
    
      # create an HTTP request
      uri = URI(@baseURL)
      req = Net::HTTP::Post.new(uri.request_uri)
      
      # add the fields
      req.set_form_data('testing' => @testFlag, 'secretKey' => @secretKey)

      # debug output
      if(@testFlag)
        puts req.to_hash # hash of request headers
      end

      # send it (will block until returns)
      response = Net::HTTP.get_response(uri)
      
      # handle response
      if(@testFlag)
        puts response.body
      end
      
      if(handleHTTPStatus(code))
        return response.body
      else
        return nil
      end

    end # read_interface()
    
    # Method to write data on the interface.
    # @param data [data] The data to send out the interface
    def write_interface(data)
    
      # create an HTTP request
      uri = URI(@baseURL)
      req = Net::HTTP::Post.new(uri.request_uri)
      
      # add the fields
      req.set_form_data('testing' => @testFlag, 'secretKey' => @secretKey, 'data' => data)

      # debug output
      if(@testFlag)
        puts req.to_hash # hash of request headers
      end

      # send it (will block until returns)
      response = Net::HTTP.get_response(uri)
      
      # handle response
      if(@testFlag)
        puts response.body
      end
      
      handleHTTPStatus(code)
    end
    
  end # class HttpProtocol
end # module Cosmos
