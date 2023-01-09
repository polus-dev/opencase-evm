// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract MultiOwnable is Context {
    mapping(address => bool) private _owners;

    event OwnerAssigned(address indexed owner);
    event OwnerFired(address indexed owner);

    constructor() {
        _assignOwner(_msgSender());
    }

    modifier onlyOwner() {
        require(_owners[_msgSender()] == true, "MultiOwnable: not owner");
        _;
    }

    function assignOwner(address owner) public virtual onlyOwner {
        require(owner != address(0), "MultiOwnable: zero address");
        require(_owners[owner] == false, "MultiOwnable: already assigned");

        _assignOwner(owner);
    }

    function _assignOwner(address owner) internal virtual {
        _owners[owner] = true;
        emit OwnerAssigned(owner);
    }

    function fireOwner(address owner) public virtual onlyOwner {
        require(owner != address(0), "MultiOwnable: zero address");
        require(_owners[owner] == true, "MultiOwnable: not assigned");

        _fireOwner(owner);
    }

    function _fireOwner(address owner) internal virtual {
        _owners[owner] = false;
        emit OwnerFired(owner);
    }

    function checkOwner(address owner) public view virtual returns (bool) {
        return _owners[owner];
    }
}
