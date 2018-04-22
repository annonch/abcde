pragma solidity ^0.4.2;


// copyright abcde llc
// author: Christopher Hannon

import "./Future.sol";

contract ClearingHouse {
  Future[256] contracts;
  mapping(uint=>bool) alive;
  
  uint[] contractIDs;

  function newContract(uint _id, Future _f) {
    contracts[_id] = _f;
    alive[_id] = true;
  }
  
  function settle(uint _id) {
    //address contract = contracts[_id];
    require (alive[_id] == true);
    require (contracts[_id].getExpiration() < now);
    int l;
    int s;
    (l, s) = contracts[_id].settle();
    alive[_id] = false;
    contracts[_id].getShort().transfer(uint(s));
    contracts[_id].getLong().transfer(uint(l));
    contracts[_id].finalize();
  }

}

