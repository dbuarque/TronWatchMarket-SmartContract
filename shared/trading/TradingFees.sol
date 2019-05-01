pragma solidity 0.4.25;

import "./TradingFeeDiscount.sol";
import "../general/Ownable.sol";


contract TradingFees is
  Ownable,
  TradingFeeDiscount
{
  event SetTradingFeeDenominators(
    uint makerFeeDenominator,
    uint takerFeeDenominator
  );
  event SetTradingFeeDenominatorsForQuote(
    uint indexed quote,
    uint makerFeeDenominator,
    uint takerFeeDenominator
  );
  event SetTradingFeeDenominatorsForPair(
    uint indexed base,
    uint indexed quote,
    uint makerFeeDenominator,
    uint takerFeeDenominator
  );

  uint public constant DEFAULT_MAKER_FEE_DENOMINATOR = 4000;
  uint public constant DEFAULT_TAKER_FEE_DENOMINATOR = 1000;

  uint private makerTradingFeeDenominator = DEFAULT_MAKER_FEE_DENOMINATOR;
  uint private takerTradingFeeDenominator = DEFAULT_TAKER_FEE_DENOMINATOR;
  mapping(uint => mapping(bool => uint)) private quoteToIsMakerToFeeDenominator;
  mapping(
    uint => mapping(uint => mapping(bool => uint))
  ) private baseToQuoteToIsMakerToFeeDenominator;

  function setTradingFeeDenominators(
    uint _makerFeeDenominator,
    uint _takerFeeDenominator
  ) external
    onlyOwner
    isValidPrice(_makerFeeDenominator, _takerFeeDenominator)
  {
    makerTradingFeeDenominator = _makerFeeDenominator;
    takerTradingFeeDenominator = _takerFeeDenominator;

    emit SetTradingFeeDenominators(_makerFeeDenominator, _takerFeeDenominator);
  }

  function setTradingFeeDenominatorsForQuote(
    uint _quote,
    uint _makerFeeDenominator,
    uint _takerFeeDenominator
  ) external
    onlyOwner
    isValidPrice(_makerFeeDenominator, _takerFeeDenominator)
  {
    quoteToIsMakerToFeeDenominator[_quote][true] = _makerFeeDenominator;
    quoteToIsMakerToFeeDenominator[_quote][false] = _takerFeeDenominator;

    emit SetTradingFeeDenominatorsForQuote(
      _quote,
      _makerFeeDenominator,
      _takerFeeDenominator
    );
  }

  function setTradingFeeDenominatorsForPair(
    uint _base,
    uint _quote,
    uint _makerFeeDenominator,
    uint _takerFeeDenominator
  ) external
    onlyOwner
    isValidPrice(_makerFeeDenominator, _takerFeeDenominator)
  {
    baseToQuoteToIsMakerToFeeDenominator[_base][_quote][true]
      = _makerFeeDenominator;
    baseToQuoteToIsMakerToFeeDenominator[_base][_quote][false]
      = _takerFeeDenominator;

    emit SetTradingFeeDenominatorsForPair(
      _base,
      _quote,
      _makerFeeDenominator,
      _takerFeeDenominator
    );
  }

  function getTradingFeeForPair(
    uint _base,
    uint _quote
  ) external view
    returns (uint, uint)
  {
    return (
      _getFeeDenominator(_base, _quote, true),
      _getFeeDenominator(_base, _quote, false)
    );
  }

  function calcTradingFees(
    uint _base,
    uint _quote,
    bool _isMaker,
    address _account,
    address _affiliate,
    uint _tradeAmount
  ) public view
    returns (uint houseFee, uint affiliateFee)
  {
    uint fee = _applyTradingFeeDiscount(
      _account,
      _tradeAmount / _getFeeDenominator(_base, _quote, _isMaker)
    );
    if(_affiliate != address(0) && _account != _affiliate)
    {
      if(getOwner() != address(0))
      {
        affiliateFee = (fee + 1) / 2;
        houseFee = fee - affiliateFee;
      }
      else
      {
        affiliateFee = fee;
      }
    }
    else if(getOwner() != address(0))
    {
      houseFee = fee;
    }
  }

  modifier isValidPrice(
    uint _makerFeeDenominator,
    uint _takerFeeDenominator
  )
  {
    require(
      _makerFeeDenominator >= DEFAULT_MAKER_FEE_DENOMINATOR
      && _takerFeeDenominator >= DEFAULT_TAKER_FEE_DENOMINATOR, "NO_PRICE_HIKES");
    _;
  }


  function _getFeeDenominator(
    uint _base,
    uint _quote,
    bool _isMaker
  ) private view
    returns (uint)
  {
    if(baseToQuoteToIsMakerToFeeDenominator[_base][_quote][_isMaker] != 0)
    {
      return baseToQuoteToIsMakerToFeeDenominator[_base][_quote][_isMaker];
    }
    else if(quoteToIsMakerToFeeDenominator[_quote][_isMaker] != 0)
    {
      return quoteToIsMakerToFeeDenominator[_quote][_isMaker];
    }
    else if(_isMaker)
    {
      return makerTradingFeeDenominator;
    }
    else
    {
      return takerTradingFeeDenominator;
    }
  }
}