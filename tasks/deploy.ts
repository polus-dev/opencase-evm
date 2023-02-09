import { task } from 'hardhat/config'
import * as casecfg from '../case.json'

type DeployERC721TokenArgs = { name: string, symbol: string }
type DeployERC20TokenArgs = { name: string, symbol: string, premint: number }

task('deploy-case', 'deploy "contracts/OpenCase.sol" smart contract')
    .setAction(async (_, hre) => {
        const OpenCase = await hre.ethers.getContractFactory('PolusOpenCase')

        for (let i = 0; i < casecfg.casesa.length; i++) {
            const currnt = casecfg.casesa[i]

            const unused = (currnt.range[1] - currnt.range[0]) + 1
            const rndfrm = currnt.range[0]

            const opencase = await OpenCase.deploy(
                currnt.cname,
                currnt.ipfsb,
                casecfg.nftcol,
                casecfg.ptoken,
                casecfg.receiv,
                currnt.price,
                unused,
                rndfrm
            )

            await opencase.deployed()

            const rangestr = `${currnt.range[0]},${currnt.range[1]}`
            console.log(`Case deployed to: ${opencase.address} | ${currnt.cname} ${rangestr}`)
        }
    })

task('start-case', 'start case by address')
    .addPositionalParam<string>('address', 'address of PolusOpenCase contract')
    .setAction(async (arg: { address: string }, hre) => {
        const OpenCase = await hre.ethers.getContractFactory('PolusOpenCase')
        const opencase = OpenCase.attach(arg.address)

        const tx = await opencase.startc()
        console.log(`startc executed in tx ${tx.hash}`)
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
