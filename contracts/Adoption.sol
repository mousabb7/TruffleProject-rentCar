pragma solidity ^0.5.0;
//
// Permissions
//
//                                      Owner    Renter   Anyone
// Initialize                             x
// Setup                                  x
// Set rental price                       x
// Make available/unavailable             x
// Force rental end (after period)        x
// Call function with onlyRenter                   x
// End rental before return time                   x
// Rent                                                      x

//
contract Adoption {


    // The owner of this car
    address public owner;
     // The account currently renting the car
    address public renter;

    // The date when the latest rental started
    uint public rentalDate;
    // The date when the latest rental is supposed to end
    uint public returnDate;

    // Whether or not the car is currently rented
    bool public rented;

    // The price per second of the rental (in wei)
    uint public rentalPrice;

    //Can not be rented for less time than this.
    //If renter tries to return the car earlier than this time, minimum will be charged anyways
    uint public minRentalTime;
    uint constant MIN_RENTAL_TIME = 60;

    //Can not be rented for longer than this.
    uint public maxRentalTime;
    uint constant MAX_RENTAL_TIME = 3600 * 24 * 365;

    // Whether or not the car can be rented. (Owner can take it off to prevent rental)
    // If its currently rented, making it unavailable doesn't stop it from being used
    bool public available;

    //
    // Events
    //

    event E_Rent(address indexed _renter, uint _rentalDate, uint _returnDate, uint _rentalPrice);
    event E_ReturnRental(address indexed _renter, uint _returnDate);

    //
    // MODIFIERS
    //

    /// allows only the owner to call functions with this modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// allows only the current renter to call functions with this modifier
    modifier onlyRenter() {
        require(msg.sender == renter);
        _;
    }

    /// allows functions with this modifier to be called only when NOT rented
    modifier whenNotRented() {
        require(!rented || now > returnDate);
        _;
    }

    /// allows functions with this modifier to be called only when rented
    modifier whenRented() {
        require(rented && now <= returnDate);
        _;
    }

    /// allows functions with this modifier to be called only when car is available
    modifier ifAvailable() {
        require(available);
        _;
    }

    /////////

    function Rentablee() public {
        owner = msg.sender;
    }

    // sets up the rentable car
    // param _pricePerHour the rental price per hour in wei
    // param _minRentalTime the minimum time the object has to be rented for
    // param _maxRentalTime the maximum time the object has to be rented for
    function rentableSetup(uint _pricePerHour, uint _minRentalTime, uint _maxRentalTime) public onlyOwner {
        require(!available); // Take car down before trying to update
        require(_minRentalTime >= MIN_RENTAL_TIME &&
                _maxRentalTime <= MAX_RENTAL_TIME &&
                _minRentalTime < _maxRentalTime);

        available = true;
        minRentalTime = _minRentalTime;
        maxRentalTime = _maxRentalTime;

        setRentalPricePerHour(_pricePerHour); // _pricePerHour > 0;

    }

    // owner can make the car available/unavailable for rental
    function setAvailable(bool _available) public onlyOwner {
        available = _available;
    }

    function setRentalPricePerHour(uint _pricePerHour) public onlyOwner whenNotRented{
        require(_pricePerHour > 0);
        rentalPrice = _pricePerHour / 3600;
    }

    function setRentalPricePerDay(uint _pricePerDay) public onlyOwner whenNotRented{
        require(_pricePerDay > 0);
        rentalPrice = _pricePerDay / 24 / 3600;
    }

//    function setRentalPricePerSecond(uint _pricePerSecond) public onlyOwner whenNotRented{
  //      require(_pricePerSecond > 0);
    //    rentalPrice = _pricePerSecond;
    //}

    // rents the car for any given time depending money sent and price of car
    function rent() public payable ifAvailable whenNotRented{
        require (msg.value > 0);
        require (rentalPrice > 0);              // Make sure the rental price was set

        uint rentalTime = msg.value / rentalPrice;
        require(rentalTime >= minRentalTime && rentalTime <= maxRentalTime);

        returnDate = now + rentalTime;

        rented = true;
        renter = msg.sender;
        rentalDate = now;

    emit E_Rent(renter, rentalDate, returnDate, rentalPrice);
    }

    // return the elapsed time since the car was rented
    function rentalElapsedTime() public view whenRented returns (uint){
        return now - rentalDate;
    }

    // return the wei owed by the renter given how much time has passed since the rental
    function rentalAccumulatedPrice() public view whenRented returns (uint){
        uint _rentalElapsedTime = rentalElapsedTime();
        return rentalPrice * _rentalElapsedTime;
    }

    function rentalBalanceRemaining() public view whenRented returns (uint){
        return rentalTimeRemaining() * rentalPrice;
    }

    function rentalTimeRemaining() public view whenRented returns (uint){
        return (returnDate - now);
    }

    function rentalTotalTime() public view whenRented returns (uint){
        return (returnDate - rentalDate);
    }


    // can be called by owner of the car if renter doesn't return it.
    function forceRentalEnd() public onlyOwner{
        require(now > returnDate && rented);

        emit E_ReturnRental(renter, now);

        resetRental();
    }

    // the renter can return the car during the rental period and get a refund of the outstanding time
    function returnRental() public onlyRenter whenRented {
        // Calculate rental remaining time and return money to renter
        // If time elapsed is less than the minimum rental time, we charge the minimum
        // Else, we return all pending balance.
        uint fundsToReturn = 0;
        if(rentalElapsedTime() < minRentalTime){
            fundsToReturn = (rentalTotalTime() - minRentalTime) * rentalPrice ;
        }else{
            fundsToReturn = rentalBalanceRemaining();
        }

        emit E_ReturnRental(renter, now);

        resetRental();

        msg.sender.transfer(fundsToReturn);


    }

    // resets the rental variables
    function resetRental() private{
        rented = false;
        renter = address(0);
        rentalDate = 0;
        returnDate = 0;
    }

}
