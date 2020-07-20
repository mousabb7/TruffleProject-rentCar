pragma solidity ^0.5.0;
import "./Adoption.sol";
import "./carhis.sol";

contract Car is Adoption {

    string public Type;
    string public size;
    uint public duration;
    uint public timesdriv;

    function Carr(string memory _Type, string memory _size, uint _duration) public {
        Type = _Type;
        size = _size;
        duration = _duration;
        timesdriv = 0;
    }

    function Drivecar() public onlyRenter whenRented returns(bool){
        timesdriv++;
        return true;
    }
}