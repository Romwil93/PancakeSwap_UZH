ROUTER: Contract for interacting with the 'LiquidityFactory' and 'LiquidityPool' contracts (add/ withdraw liquidity, swap tokens using liquidity). 
Needs to be deployed manually and referenced on 'LiquidityFactory' contract by admin.
--> Deployed at: 0x1Fe0249F120Bb6DDda4b4088Df4E96552976E2A3

FACTORY: Contract for deploying new and keeping track of 'LiquidityPool' contracts. Called by 'Router'. 
Needs to be deployed manually and referenced on 'Router' contract by admin.
--> Deployed at: 0xf219935e219b36eF69315c0179197E0B4318C3E2

POOL: Contract for managing liquidity of a specific token pair. Called by 'Router'. Deployed by 'LiquidityFactory'.
--> Test deployed at: 0x78b4D41224EbF1A2478Ee0BbE67f96C2b6D908C2
--> Tokens used: 0x128A8F1a0361adA3ab1F6Bb0F4940461B3BD3f1E, 0x1D596687e91C0Deb82aa2538858b4FBD0331141A


!!!Important!!!
Before sending tokens to pool through the 'addLiquidity', 'withdrawLiquidity', and 'swap' functions in the 'Router' contract,
the allowance must be approved through the token contracts.