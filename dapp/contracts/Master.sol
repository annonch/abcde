pragma solidity ^0.4.2;


// copyright abcde llc
// author: Christopher Hannon

import "./Quotes.sol";
import "./Future.sol";
import "./OrderMatching.sol";
import "./ClearingHouse.sol";

contract Master {
  Quotes public c_q;
  OrderMatching public c_om;
  Future[256] public c_f;
  ClearingHouse public c_ch;
  
  uint futuresId = 0;
  uint version = 1;
  address short;
  address long;

  uint public matched = 0;
  int public AAPL_q;

  enum UnderlyingCode {AAPL, GOOG, TSLA}

  event matchedEvent();
  
  function Master() {
    c_q = new Quotes();
    getAAPLQuote();
    c_om = new OrderMatching();
    c_ch = new ClearingHouse();
  }
  
  function Match(bool _short) public payable {
    require (msg.value >= uint(AAPL_q) / 5); // margin requ
    
    if (_short) {
      short = msg.sender; //int status = c_om.match(short)
      matched = matched + 1;
    }
    else {
      long = msg.sender;
      matched = matched + 1;
    }
    if (matched == 2) {
      c_f[futuresId] = new Future(futuresId,100, short, long, AAPL_q, c_q);
      matchedEvent();
      //function Future(uint _id, uint _expiration, UnderlyingCode _u, address _s, address _l, int _k, Quotes _q) public {
    }
  }
    
  function getAAPLQuote(){
    int _v = c_q.getPrices(1);
    AAPL_q = _v*10000;
  }
}


