# encoding: ascii-8bit

# Copyright 2014 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt

# This file implements an example background task

require 'cosmos/tools/cmd_tlm_server/background_task'

module Cosmos

  # ExampleBackgroundTask class
  #
  # This class is an example background task
  #
  class ExampleBackgroundTask < BackgroundTask

    def initialize
      super()
      @name = 'Example Background Task'
      @sleeper = Sleeper.new
    end

    def call
      sent_count = 0
      @status = "Sleeping for 5 seconds"
      return if @sleeper.sleep(5) # allow interfaces time to start
      loop do
        #Make sure we start up with 3 collects
        if (tlm('INST', 'HEALTH_STATUS', 'COLLECTS') < 3)
          begin
            cmd('INST', 'COLLECT', 'TYPE' => 'NORMAL', 'DURATION' => 1)
            sent_count += 1
            @status = "Sent COLLECT ##{sent_count} at #{Time.now.formatted}"
          rescue
            # Oh well - probably disconnected
          end
        else
          break
        end
        return if @sleeper.sleep(1)
      end
      @status = "Finished at #{Time.now.formatted}"
    end

    def stop
      @sleeper.cancel
    end

  end # class ExampleBackgroundTask

end # module Cosmos
