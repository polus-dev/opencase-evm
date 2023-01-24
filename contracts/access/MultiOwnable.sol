// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract MultiOwnable is Context {
    address private _owner_one;
    mapping(address => bool) private _owners;

    event OwnerAssigned(address indexed owner);
    event OwnerFired(address indexed owner);

    constructor() {
        _owner_one = _msgSender();
        _assignOwner(_msgSender());
    }

    modifier onlyOwner() {
        require(_owners[_msgSender()] == true, "MultiOwnable: not owner");
        _;
    }

    function assignOwner(address account) public virtual onlyOwner {
        require(account != address(0), "MultiOwnable: zero address");
        require(_owners[account] == false, "MultiOwnable: already assigned");

        _assignOwner(account);
    }

    function _assignOwner(address account) internal virtual {
        _owners[account] = true;
        emit OwnerAssigned(account);
    }

    function fireOwner(address account) public virtual onlyOwner {
        require(account != address(0), "MultiOwnable: zero address");
        require(_owners[account] == true, "MultiOwnable: not assigned");

        _fireOwner(account);
    }

    function _fireOwner(address account) internal virtual {
        _owners[account] = false;
        emit OwnerFired(account);
    }


    function setOwnerOne(address account) public virtual onlyOwner {
        require(account != address(0), "MultiOwnable: zero address");
        _owner_one = account;
    }

    function checkOwner(address account) public view virtual returns (bool) {
        return _owners[account];
    }

    function owner() public view virtual returns (address) {
        return _owner_one;
    }
}
