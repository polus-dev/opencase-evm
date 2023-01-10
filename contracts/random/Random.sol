// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";

library Random {
    function _randh(uint256 salt) private view returns (uint256) {
        // prettier-ignore
        return uint256(keccak256(abi.encodePacked(
            blockhash(block.number - 1), block.timestamp, msg.sender, salt
        )));
    }

    function random(uint256 salt) internal view returns (uint256) {
        return _randh(salt);
    }

    function cutrnd(uint256 to, uint256 salt) internal view returns (uint256) {
        return _randh(salt) % to;
    }
}
