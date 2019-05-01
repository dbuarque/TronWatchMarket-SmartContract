pragma solidity 0.4.25;

import "../general/LibSignature.sol";
import "../trading/OfferStatus.sol";
import "../general/UintSafeMath.sol";
import "../general/UintMath.sol";


contract AbstractExchange is
  LibSignature,
  OfferStatus
{
  using UintSafeMath for uint;
  using UintMath for uint;

  struct MakerOffer
  {
    address maker;
    address affiliate;
    uint amount;
    uint rateNumerator;
    uint rateDenominator;
    uint creationDate;
    uint expirationDate;
    bool autoWithdraw;
  }

  function _calcTradeQuantity(
    MakerOffer memory _makerOffer,
    bool _isTakerBuy,
    bytes32 _makerHash,
    uint _makerAvailableBalance,
    uint _takerAmount,
    uint _takerAvailableBalance
  ) internal view
    returns (uint baseAmount, uint quoteAmount)
  {
    baseAmount = _getOfferAmountRemaining(
      _makerHash,
      _makerOffer.maker,
      _makerOffer.amount,
      _makerOffer.creationDate,
      _makerOffer.expirationDate
    ).min(
      _takerAmount,
      _isTakerBuy ? _makerAvailableBalance : _takerAvailableBalance
    );

    quoteAmount =
      (
        baseAmount.mul(_makerOffer.rateNumerator) / _makerOffer.rateDenominator
      ).min(_isTakerBuy ? _takerAvailableBalance : _makerAvailableBalance);

    baseAmount = quoteAmount
      .mul(_makerOffer.rateDenominator)
      / _makerOffer.rateNumerator;

    quoteAmount = baseAmount
      .mul(_makerOffer.rateNumerator)
      / _makerOffer.rateDenominator;

    return (baseAmount, quoteAmount);
  }

  function _getRemaining(
    MakerOffer memory _makerOffer,
    bool _isMakerBuy,
    bytes32 _makerHash,
    Signature memory _signature,
    uint _makerAvailableBalance
  ) internal view
    validSignature(_makerHash, _signature, _makerOffer.maker)
    returns (uint maxBaseAmount, uint maxQuoteAmount)
  {
    maxBaseAmount = _getOfferAmountRemaining(
      _makerHash,
      _makerOffer.maker,
      _makerOffer.amount,
      _makerOffer.creationDate,
      _makerOffer.expirationDate
    );

    if(_isMakerBuy)
    {
      maxQuoteAmount = maxBaseAmount
        .mul(_makerOffer.rateNumerator)
        / _makerOffer.rateDenominator;

      maxQuoteAmount = maxQuoteAmount.min(_makerAvailableBalance);
    }
    else
    {
      maxBaseAmount = maxBaseAmount.min(_makerAvailableBalance);

      maxQuoteAmount = maxBaseAmount
        .mul(_makerOffer.rateNumerator)
        / _makerOffer.rateDenominator;
    }

    maxBaseAmount = maxQuoteAmount
      .mul(_makerOffer.rateDenominator)
      / _makerOffer.rateNumerator;

    maxQuoteAmount = maxBaseAmount
      .mul(_makerOffer.rateNumerator)
      / _makerOffer.rateDenominator;

    return (maxBaseAmount, maxQuoteAmount);
  }


  function _getRemainingWithoutBalance(
    MakerOffer memory _makerOffer,
    bytes32 _makerHash,
    Signature memory _signature
  ) internal view
    validSignature(_makerHash, _signature, _makerOffer.maker)
    returns (uint maxBaseAmount, uint maxQuoteAmount)
  {
    maxBaseAmount = _getOfferAmountRemaining(
      _makerHash,
      _makerOffer.maker,
      _makerOffer.amount,
      _makerOffer.creationDate,
      _makerOffer.expirationDate
    );

    maxQuoteAmount = maxBaseAmount
      .mul(_makerOffer.rateNumerator)
      / _makerOffer.rateDenominator;

    maxBaseAmount = maxQuoteAmount
      .mul(_makerOffer.rateDenominator)
      / _makerOffer.rateNumerator;

    maxQuoteAmount = maxBaseAmount
      .mul(_makerOffer.rateNumerator)
      / _makerOffer.rateDenominator;

    return (maxBaseAmount, maxQuoteAmount);
  }
}
