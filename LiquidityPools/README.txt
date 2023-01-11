ROUTER: Contract for interacting with the 'LiquidityFactory' and 'LiquidityPool' contracts (add/ withdraw liquidity, exchange tokens using liquidity). 
Needs to be deployed manually and referenced on 'LiquidityFactory' contract by admin.
--> Deployed through notebook at: 0x043124a8e838FfdFB968309Fe4077B274d5A4C34

FACTORY: Contract for deploying new and keeping track of 'LiquidityPool' contracts. Called by 'Router'. 
Needs to be deployed manually and referenced on 'Router' contract by admin.
--> Deployed  through notebook at: 0x07Db82eAd90449bf347fc3A4fAAE32F86eCC8B60

POOL: Contract for managing liquidity of a specific token pair. Called by 'Router'. Deployed by 'LiquidityFactory'.
--> Test deployed through notebook at: 0x1C6C5e71c05B6D788A240fb5C1ee633d64A7ecDE
--> Tokens used: 0x128A8F1a0361adA3ab1F6Bb0F4940461B3BD3f1E, 0x1D596687e91C0Deb82aa2538858b4FBD0331141A