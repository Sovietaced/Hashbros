namespace :engine do


  def lock!
    `touch lock`
  end

  def unlock!
    `rm lock`
  end

  task run: :environment do

    include ForkHelper
    require 'newrelic-rake'
    NewRelic::Agent.manual_start

    # Only continue if no existing rake operations are going
    if not File.exists?('lock')
      # Create a lock file
      lock!

      begin
         puts "start : " + Time.now.to_s
        
        ForkHelper.fork_with_new_connection do 
          Engine::BlockEngine.block_task
           puts "block : " + Time.now.to_s
        end

        ForkHelper.fork_with_new_connection do 
          Engine::ProfitSwitchEngine.update_worker_stats
           puts "worker stats : " + Time.now.to_s
        end

        ForkHelper.fork_with_new_connection do 
          Engine::ProfitSwitchEngine.update_rounds
           puts "round stats : " + Time.now.to_s
        end
         
        ForkHelper.fork_with_new_connection do 
          Engine::DepositEngine.deposit_task
           puts "deposits : " + Time.now.to_s
        end

        ForkHelper.fork_with_new_connection do 
          Engine::TradingEngine.trade_task  
           puts "trades : " + Time.now.to_s
        end

        ForkHelper.fork_with_new_connection do 
           Engine::ProfitSwitchEngine.profit_switch_task
            puts "profit switch : " + Time.now.to_s
        end

        ForkHelper.fork_with_new_connection do 
          Engine::PayoutEngine.payout_task
           puts "payouts : " + Time.now.to_s
        end

        # Wait for all our forks to finish
        Process.waitall

        # Remove lock file
        unlock!

      # If shit fails remove the lock file and report the problem
      rescue => e
        unlock!
        NewRelic::Agent.notice_error(StandardError.new("Engine Failed. Backtrace : #{e.backtrace}"))
      end
    end
  end

  task auto_redeem: :environment do

    require 'newrelic-rake'
    NewRelic::Agent.manual_start
    
    begin
      Engine::RedemptionEngine.auto_redeem
    rescue => e
      NewRelic::Agent.notice_error(StandardError.new("Auto Redeem Failed. Backtrace : #{e.backtrace}"))
    end
  end

  task process_redemptions: :environment do

    require 'newrelic-rake'
    NewRelic::Agent.manual_start
    
    begin
      Engine::RedemptionEngine.redemption_task
    rescue => e
      NewRelic::Agent.notice_error(StandardError.new("Redemption Processing Failed. Backtrace : #{e.backtrace}"))
    end
  end

  task update_coins: :environment do

    require 'newrelic-rake'
    NewRelic::Agent.manual_start
    
    begin
      Engine::PoolEngine.pool_task
      Engine::CoinEngine.coin_task
    rescue => e
      NewRelic::Agent.notice_error(StandardError.new("Update Coins Failed. Backtrace : #{e.backtrace}"))
    end
  end

  # Daily withdrawal of BTC from cryptsy exchange
  task withdraw: :environment do

    require 'newrelic-rake'
    NewRelic::Agent.manual_start
    
    begin
      Engine::ExchangeEngine.withdraw
    rescue => e
      NewRelic::Agent.notice_error(StandardError.new("Auto Withdraw Failed. Backtrace : #{e.backtrace}"))
    end
  end
end
