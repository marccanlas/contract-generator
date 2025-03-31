const fs = require('fs')
const yargs = require('yargs')

const argv = yargs
  .command('Generate an NFT smart contract ready to deploy.')
  .option('name', {
    alias: 'n',
    description: 'Set the name of the NFT',
    type: 'string'
  })
  .option('symbol', {
    alias: 's',
    description: 'Set the symbol of the NFT',
    type: 'string'
  })
  .help()
  .alias('help', 'h').argv;

console.log(argv)

const { name, symbol, maxSupply } = argv['_'].length ? argv['_'] : argv

console.log(`Generating ${name} | ${symbol} contract...`)

const template = fs.readFileSync('./templates/erc721a.sol', 'utf8')
const sourceCode = template.replace(/nftNAME/g, name)
                          .replace(/nftSYMBOL/g, symbol)


fs.writeFileSync(`./contracts/${name}.sol`, sourceCode)