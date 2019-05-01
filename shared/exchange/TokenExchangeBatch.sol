pragma solidity 0.4.25;

import "./TokenExchange.sol";


contract TokenExchangeBatch is
  TokenExchange
{
  function fill(
    address[] _addresses,
    uint[] _uints,
    bool[] _bools,
    uint8[] _v,
    bytes32[] _rs
  ) external payable
  {
    deposit();

    _fillBatchOrder(
      msg.sender,
      _createTakerOrder(_addresses, _uints, _bools),
      _createOffers(_addresses, _uints, _bools),
      _createSignatures(_v, _rs)
    );
  }

  function _fillBatchOrder(
    address _taker,
    TakerOrder memory _takerOrder,
    MakerOffer[] memory _makerOffer,
    Signature[] memory _signature
  ) internal
  {
    uint count = _makerOffer.length;
    for(uint i = 0; _takerOrder.amount > 0 && i < count; i++)
    {
      _takerOrder.amount -= _fillSingleOrder(
        _taker,
        _takerOrder,
        _makerOffer[i],
        _signature[i]
      );
    }
  }

  function _createOffers(
    address[] memory _addresses,
    uint[] memory _uints,
    bool[] memory _bools
  ) internal pure
    returns (MakerOffer[] memory)
  {
    uint count = (_addresses.length - 1) / 2;
    MakerOffer[] memory offers = new MakerOffer[](count);

    for(uint i = 0; i < count; i++)
    {
      uint i5 = i * 5;

      offers[i] = MakerOffer(
        _addresses[i * 2],
        _addresses[1 + i * 2],
        _uints[2 + i5],
        _uints[3 + i5],
        _uints[4 + i5],
        _uints[5 + i5],
        _uints[6 + i5],
        _bools[2 + i]
      );
    }

    return offers;
  }

  function _createTakerOrder(
    address[] memory _addresses,
    uint[] memory _uints,
    bool[] memory _bools
  ) internal pure
    returns (TakerOrder memory)
  {
    return TakerOrder(
      _uints[0],
      _uints[1],
      _uints[_uints.length - 1],
      _addresses[_addresses.length - 1],
      _bools[0],
      _bools[1]
    );
  }
}
