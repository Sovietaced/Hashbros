module ForkHelper
  	# Logic for forking connections
  # The forked process does not have access to static vars as far as I can discern, so I've done some stuff to check if the op threw an exception.
  def self.fork_with_new_connection
    # Store the ActiveRecord connection information
    config = ActiveRecord::Base.remove_connection
 
    Process.fork do

      begin
        ActiveRecord::Base.establish_connection(config)
 
        # Run the closure passed to the fork_with_new_connection method
        yield
 
      rescue Exception => exception
        puts ("Forked operation failed with exception: " + exception)

      ensure
        ActiveRecord::Base.remove_connection
        Process.exit! 
      end
    end
 
    # Restore the ActiveRecord connection information
    ActiveRecord::Base.establish_connection(config)
 
  end 
end