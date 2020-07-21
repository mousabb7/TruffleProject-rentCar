# Rent Car #
## How it works ##
Once you put the car for rent, any account can rent the car by calling the rent() function and determine the lease term. The return date depends on what the item's rental price is and how much time the renter supplies. The calculated return time has to be greater than the minimum rental period and can't exceed the maximum rental period, both set by the owner. (This prevents an item to be rented for a few seconds or for tens of years).

The owner of the contract will need to do some basic setup, which includes:

  Setting the rental price: How much wei per hour it costs to rent the car.
  Minimum rental period: The minimum time (in hour) the renter has to rent the car for.

  Once the car has been setup, any account can call the rent() function providing ether to it. The rental return date will be calculated based on the ether supplied and cost per     hour the owner previously set.

While someone is the current renter of the car, they can call the functions of the contract marked as onlyRenter. At any moment they can call returnRental() to end the rental and get a refund (if applicable) of the time remaining.

If they don't return the car, once the rental return date is reached, they will be unable to keep using the car and the owner can call forceRentalEnd() to remove the car from them and make it available for someone else.
## How to implement it ##
1- Create a contract that inherits from Rentable and import Rentable.sol

2- Decide which function(s) you want to make only callable by the person currently renting the car. (Notice that an car can only be rented by one person at the same time).

3- On each of the functions that you want to restrict usage, add these 2 modifiers: onlyRenter and whenRented.

  onlyRenter will cause the function to require it to be executed by the address currently set as renter.
  whenRented will cause the function to fail if executed outside of the rental period set for the current renter.
  ## Rentable item setup ##
Before the car set as Rentable can be used, there's a few steps that have to be performed.

1- Deploy the contract inheriting from Rentable.

2- Make the car available. As default, the car won't be avalaible for rental. First, you have to define it's price per hour, minimum and maximum rental time by calling            rentableSetup(uint _pricePerHour, uint _minRentalTime, uint _maxRentalTime). Once you call this function, the car will be available for rental.
3- While the car is not rented, you can modify its rental price. There's 2 functions to do so: setRentalPricePerDay(), setRentalPricePerHour(). Use the one that makes more
   sense to you depending the use case. All 2 of them do the same, they set how much wei per second the rental costs.
## How to interact with a Rentable contract ##
Once your Rentable car has been set up, any account can rent it by calling the rent() function or just by sending ether to the contract (and supplying enough gas).

1- The account trying to rent the item executes the rent() function while supplying ether to it. If enough ether was supplied to rent the car within the minimum and maximum        thresholds, then the car gets rented by the account.

2- While the account is the renter of the car, they can execute any function marked as onlyRenter and whenRented.

3- To return the car(and recover any unspent funds) the renter has to call returnRental().
## Other ##
There are two function to decide who is the good person and what is the good car to rent it by add history for the renter and for the car
