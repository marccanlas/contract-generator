const { MerkleTree } = require("merkletreejs");
const keccak256 = require('keccak256');

let whitelistAddresses = [
    "0x8a72D3480EB61B985765ebD9823DbaC3E77A96DE",
    "0x2CCa4e618b1Acf866E4d6EAA6170C1b2b75637bc"
]

let preMintAddresses = [
    "0x7619D2Ff06E37F84e28c0f80a54C89813677a3C0",
    "0xaE43aCac9FdeA2448fc62071aA5637D0Db98200d"
]

const whitelistleafNodes = whitelistAddresses.map(addr => keccak256(addr));
const whitelistmerkleTree = new MerkleTree(whitelistleafNodes, keccak256, { sortPairs: true });

const whitelistrootHash = whitelistmerkleTree.getHexRoot();
const whitelistproof = whitelistmerkleTree.getHexProof(keccak256("0x8a72D3480EB61B985765ebD9823DbaC3E77A96DE"));

const preleafNodes = preMintAddresses.map(addr => keccak256(addr));
const premerkleTree = new MerkleTree(preleafNodes, keccak256, { sortPairs: true });

const prerootHash = premerkleTree.getHexRoot();
const preproof = premerkleTree.getHexProof(keccak256("0x7619D2Ff06E37F84e28c0f80a54C89813677a3C0"));

console.log("Whitelist", whitelistrootHash);
console.log("Pre mint", prerootHash);
console.log("whitelistproof", whitelistproof);
console.log("preproof", preproof);