pragma solidity 0.4.25;

import "../general/UintSafeMath.sol";


contract TradingFeeDiscount
{
  event PurchaseTradingFeeDiscount(
    address indexed account,
    uint tier
  );

  uint[6] private tradingFeeCosts     = [0, 10, 50, 250, 1000, 5000];
  uint[6] private tradingFeeDiscounts = [0, 5, 10, 25, 50, 100];

  mapping(address => uint) private accountToDiscountTier;

  function getTradingFeeCost(
    uint _tier
  ) external view
    returns (uint)
  {
    return tradingFeeCosts[_tier];
  }

  function getTradingFeeDiscountForTier(
    uint _tier
  ) external view
    returns (uint)
  {
    return tradingFeeDiscounts[_tier];
  }

  function getTradingFeeDiscountTier(
    address _account
  ) public view
    returns (uint)
  {
    return accountToDiscountTier[_account];
  }

  function getCostToPurchaseTradingFeeDiscount(
    address _account,
    uint _desiredTier
  ) public view
    returns (uint)
  {
    require(_desiredTier > accountToDiscountTier[_account], "MUST_UPGRADE_TIER");

    return tradingFeeCosts[_desiredTier]
      - tradingFeeCosts[accountToDiscountTier[_account]];
  }

  function getTradingFeeDiscountInPercent(
    address _account
  ) public view
    returns (uint)
  {
    return tradingFeeDiscounts[accountToDiscountTier[_account]];
  }

  function _purchaseTradingFeeDiscount(
    address _account,
    uint _desiredTier
  ) internal
  {
    accountToDiscountTier[_account] = _desiredTier;
    emit PurchaseTradingFeeDiscount(_account, _desiredTier);
  }

  function _applyTradingFeeDiscount(
    address _account,
    uint _fee
  ) internal view
    returns (uint)
  {
    return _fee - _fee * getTradingFeeDiscountInPercent(_account) / 100;
  }
}