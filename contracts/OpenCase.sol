// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./random/Random.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IERC721 {
    function safeMint(address to, uint256 tokenId, string memory uri) external;
}

contract PolusOpenCase is Ownable {
    using SafeERC20 for IERC20;

    struct RndUsrs {
        uint256 randsalt;
        uint256 blocknum;
        uint256 fxdprice;
    }

    event CaseOpened(address indexed receiver, uint256 randsalt, uint256 out);

    event CaseOpenedAtLateBlock(
        address indexed receiver,
        uint256 expected,
        uint256 got
    );

    string private _ipfstr; //  ipfs base string "ipfs://{CID}/"
    address private _nftcol; // address of IERC721 NFT collection
    address private _ptoken; // payment IERC20 token address
    address private _receiv; // income receiver address
    uint256 private _sprice; // start case price in _ptoken
    uint256 private _unused; // count of nft coll items
    uint256 private _rndfrm; // start of rand range
    uint256 private _fromts; // start timestamp

    uint256 private constant WAITB = 2; // wait blocks
    uint256 private constant MSTEP = 500; //  5%
    uint256 private constant MTARG = 2500; // 25%
    uint256 private constant DAY = 1 days;

    mapping(uint256 => uint256) private _shifted;
    mapping(address => RndUsrs) private _rndusrs;

    constructor(
        string memory ipfstr_,
        address nftcol_,
        address ptoken_,
        address receiv_,
        uint256 sprice_,
        uint256 unused_,
        uint256 rndfrm_
    ) {
        _ipfstr = ipfstr_;
        _nftcol = nftcol_;
        _ptoken = ptoken_;
        _receiv = receiv_;
        _sprice = sprice_;
        _unused = unused_;
        _rndfrm = rndfrm_;
    }

    function getati(uint256 i) private view returns (uint256) {
        return _shifted[i] != 0 ? _shifted[i] : i;
    }

    function startc() external onlyOwner {
        require(_fromts == 0, "PolusOpenCase: already started");
        _fromts = block.timestamp;
    }

    function realcs() private {
        RndUsrs memory user = _rndusrs[msg.sender];
        IERC20(_ptoken).safeTransferFrom(msg.sender, _receiv, user.fxdprice);

        uint256 idx = Random.cutrnd(_rndfrm, _unused, user.randsalt);
        uint256 out = getati(idx);

        _unused -= 1;
        uint256 unused_ = _unused;

        _shifted[idx] = getati(unused_);
        _shifted[unused_] = 0;

        string memory uri = string(
            abi.encodePacked(_ipfstr, Strings.toString(out), ".json")
        );

        IERC721(_nftcol).safeMint(msg.sender, out, uri);

        emit CaseOpened(msg.sender, user.randsalt, out);
        delete _rndusrs[msg.sender];
    }

    function opencs() external {
        require(_fromts > 0, "PolusOpenCase: not started");
        require(_unused > 0, "PolusOpenCase: not unused");

        uint256 expectedblk = _rndusrs[msg.sender].blocknum;

        if (expectedblk == 0) {
            _rndusrs[msg.sender] = RndUsrs(
                Random.random(0),
                block.number + WAITB,
                priced()
            );

            return;
        }

        require(block.number > expectedblk, "PolusOpenCase: too early block");

        if (block.number > expectedblk) {
            emit CaseOpenedAtLateBlock(msg.sender, expectedblk, block.number);
            delete _rndusrs[msg.sender];
            return;
        }

        realcs();
    }

    function priced() internal view returns (uint256) {
        uint256 sincedy = (block.timestamp - _fromts) / DAY;
        uint256 percent = sincedy >= (MTARG / MSTEP) ? MTARG : sincedy * MSTEP;

        return _sprice + ((_sprice * percent) / 10_000);
    }

    function ipfstr() external view returns (string memory) {
        return _ipfstr;
    }

    function nftcol() external view returns (address) {
        return _nftcol;
    }

    function ptoken() external view returns (address) {
        return _ptoken;
    }

    function receiv() external view returns (address) {
        return _receiv;
    }

    function sprice() external view returns (uint256) {
        return _sprice;
    }

    function unused() external view returns (uint256) {
        return _unused;
    }

    function rndfrm() external view returns (uint256) {
        return _rndfrm;
    }

    function fromts() external view returns (uint256) {
        return _fromts;
    }

    function shifted(uint256 idx) external view returns (uint256) {
        return _shifted[idx];
    }

    function rndusrs(address user) external view returns (RndUsrs memory) {
        return _rndusrs[user];
    }

    function waitblk() external pure returns (uint256) {
        return WAITB; // wait blocks
    }

    function margins() external pure returns (uint256) {
        return MSTEP; // margin step
    }

    function margint() external pure returns (uint256) {
        return MTARG; // margin target
    }
}
