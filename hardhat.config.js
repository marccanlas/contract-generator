/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
const { API_URL, PRIVATE_KEY } = process.env;
module.exports = {
   solidity: "0.8.4",
   defaultNetwork: "rinkeby",
   networks: {
      hardhat: {},
      rinkeby: {
         url: "https://eth-rinkeby.alchemyapi.io/v2/OJFNZ3uQy_qQPOROMQ8oRwpuckNPkeIs",
         accounts: [`0x${PRIVATE_KEY}`]
      }
   },
}