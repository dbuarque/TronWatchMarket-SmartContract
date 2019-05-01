pragma solidity 0.4.25;

import "./TokenExchangeBatch.sol";
import "../trading/OrderStatus.sol";


contract TokenExchangeDelegate is
  OrderStatus,
  TokenExchangeBatch
{
  function fillDelegate(
    address[] _addresses,
    uint[] _uints,
    bool[] _bools,
    uint8[] _v,
    bytes32[] _rs
  ) external
  {
    _fillDelegate(
      _addresses[_addresses.length - 2],
      _createTakerOrder(_addresses, _uints, _bools),
      _uints[_uints.length - 3],
      _uints[_uints.length - 2],
      _createOffers(_addresses, _uints, _bools),
      _createSignatures(_v, _rs)
    );
  }

  function getTakerHash(
    address[] _addresses,
    uint[] _uints,
    bool[] _bools
  ) external view
    returns (bytes32)
  {
    return _getTakerHash(
      _addresses[_addresses.length - 2],
      _createTakerOrder(_addresses, _uints, _bools),
      _uints[_uints.length - 3],
      _uints[_uints.length - 2],
      _createOffers(_addresses, _uints, _bools)
    );
  }


  function _fillDelegate(
    address _taker,
    TakerOrder memory _takerOrder,
    uint _creationDate,
    uint _expirationDate,
    MakerOffer[] memory _makerOffers,
    Signature[] memory _signatures
  ) internal
  {
    bytes32 takerHash = _getTakerHash(
      _taker,
      _takerOrder,
      _creationDate,
      _expirationDate,
      _makerOffers
    );

    require(
      _getOrderIsValid(
        _taker,
        takerHash,
        _creationDate,
        _expirationDate,
        _signatures[_signatures.length - 1]
      ),
      "INVALID_ORDER"
    );

    _consumeOrder(takerHash);

    _fillBatchOrder(
      _taker,
      _takerOrder,
      _makerOffers,
      _signatures);
  }

  function _getTakerHash(
    address _taker,
    TakerOrder memory _takerOrder,
    uint _creationDate,
    uint _expirationDate,
    MakerOffer[] memory _makerOffers
  ) internal view
    returns (bytes32)
  {
    uint count = _makerOffers.length;
    bytes32[] memory makerHashes = new bytes32[](count);
    for(uint i = 0; i < count; i++)
    {
      makerHashes[i] = _getMakerHash(
        _takerOrder.base,
        _takerOrder.quote,
        !_takerOrder.isTakerBuy,
        _makerOffers[i]
      );
    }
    return keccak256(
      abi.encodePacked(
        address(this),
        _taker,
        _takerOrder.base,
        _takerOrder.quote,
        _takerOrder.isTakerBuy,
        _takerOrder.amount,
        _takerOrder.affiliate,
        _takerOrder.autoWithdraw,
        _creationDate,
        _expirationDate,
        makerHashes
      )
    );
  }
}
