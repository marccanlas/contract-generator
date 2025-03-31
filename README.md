# Intro

This tool allows to generate smart contract for our clients.

We use 

How to use: 

Create a `.env` file containing the private key of the account used to pay for the contract:

```
PRIVATE_KEY="85440f0b2917596e98091cadb50336f4a7472522364a5b0f4d35fbb426f9d9aa"
```

Then generate the smart contract:
```
node scripts/create.js --name CoolNFT --symbol COOLNFT
```

Then launch the deploy script, with the name of the contract

```
node scripts/deploy.js --name CoolNFT --network rinkeby --team teamAddress1 --team teamAddress2 --teamShares share1 --teamShares share2 --merkletree address1 --merkletree address2 --merkletree address3 --merkletree address4(etc) --baseURI baseURI --maxSupply maxsupply --maxWhitelist maxlist --wlMintLimit mintlimit --saleStartTime starttime --wlSalePrice whitelistPrice --publicSalePrice normalPrice
```
