const hre = require("hardhat")
const ethers = hre.ethers
const yargs = require('yargs')
const { MerkleTree } = require("merkletreejs");
const keccak256 = require('keccak256');

const argv = yargs
  .command('Generate an NFT smart contract ready to deploy.')
  .option('name', {
    alias: 'n',
    description: 'Set the name of the NFT',
    type: 'string'
  })
  .option('network', {
    alias: 't',
    description: 'Set the deployment network',
    type: 'string'
  })
  .option('team', {
    alias: 'te',
    description: 'Set the splitting address',
    type: 'string'
  })
  .option('teamShares', {
    alias: 'ts',
    description: 'Set the Payment splitting %',
    type: 'number'
  })
  .option('merkletree', {
    alias: 'mt',
    description: 'Set the addresses of Merkle tree',
    type: 'string'
  })
  .option('baseURI', {
    alias: 'b',
    description: 'Set the base URI',
    type: 'string'
  })
  .option('maxSupply', {
    alias: 'ms',
    description: 'Set the Max Supply',
    type: 'Number'
  })
  .option('maxWhitelist', {
    alias: 'mw',
    description: 'Set the Max Supply',
    type: 'Number'
  })
  .option('wlMintLimit', {
    alias: 'wml',
    description: 'Set the Mint limit of whitelist',
    type: 'Number'
  })
  .option('saleStartTime', {
    alias: 'sst',
    description: 'Set the start time for sale',
    type: 'Number'
  })
  .option('wlSalePrice', {
    alias: 'wsp',
    description: 'Set the price of whitelist',
    type: 'Number'
  })
  .option('publicSalePrice', {
    alias: 'psp',
    description: 'Set the public price',
    type: 'Number'
  })
  .help()
  .alias('help', 'h').argv;

const { name, network, merkletree, team, teamShares, baseURI, maxSupply, maxWhitelist, wlMintLimit, saleStartTime, wlSalePrice, publicSalePrice } = argv

const leafNodes = merkletree.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

const rootHash = merkleTree.getRoot();

// console.log(name, network, rootHash, team, teamShares, baseURI, maxSupply, maxWhitelist, wlMintLimit, saleStartTime, wlSalePrice, publicSalePrice)
// process.exit(1)

if (network) {
  process.env['HARDHAT_NETWORK'] = network
}

async function main() {

  console.log(`Compiling ...`)
  await hre.run("compile")

  // Grab the contract factory
  console.log(`Deploying ...`)

  const NFT = await ethers.getContractFactory(name)

  // Start deployment
  const deployed = await NFT.deploy(team, teamShares, rootHash, baseURI, maxSupply, maxWhitelist, wlMintLimit, saleStartTime, wlSalePrice, publicSalePrice) // Instance of the contract 

  console.log("Contract deployed to address:", deployed.address)
  // console.log(deployed)
}

main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error)
   process.exit(1)
 });