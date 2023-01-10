// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";
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
        address msgsendr;
        uint256 randsalt;
        uint256 blocknum;
        uint256 fxdprice;
    }

    event CaseOpened(address indexed receiver, uint256 randsalt, uint256 out);
    event LateBlock(address indexed receiver, uint256 expfrom, uint256 expto);

    string private _ipfstr; //  ipfs base string "ipfs://{CID}/"
    address private _nftcol; // address of IERC721 NFT collection
    address private _ptoken; // payment IERC20 token address
    address private _receiv; // income receiver address
    uint256 private _sprice; // start case price in _ptoken
    uint256 private _unused; // count of nft coll items
    uint256 private _rndfrm; // start of rand range
    uint256 private _fromts; // start timestamp

    uint256 private constant WAITB = 9; // wait blocks
    uint256 private constant DIFFB = 4; // allowed blocks diff
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

    modifier canBeUsed() {
        require(_fromts > 0, "PolusOpenCase: not started");
        require(_unused > 0, "PolusOpenCase: not unused");
        _;
    }

    function getati(uint256 i) private view returns (uint256) {
        return _shifted[i] != 0 ? _shifted[i] : i;
    }

    function startc() external onlyOwner {
        require(_fromts == 0, "PolusOpenCase: already started");
        _fromts = block.timestamp;
    }

    function stagefrst(address next, bool fwd) external payable canBeUsed {
        if (fwd) payable(next).transfer(msg.value);

        _rndusrs[next] = RndUsrs({
            msgsendr: msg.sender,
            randsalt: Random.random(0),
            blocknum: block.number + WAITB,
            fxdprice: priced()
        });
    }

    function stagescnd() external canBeUsed {
        RndUsrs memory user = _rndusrs[msg.sender];
        require(user.blocknum > 0, "PolusOpenCase: not first");

        uint256 fromblk = user.blocknum;
        uint256 toblk = user.blocknum + DIFFB;

        require(block.number >= fromblk, "PolusOpenCase: too early block");
        if (block.number > toblk) {
            emit LateBlock(user.msgsendr, fromblk, toblk);
            delete _rndusrs[msg.sender];
            return;
        }

        IERC20(_ptoken).safeTransferFrom(
            user.msgsendr,
            _receiv,
            user.fxdprice
        );

        uint256 idx = Random.cutrnd(_rndfrm, _unused, user.randsalt);
        uint256 out = getati(idx);

        _unused -= 1;
        uint256 unused_ = _unused;

        _shifted[idx] = getati(unused_);
        _shifted[unused_] = 0;

        string memory uri = string(
            abi.encodePacked(_ipfstr, Strings.toString(out), ".json")
        );

        IERC721(_nftcol).safeMint(user.msgsendr, out, uri);

        emit CaseOpened(user.msgsendr, user.randsalt, out);
        delete _rndusrs[msg.sender];
    }

    function sicedy() public view returns(uint256) {
        return (block.timestamp - _fromts) / DAY;
    }

    function percnt() public view returns(uint256) {
        uint256 sincedy = sicedy();
        return sincedy >= (MTARG / MSTEP) ? MTARG : sincedy * MSTEP;
    }

    function priced() public view returns (uint256) {
        return _sprice + ((_sprice * percnt()) / 10_000);
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

    function diffblk() external pure returns (uint256) {
        return DIFFB; // allowed blocks diff
    }

    function margins() external pure returns (uint256) {
        return MSTEP; // margin step
    }

    function margint() external pure returns (uint256) {
        return MTARG; // margin target
    }
}
