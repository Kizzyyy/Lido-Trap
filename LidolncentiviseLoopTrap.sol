// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

interface IERC20Minimal {
    function totalSupply() external view returns (uint256);
}

/// @title LidoIncentiveLoopTrap
/// @notice Monitors Lido stETH supply growth and signals Drosera when rewards increase.
///         When total supply increases, it encodes 1% of the delta as the incentive payload.
contract LidoIncentiveLoopTrap is ITrap {
    // Hoodi testnet stETH token address (represents Lido rewards)
    address public constant STETH_TOKEN = 0x3508A952176b3c15387C97BE809eaffB1982176a;

    /// @notice Collects the latest supply data for sampling.
    function collect() external view override returns (bytes memory) {
        uint256 supply = IERC20Minimal(STETH_TOKEN).totalSupply();
        return abi.encode(block.number, supply);
    }

    /// @notice Compares recent samples to detect growth in supply.
    /// @dev Returns (true, encodedAmount) if supply grew since last sample.
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, bytes(""));

        (uint256 bnPrev, uint256 prevSupply) = abi.decode(data[data.length - 2], (uint256, uint256));
        (uint256 bnLast, uint256 lastSupply) = abi.decode(data[data.length - 1], (uint256, uint256));

        if (bnLast <= bnPrev || lastSupply <= prevSupply) return (false, bytes(""));

        uint256 delta = lastSupply - prevSupply;
        uint256 incentive = delta / 100; // 1% of increase
        if (incentive == 0) return (false, bytes(""));

        return (true, abi.encode(incentive));
    }
}

trap contract