# opencase-evm

## prerequisites
```
node js v16.16.0 or newer
yarn v1.22.19 or newer
```

## deployment process

1. install dependencies `yarn install`
2. create `.env` file based on `.env.example`
3. create `case.json` file with your values:
```json
{
    "ipfstr": "ipfs://bafy.........................bm7mu/",
    "nftcol": "0x74b7................................14e3",
    "ptoken": "0xE097................................6921",
    "receiv": "0xA644................................13e2",
    "sprice": "1000000",
    "unused": 20,
    "rndfrm": 0
}
```
4. run `hh deploy-case --network realnet`
5. done

# license
MIT license. Read more in [LICENSE](./LICENSE) file.
