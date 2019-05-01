pragma solidity 0.4.25;

import "./shared/exchange/TokenExchangeDelegate.sol";
import "./shared/trading/TradingFeeDiscountTrc10.sol";


contract TronWatchMarketExchange is
  TradingFeeDiscountTrc10,
  TokenExchangeDelegate
{
  constructor(
    uint _tronWatchMarketToken
  ) public
    TWMToken(_tronWatchMarketToken)
  {
  }
}