pragma solidity 0.4.25;

import "../general/Ownable.sol";
import "../trading/Bank.sol";
import "../trading/TradingFees.sol";


contract TokenExchange is
  Ownable,
  Bank,
  TradingFees
{
  event Fill(
    bytes32 indexed makerHash,
    address indexed maker,
    address indexed taker,
    uint base,
    uint quote,
    bool isTakerBuy,
    uint baseAmount,
    uint baseFee,
    uint quoteAmount,
    uint quoteFee
  );

  event PayAffiliate(
    bytes32 indexed makerHash,
    address indexed affiliate,
    address indexed trader,
    uint token,
    uint affiliateFee
  );

  struct TakerOrder
  {
    uint base;
    uint quote;
    uint amount;
    address affiliate;
    bool isTakerBuy;
    bool autoWithdraw;
  }

  function getMakerHash(
    address _maker,
    bool _isMakerBuy,
    address _makerAffiliate,
    uint[7] _uints,
    bool _autoWithdraw
  ) external view
    returns (bytes32)
  {
    require(_maker != address(0), "INVALID_ADDRESS");

    return _getMakerHash(
      _uints[0],
      _uints[1],
      _isMakerBuy,
      MakerOffer(
        _maker,
        _makerAffiliate,
        _uints[2],
        _uints[3],
        _uints[4],
        _uints[5],
        _uints[6],
        _autoWithdraw
      )
    );
  }

  function getRemaining(
    address[2] _addresses,
    uint[7] _uints,
    bool[2] _bools,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external view
    returns (uint maxBaseAmount, uint maxQuoteAmount)
  {
    MakerOffer memory makerOffer = MakerOffer(
      _addresses[0],
      _addresses[1],
      _uints[2],
      _uints[3],
      _uints[4],
      _uints[5],
      _uints[6],
      _bools[1]
    );
    return _getRemaining(
      makerOffer,
      _bools[0],
      _getMakerHash(
        _uints[0],
        _uints[1],
        _bools[0],
        makerOffer
      ),
      Signature(_v, _r, _s),
      getAvailableBalanceOf(
        _uints[_bools[0] ? 1 : 0],
        makerOffer.maker
      )
    );
  }

  function getRemainingWithoutBalance(
    address[2] _addresses,
    uint[7] _uints,
    bool[2] _bools,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external view
    returns (uint maxBaseAmount, uint maxQuoteAmount)
  {
    MakerOffer memory makerOffer = MakerOffer(
      _addresses[0],
      _addresses[1],
      _uints[2],
      _uints[3],
      _uints[4],
      _uints[5],
      _uints[6],
      _bools[1]
    );
    return _getRemainingWithoutBalance(
      makerOffer,
      _getMakerHash(
        _uints[0],
        _uints[1],
        _bools[0],
        makerOffer
      ),
      Signature(_v, _r, _s)
    );
  }

  function _fillSingleOrder(
    address _taker,
    TakerOrder memory _takerOrder,
    MakerOffer memory _makerOffer,
    Signature memory _signature
  ) internal
    returns (uint)
  {
    require(_taker != _makerOffer.maker, "NO_TRADING_WITH_SELF");

    bytes32 makerHash = _getMakerHash(
      _takerOrder.base,
      _takerOrder.quote,
      !_takerOrder.isTakerBuy,
      _makerOffer);

    require(
      _isValidSignature(makerHash, _signature, _makerOffer.maker),
      "INVALID_SIGNATURE"
    );

    uint makerBalanceThenBaseAmount;
    uint takerBalanceThenQuoteAmount;

    if(_takerOrder.isTakerBuy)
    {
      makerBalanceThenBaseAmount = getAvailableBalanceOf(
        _takerOrder.base,
        _makerOffer.maker
      );
      takerBalanceThenQuoteAmount = getAvailableBalanceOf(_takerOrder.quote, _taker);
    }
    else
    {
      makerBalanceThenBaseAmount = getAvailableBalanceOf(
        _takerOrder.quote,
        _makerOffer.maker
      );
      takerBalanceThenQuoteAmount = getAvailableBalanceOf(_takerOrder.base, _taker);
    }

    (makerBalanceThenBaseAmount, takerBalanceThenQuoteAmount) =
      _calcTradeQuantity(
        _makerOffer,
        _takerOrder.isTakerBuy,
        makerHash,
        makerBalanceThenBaseAmount,
        _takerOrder.amount,
        takerBalanceThenQuoteAmount
      );

    _consumeOffer(makerHash, makerBalanceThenBaseAmount);

    if(makerBalanceThenBaseAmount > 0)
    {
      uint quoteFee = _transferTokenForTrade(
        _taker,
        _takerOrder,
        _makerOffer,
        makerHash,
        false,
        takerBalanceThenQuoteAmount
      );
      uint baseFee = _transferTokenForTrade(
        _taker,
        _takerOrder,
        _makerOffer,
        makerHash,
        true,
        makerBalanceThenBaseAmount
      );

      emit Fill(
        makerHash,
        _makerOffer.maker,
        _taker,
        _takerOrder.base,
        _takerOrder.quote,
        _takerOrder.isTakerBuy,
        makerBalanceThenBaseAmount,
        baseFee,
        takerBalanceThenQuoteAmount,
        quoteFee
      );
    }

    return makerBalanceThenBaseAmount;
  }

  function _getMakerHash(
    uint _base,
    uint _quote,
    bool _isBuy,
    MakerOffer memory _makerOffer
  ) internal view
    returns (bytes32)
  {
    return keccak256(
      abi.encodePacked(
        address(this),
        _base,
        _quote,
        _isBuy,
        _makerOffer.maker,
        _makerOffer.amount,
        _makerOffer.rateNumerator,
        _makerOffer.rateDenominator,
        _makerOffer.creationDate,
        _makerOffer.expirationDate,
        _makerOffer.affiliate,
        _makerOffer.autoWithdraw
      )
    );
  }

  function _transferTokenForTrade(
    address _taker,
    TakerOrder memory _takerOrder,
    MakerOffer memory _makerOffer,
    bytes32 _makerHash,
    bool _sendBase,
    uint _amount
  ) private
    returns (uint)
  {
    uint token = _sendBase ? _takerOrder.base : _takerOrder.quote;
    address from;
    address to;

    address affiliate;
    bool autoWithdraw;
    bool isMaker;
    if(_sendBase == _takerOrder.isTakerBuy)
    {
      from = _makerOffer.maker;
      to = _taker;
      affiliate = _takerOrder.affiliate;
      autoWithdraw = _takerOrder.autoWithdraw;
      isMaker = false;
    }
    else
    {
      from = _taker;
      to = _makerOffer.maker;
      affiliate = _makerOffer.affiliate;
      autoWithdraw = _makerOffer.autoWithdraw;
      isMaker = true;
    }

    uint houseFee;
    uint affiliateFee;

    if(from != getOwner() && to != getOwner())
    {
      (houseFee, affiliateFee) = calcTradingFees(
        _takerOrder.base,
        _takerOrder.quote,
        isMaker,
        from,
        affiliate,
        _amount
      );
    }

    _fillTrade(
      from,
      to,
      token,
      _amount,
      autoWithdraw,
      houseFee,
      affiliate,
      affiliateFee
    );

    if(affiliateFee > 0)
    {
      emit PayAffiliate(
        _makerHash,
        affiliate,
        isMaker ? _makerOffer.maker : _taker,
        token,
        affiliateFee
      );
    }

    return houseFee + affiliateFee;
  }
}
