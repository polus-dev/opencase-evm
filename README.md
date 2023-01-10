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
    "nftcol": "0x74b7CF5C5Dc3854f06Ce75acE3dAB868C99014e3",
    "ptoken": "0xE097d6B3100777DC31B34dC2c58fB524C2e76921",
    "receiv": "0xA64452F16014599bA9e80bc1a1dE968624C113e2",
    "ipfstr": [{
        "cname": "case name",
        "ipfsb": "ipfs://zdj7WfsbQNERbgiDCA8oPMGrSAF3Jd5tcXhyt7VMTTtiFE9S5/",
        "price": "75000000",
        "range": [26, 199]
    }]
}

```
4. run `hh deploy-case --network realnet`
5. done

# license
MIT license. Read more in [LICENSE](./LICENSE) file.
