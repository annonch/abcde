pragma solidity ^0.4.2;


// copyright abcde llc
// author: Christopher Hannon

import "./Quotes.sol";

contract Future {
  //Futures contract
  enum UnderlyingCode {AAPL, GOOG, TSLA}
  enum Position {SHORT, LONG}
  
  uint  id; // contract ID
  uint  expiration; // TODO: need to figure out data type
  
  UnderlyingCode  under; // type of stock
  
  address short; // who has the short position
  address long;  // ''
  int  strikePrice; // (Times 100)
  int currentValue; // of underlying : times 100 to get cents out
  Quotes q;

  event priceChangeEvent(int indexed price);
  event newOwnerEvent(address indexed owner, Position indexed p);

  function getExpiration() public returns(uint exp){
    return expiration;
  }

  function getLong() public returns(address a){
    return long;
  }
  function getShort() public returns(address a){
    return short;
  }

  function Future(uint _id, uint _expiration, address _s, address _l, int _k, Quotes _q) public {
    // this function sets the properties of the contract
    id = _id;
    expiration = _expiration; // block??
    //under = _u;
    short = _s;
    long = _l;
    strikePrice = _k;
    q = _q;
    
    currentValue = UpdateValue();
    
  }

  function EOD() private {
    UpdateValue();

  }

  function settle() public returns(int lval, int sval){
    UpdateValue();
    //payoff function
    lval = currentValue - strikePrice; // x 10000
    sval = -lval;
    return (lval,sval);
  }

  function finalize() {
    selfdestruct(0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE); // hardcoded address 9
  }

  function changeOwner(Position p, address newOwner) {
    if (p == Position.LONG) {
      long = newOwner;
    }else{
      if (p == Position.SHORT) {
	  short = newOwner;
	}
    }
    if (short == long) { finalize(); }
    newOwnerEvent(newOwner, p);
  }
  
  function UpdateValue() private returns(int val) {

    if (under==UnderlyingCode.AAPL) {
      return q.prices(1);
    }

    return 1;
    //priceChangeEvent(newPrice);
  }
  
}

