pragma solidity ^0.4.2;


// copyright abcde llc
// author: Christopher Hannon

import "./usingOracleize.sol";    //\\"github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "./strings.sol";           //github.com/Arachnid/solidity-stringutils/strings.sol";

contract Quotes is usingOraclize{

  //slicing utilities
  using strings for *;
  
  enum UnderlyingCode {AAPL, GOOG, TSLA, FB}

  mapping(uint=>int) public prices;
  mapping(bytes32=>uint) private queries;
  uint public queryCount = 1;
  string public AAPLprices;
  
  event LogPriceUpdated(string price);
  event LogNewOraclizeQuery(string description);

  function getPrices(uint _id) returns(int price){
    return prices[_id];
  }

  function Quotes() {
    //OAR = OraclizeAddrResolverI(0xC2f02cADd6d964C79dbd80397CAA919ba3c14793);
    OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
    //OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

    updatePrices(1,UnderlyingCode.AAPL);
    //updatePrices(1,GOOG);
  }
  
  function __callback(bytes32 myid, string result, bytes proof) {
    require(msg.sender == oraclize_cbAddress());

    if (queries[myid] == 1){
      //parse and update AAPL
      var s = result.toSlice();
      prices[1] = int(stringToUint(s.split(".".toSlice()).toString())*100); // get the first part
      uint x = stringToUint(s.toString()); // get the second part 
      prices[1] = prices[1] + int(x) ;
      LogPriceUpdated(result);
      AAPLprices=result;
      //updatePrices(60, UnderlyingCode.AAPL); // once per min
    } else{
      //different query
    }
  }   

  function updatePrices(uint time, UnderlyingCode code) payable {
    if (oraclize_getPrice("URL") > this.balance) {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    } else {
      LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
      //oraclize_query("URL", "json(http://api.fixer.io/latest?symbols=USD,GBP).rates.GBP");                     
      if (code == UnderlyingCode.AAPL){
	//queries[oraclize_query(time,"URL" ,'json(https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=AAPL&interval=1min&apikey=6HBJU7XXQ5LHA1G4."Time Series (1min)"."2018-04-20 16:00:00"."4. close")')] = 1;
	queries[oraclize_query(time, "URL", "https://eodhistoricaldata.com/api/eod/AAPL.US?api_token=OeAFFmMliFG5orCUuwAKQ8l4WWFQ67YX&fmt=json&filter=last_close")] = 1;
      }
    }
  }

  function stringToUint(string s) constant returns (uint) {
    bytes memory b = bytes(s);
    uint result = 0;
    for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
        if (b[i] >= 48 && b[i] <= 57) {
            result = result * 10 + (uint(b[i]) - 48); // bytes and int are not compatible with the operator -.
        }
    }
    return result; // 
  }
}
