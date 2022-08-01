import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      blockGasLimit: 100000000,
      gas: 100000000
    },
    kccTest: {
      url: 'https://rpc-testnet.kcc.network',
      chainId: 322,
      accounts: ['a169188d442a35eff327a448d864d82523f95e07a20e76247230ba38c596d0dd']
      // gasPrice: 20000000000,
      // accounts: {mnemonic: mnemonic}
    },
    kccMainnet: {
      url: ' https://rpc-mainnet.kcc.network',
      chainId: 321,
      // gasPrice: 20000000000,
      accounts: ['a169188d442a35eff327a448d864d82523f95e07a20e76247230ba38c596d0dd'],
    }
  },

  solidity: {
    compilers: [
      { version: "0.8.9" }
    ]
  }
};

export default config;
