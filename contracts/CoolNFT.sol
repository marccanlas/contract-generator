// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "erc721a/contracts/ERC721A.sol";

contract CoolNFT is Ownable, ERC721A, PaymentSplitter {

    using Strings for uint;

    // enum Step {
    //     NotStarted,
    //     WhitelistSale,
    //     PublicSale,
    //     SoldOut
    // }

    string public baseURI;

    bool public revealed = false;

    // Step public sellingStep;

    uint public maxSupply;
    uint public maxWhitelist;
    uint public wlMintLimit;

    uint public wlSalePrice;
    uint public publicSalePrice;

    bytes32 public merkleRoot;

    uint public saleStartTime;

    mapping(address => uint) public amountNFTsperWalletWhitelistSale;

    uint private teamLength;

    event mint(address);
    event widthrawToWallet(address);

    constructor(address[] memory _team, 
        uint[] memory _teamShares, 
        bytes32 _merkleRoot, 
        string memory _baseURI,
        uint _maxSupply,
        uint _maxWhitelist,
        uint _wlMintLimit,
        uint _saleStartTime,
        uint _wlSalePrice,
        uint _publicSalePrice
        ) ERC721A("CoolNFT", "COOLNFT")
    PaymentSplitter(_team, _teamShares) {
        merkleRoot = _merkleRoot;
        baseURI = _baseURI;
        teamLength = _team.length;
        maxSupply = _maxSupply;
        maxWhitelist = _maxWhitelist;
        wlMintLimit = _wlMintLimit;
        saleStartTime = _saleStartTime;
        wlSalePrice = _wlSalePrice;
        publicSalePrice = _publicSalePrice;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract.");
        _;
    }

    function merkletreeVerify(bytes32[] calldata _proof) public view returns(bool){
        if (isWhiteListed(msg.sender, _proof)) {
            if (currentTime() <= saleStartTime){
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    function whitelistMint(address _account, uint _quantity, bytes32[] calldata _proof) external payable callerIsUser {
        uint price = wlSalePrice;
        require(currentTime() <= saleStartTime, "Whitelist Sale has not started yet");
        // require(sellingStep == Step.WhitelistSale, "Whitelist sale is not activated");
        require(isWhiteListed(msg.sender, _proof), "Not whitelisted");
        require(amountNFTsperWalletWhitelistSale[msg.sender] + _quantity <= wlMintLimit, "Whitelist minting limit exceeded");
        require(totalSupply() + _quantity <= maxWhitelist, "Max supply exceeded");
        require(msg.value >= price * _quantity, "Not enough funds");
        amountNFTsperWalletWhitelistSale[msg.sender] += _quantity;
        _safeMint(_account, _quantity);
        emit mint(msg.sender);
    }

    function publicSaleMint(address _account, uint _quantity) external payable callerIsUser {
        require(currentTime() > saleStartTime, "Public Sale has not started yet");
        uint price = publicSalePrice;
        // require(sellingStep == Step.PublicSale, "Public sale is not activated");
        require(totalSupply() + _quantity <= maxSupply, "Max supply exceeded");
        require(msg.value >= price * _quantity, "Not enough funds");
        _safeMint(_account, _quantity);
        emit mint(msg.sender);
    }

    // function widthraw(address _to) external payable onlyOwner{
    //      uint amount = address(this).balance;
    //     (bool success, ) = _to.call{value: amount}("");
    //      require(success, "Failed to send Ether");
    //      emit widthrawToWallet(_to);
    // }

    function gift(address _to, uint _quantity) external onlyOwner returns(uint256){
        require(totalSupply() + _quantity <= maxSupply, "Reached max Supply");
        _safeMint(_to, _quantity);
        return totalSupply();
    }

    function setSaleStartTime(uint _saleStartTime) external onlyOwner {
        saleStartTime = _saleStartTime;
    }

    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function currentTime() internal view returns(uint) {
        return block.timestamp;
    }

    // function setStep(uint _step) external onlyOwner {
    //     sellingStep = Step(_step);
    // }

    function setMaxSupply(uint _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setMaxWhitelist(uint _maxWhitelist) external onlyOwner {
        maxWhitelist = _maxWhitelist;
    }

    function setWhitelistMintLimit(uint _wlMintLimit) external onlyOwner {
        wlMintLimit = _wlMintLimit;
    }

    function setWhitelistSalePrice(uint _wlSalePrice) external onlyOwner {
        wlSalePrice = _wlSalePrice;
    }

    function setPublicSalePrice(uint _publicSalePrice) external onlyOwner {
        publicSalePrice = _publicSalePrice;
    }

    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");

        // if (!revealed) {
        //     return string(abi.encodePacked(baseURI, "hidden.json"));
        // }

        return string(abi.encodePacked(baseURI, _tokenId.toString()));
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setReveal(bool _revealed) external onlyOwner {
        revealed = _revealed;
    }

    function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
        return _verify(leaf(_account), _proof);
    }

    function leaf(address _account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 _leaf, bytes32[] memory _proof) internal view returns(bool) {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }

    function releaseAll() external onlyOwner {
        for(uint i = 0 ; i < teamLength ; i++) {
            release(payable(payee(i)));
        }
    }

    receive() override external payable {
        revert('Minting allowed only.');
    }
}