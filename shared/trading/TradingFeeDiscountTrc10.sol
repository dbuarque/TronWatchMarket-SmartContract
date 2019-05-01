pragma solidity 0.4.25;

import "../general/Ownable.sol";
import "./TradingFeeDiscount.sol";
import "./Bank.sol";
import "../token/TWMToken.sol";


contract TradingFeeDiscountTrc10 is
  Ownable,
  Bank,
  TradingFeeDiscount,
  TWMToken
{
  event PayAffiliateForDiscount(
    address indexed affiliate,
    uint affiliateFee
  );

  function purchaseTradingFeeDiscount(
    address _account,
    uint _desiredTier,
    address _affiliate
  ) external payable
  {
    deposit();
    uint fee = getCostToPurchaseTradingFeeDiscount(_account, _desiredTier);
    _purchaseTradingFeeDiscount(_account, _desiredTier);
    if(getOwner() != address(0))
    {
      uint houseFee = fee / 2;
      fee = fee - houseFee;
      if(_affiliate != address(0))
      {
        uint affiliateFee = (houseFee + 1) / 2;
        houseFee -= affiliateFee;
        _transferTrc10(msg.sender, _affiliate, getTronWatchMarketToken(), affiliateFee, false);
        emit PayAffiliateForDiscount(_affiliate, affiliateFee);
      }
      _transferTrc10(msg.sender, getOwner(), getTronWatchMarketToken(), houseFee, false);
    }
    _burnTrc10(msg.sender, getTronWatchMarketToken(), fee);
  }
}