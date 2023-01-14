# PancakeSwap_UZH
 We implement features of PancakeSwap on the UZH Ethereum Blockchain.


## Swap 
- "TokenSwap_Notebook.ipynb": The Token Swap Notebook needs the abi and json files. These files are stored in the folder "abi_bytecode". 
- Folder "abi_bytecode": abi and json (bytecode) files to use for the Notebook 
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

## UZHPancakeLottery
- 'lotteryStarter.sol': This contract creates a lottery where players can enter by sending a certain amount of ether and the owner can pick a winner at random.
- 'UZHPancakeLottery.sol': This UZHPancakeLottery contract allows users to buy tickets and compete in a lottery, programmed independently from scratch according to the instructions of Pancakeswap.
- 'UZHPancakeLotteryNotebook.ipynb': This Notebook allows you to interact with the UZHPancakeLottery.sol contract via web3. To run it successfully, all the required python libraries must be downloaded, and the the'UZHPancakeLottery.abi' and artifacts folder with all the JSON files must be in the same folder. For successful implementation, you must also deploy the UZHPancakeLottery.sol contract on your own and use your contract address, JSON, and abi files in the UZHPancakeLottery Notebook; otherwise, you are not the contract owner and can't interact with the contract appropriately.


## NFT Marketplace
- "UZHETH-Python Integration_final.ipynb": The interaction with the NFT marketplace out of Python. It required the following folders/ files: 
  - "NFT Marketplace/img/" for the images
  - "NFT_marketplace.sol", "NFT_marketplace.abi" and "NFT_marketplace.bin" for the connection to the deployed smart contract.
- Folder "config_metadata": Contains the configs of the created NFTs via Pinata.
- Folder "Screenshots": Contains screenshots of the tests to proof that if works. Not relevant for submission! 
