import { task } from 'hardhat/config'
import * as casecfg from '../case.json'

type DeployERC721TokenArgs = { name: string, symbol: string }
type DeployERC20TokenArgs = { name: string, symbol: string, premint: number }

task('deploy-case', 'deploy "contracts/OpenCase.sol" smart contract')
    .setAction(async (_, hre) => {
        const OpenCase = await hre.ethers.getContractFactory('PolusOpenCase')
        const opencase = await OpenCase.deploy(
            casecfg.ipfstr,
            casecfg.nftcol,
            casecfg.ptoken,
            casecfg.receiv,
            casecfg.sprice,
            casecfg.unused,
            casecfg.rndfrm
        )

        await opencase.deployed()
        console.log('PolusOpenCase deployed to:', opencase.address)
    })

task('deploy-erc721', 'deploy "contracts/tokens/ERC721Token.sol" smart contract')
    .addPositionalParam<string>('name', 'name of the token')
    .addPositionalParam<string>('symbol', 'symbol of the token')
    .setAction(async (arg: DeployERC721TokenArgs, hre) => {
        const Token = await hre.ethers.getContractFactory('ERC721Token')
        const token = await Token.deploy(arg.name, arg.symbol)

        await token.deployed()
        console.log('ERC721Token deployed to:', token.address)
    })

task('deploy-erc20', 'deploy "contracts/tokens/ERC20Token.sol" smart contract')
    .addPositionalParam<string>('name', 'name of the token')
    .addPositionalParam<string>('symbol', 'symbol of the token')
    .addPositionalParam<number>('premint', 'initial supply of the token')
    .setAction(async (arg: DeployERC20TokenArgs, hre) => {
        const Token = await hre.ethers.getContractFactory('ERC20Token')
        const token = await Token.deploy(arg.name, arg.symbol, arg.premint)

        await token.deployed()
        console.log('ERC20Token deployed to:', token.address)
    })
