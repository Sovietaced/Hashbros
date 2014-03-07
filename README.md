Hashbros
======
Hashbros is an alt-coin profit-switching mining and auto exchanging multi-pool that is awesome. Hashbros is transparent, intelligently distributed, and written in Ruby on Rails.

## Features
* Block, Deposit, Order, and Trade tracking
* Cryptsy API integration
* Profit Switching
* Worker Stats
* Up to the minute coin stats/profitability
* Historical coin/pool/worker stats
* Carefully crafted architecture for running financial audits
* Automated payouts/redemptions
* New Relic integration for reporting engine/cron task errors
* Capistrano deployment recipes

## Disclaimer
The git revision history has been wiped to remove sensitive data. This code has a number of stubs where you will have enter your own credentials/configuration details to get things really working. Keep in mind that this is only 1/3 of the entire Hashbros architecture. Also, the styling was reverted to stock bootstrap considering the styling was not a product of our own. If you do get this running yourself you will largely find that it is quite useless. This has been open sourced primarily in hopes that those can learn from our code. Most of the magic happens in app/models/engine. If anyone really wants to maintain this codebase in a similar fashion to MPOS, you are welcomed to do so, just drop us an email. 

## Setup
1. Clone down the repo
2. Bundle and install any needed dependencies `bundle install`
3. Set up the DB: `rake db:create, rake db:migrate`
4. Start that bish up : `rails s`

## Primary developers
* [Jason Parraga (Full Stack)](https://github.com/Sovietaced)
* [Bob Nisco (Full Stack)](https://github.com/BobNisco)

## Special thanks
* [Travis Beatty (Platform)](https://github.com/travisby)
* [Vin Raia (Finance)](https://github.com/VincentRaia)
* [Anthony Barranco (Security/Consulting)](https://github.com/AnthonyB28)
