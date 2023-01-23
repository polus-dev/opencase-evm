import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import '@nomiclabs/hardhat-etherscan'
import '@nomicfoundation/hardhat-chai-matchers'

import './tasks/deploy'
import './tasks/info'

import * as dotenv from 'dotenv'

dotenv.config({ path: '.env' })

const config: HardhatUserConfig = {
    defaultNetwork: 'hardhat',
    networks: {
        realnet: {
            chainId: parseInt(process.env.CHAIN_ID || '', 10),
            accounts: [ `0x${process.env.PRIVATE_KEY}` ],
            url: process.env.RPC_URL
        },
        localhost: { url: 'http://127.0.0.1:8545/' },
        hardhat: {}
    },
    solidity: {
        version: '0.8.9',
        settings: { optimizer: { enabled: true, runs: 200 } }
    },
    paths: {
        sources: './contracts',
        tests: './tests',
        cache: './cache',
        artifacts: './artifacts'
    },
    etherscan: { apiKey: { polygon: process.env.ETHERSCAN_KEY || '' } },
    gasReporter: {
        enabled: process.env.GAS_REPORTER_ENABLED === 'true',
        token: process.env.GAS_REPORTER_TOKEN,
        currency: process.env.GAS_REPORTER_CURRENCY,
        gasPriceApi: process.env.GAS_REPORTER_GASPRICEAPI,
        coinmarketcap: process.env.GAS_REPORTER_COINMARKETCAP
    }
}

// eslint-disable-next-line import/no-default-export
export default config
