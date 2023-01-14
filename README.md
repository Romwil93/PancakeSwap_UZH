# PancakeSwap_UZH
 We implement features of PancakeSwap on the UZH Ethereum Blockchain.


## Swap 
- "TokenSwap_Notebook.ipynb": The Token Swap Notebook needs the abi and json files. These files are stored in the folder "abi_bytecode". 
- "abi_bytecode": abi and json (bytecode) files to use for the Notebook 
- "Archive": different files tested during development. Not relevant for submission! 
- "TokenSwap.sol": Swap contract
- "PancakeToken.sol": Token contract

## Liquidity pools
- 'LiquidityPoolInteraction.jpynb': For the user interaction with and deployment of the liquidity pool functionality. It requires various abi- and bin-files, namely:
  - 'Factory.abi' and 'Factory.bin' for deploying and loading the factory smart contract, 
  - 'Router.abi' and 'Router.bin' for deploying and loading the router smart contract, 
  - 'Pool.abi for loading deployed liquidity pools, as well as 
  - 'ERC20.abi' for loading tokens following the ERC-20 standard.
- contracts folder: Contains the Solidity code files for the factory ('FactoryContract.sol'), the router ('RouterContract.sol'), and liquidity pool ('PoolContract.sol') smart contracts.
- 'README.txt: Contains information on currently deployed smart contract instances for testing purposes.

## Lottery


## NFT Marketplace
- "UZHETH-Python Integration_final.ipynb": The interaction with the NFT marketplace out of Python. It required the following folders/ files: 
  - "NFT Marketplace/img/" for the images
  - "NFT_marketplace.sol", "NFT_marketplace.abi" and "NFT_marketplace.bin" for the connection to the deployed smart contract.
- Folder "config_metadata": Contains the configs of the created NFTs via Pinata.
- Folder "Screenshots": Contains screenshots of the tests to proof that if works. Not relevant for submission! 
