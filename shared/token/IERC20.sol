pragma solidity 0.4.25;


interface IERC20
{
  function transfer(
    address to,
    uint value
  ) external
    returns (bool);

  function transferFrom(
    address from,
    address to,
    uint value
  ) external
    returns (bool);

  function allowance(
    address owner,
    address spender
  ) external view
    returns (uint);

  function balanceOf(
    address who
  ) external view
    returns (uint);
}
