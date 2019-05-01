pragma solidity 0.4.25;


contract TWMToken
{
  uint private tronWatchMarketToken;

  constructor(
    uint _tronWatchMarketToken
  ) internal
  {
    require(_tronWatchMarketToken != 0, "INVALID_TOKEN");
    tronWatchMarketToken = _tronWatchMarketToken;
  }

  function getTronWatchMarketToken(
  ) public view
    returns (uint)
  {
    return tronWatchMarketToken;
  }
}
