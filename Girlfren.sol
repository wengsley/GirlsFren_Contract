/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

//GF token

//SPDX-License-Identifier: None

// pragma solidity 0.8.14;
// pragma solidity >=0.4.20;
pragma solidity >=0.4.21 <=0.8.14;
pragma abicoder v1;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}


abstract contract Pausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



contract GF is IBEP20, Auth, Pausable {
    using SafeMath for uint256;

    event TradingEnabled(uint256 _startDate);
    event TimeFupdated(uint256 _timeF);
    event AdressBlacklisted(address _address, bool _bool);
    event TXLimitSet(uint256 _txLimit);
    event MaxWalletSet(uint256 _maxWallet);
    event IsFeeExemptSet(address _address, bool _exempt);
    event BuyFeesSet (uint256 _totalFees);
    event SellFeesSet (uint256 _totalFees);
    event RewardFeeReceiverSet(address _address);
    event MarketingFeeReceiverSet(address _address);
    event SwapBackSettingsSet(bool _bool, uint256 _amount);
    //Mainnet BSC :0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c // Testnet BSC: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd // ETH Mainnet: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D // ETH Testnet: 0xc778417E063141139Fce010982780140Aa0cD5Ab
    address constant private WBNB = 0x9Bbb45063Ae464fff3d4f90FaF66619fcc7B4b57; // WBNB contract address 
    address constant private DEAD = 0x000000000000000000000000000000000000dEaD; // burn address - black hole
    address constant private ZERO = 0x0000000000000000000000000000000000000000; // zero

    string private constant _name = "GirlsFren";
    string private constant _symbol = "GF";
    uint8 private constant _decimals = 18;


    uint256 constant private  _totalSupply = 100000000000000 * (10 ** _decimals); // 14 zeros
    uint256 private  _burntSupply = (_totalSupply * 10) /100; // 10% burn
    uint256 private  _liqSupply = (_totalSupply * 90) /100; // 90% remaining


    // uint256 private constant _totalSupply = 100000000000000 * (10 ** _decimals); // 14 zeros
    // uint256 private constant _burntSupply = (_totalSupply * 10) /100; // 10% burn
    // uint256 private constant _liqSupply = (_totalSupply * 90) /100; // 90% remaining

   
    uint256 public _maxTxAmount = (_totalSupply * 2) / 1000; // max limit per transaction - 0.2%
    uint256 public _maxWalletSize = (_totalSupply * 5) / 1000; // max wallet size - 0.5%

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMaxWalletExempt;
    mapping (address => bool) private bl;
    

    //Buyfees
    uint256 private liquidityFee = 0;
    uint256 private marketingFee = 3;
    uint256 private rewardFee = 6;
    uint256 private totalFee = 9;
    
    
    //Sellfees
    uint256 private sellLiquidityFee = 3;
    uint256 private sellMarketingFee = 3;
    uint256 private sellRewardFee = 3;
    uint256 private totalSellFee = 9;
    
    
    //AvFees
    uint256 private tempLiquidityFee;
    uint256 private tempMarketingFee;
    uint256 private tempLiqProviderFee;
    uint256 private tempRewardFee;
    uint256 private tempTotalFee;
    
    uint256 private feeDenominator = 100;
    uint256 public launchTimestamp;
    uint256 private timeF; 
    
    
    address private marketingFeeReceiver = 0x71c8819988FFD77e5983854fc1B1F94596Ec4872; //
    address constant private ethBridgeAndExchange = 0x9Bbb45063Ae464fff3d4f90FaF66619fcc7B4b57; // 0x5511140bb33158e3b7b0d0B83D20C5D6Cf1E9522
    // address private rewardWallet = 0x6823e74dDf4BA14E660f6B2CaE5970B0F1a7324e; //
    address private buyNFTRewardWallet = 0x72067C1c4608ae8765a9Fb0E24947dC5159310b5;
    address private sellNFTRewardWallet = 0xB7A88A07e826842aC085D739C6c87dC2fc9C5bBA;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    
    bool public tradingEnabled;
    bool public swapEnabled;
    uint256 public swapThreshold = _totalSupply / 1000 * 1; // 0.1%
    
    bool private inSwap;
    
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
        //Testnet BSC: 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //Testnet ETH: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;
        address _DEAD = DEAD;
        isFeeExempt[_owner] = true;
        isTxLimitExempt[_owner] = true;
        isMaxWalletExempt[_owner] = true; 
        isFeeExempt[ethBridgeAndExchange] = true;
        isTxLimitExempt[ethBridgeAndExchange] = true;
        isMaxWalletExempt[ethBridgeAndExchange] = true; 
        isFeeExempt[buyNFTRewardWallet] = true; 
        isTxLimitExempt[buyNFTRewardWallet] = true; 
        isMaxWalletExempt[buyNFTRewardWallet] = true; 
        isFeeExempt[sellNFTRewardWallet] = true; 
        isTxLimitExempt[sellNFTRewardWallet] = true; 
        isMaxWalletExempt[sellNFTRewardWallet] = true; 
        
        _balances[_owner] = _liqSupply;
        _balances[_DEAD] = _burntSupply;
        emit Transfer(address(0), _owner, _liqSupply);
        emit Transfer(address(0), _DEAD, _burntSupply);
    }

    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }

        // function totalSupply() external pure override returns (uint256) { return _totalSupply; }

    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }


    //Added pause for owner only
    function pause() public onlyOwner {
        _pause();
    }

    //Added unpause for owner only
    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )   internal
        whenNotPaused
        virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    )  internal
        whenNotPaused
        virtual {}

    // Increase allowance
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;

        uint256 currentAllowance = _allowances[owner][spender];

        approve(spender, currentAllowance + addedValue);

        return true;
    }

    // Decrease allowance
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;

        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        
        approve(spender, currentAllowance - subtractedValue);

        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
         _beforeTokenTransfer(sender, recipient, amount);

        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!bl[sender] && !bl[recipient]);
        if(sender != pair && recipient != pair){ return _basicTransfer(sender, recipient, amount); } //transfer between wallets
        
        if(!isFeeExempt[sender]){
            require(tradingEnabled, "Trading is not enabled yet");
        }
        
        checkTxLimit(sender,recipient, amount);


        if (recipient != pair && recipient != DEAD && recipient != ethBridgeAndExchange && sender != ethBridgeAndExchange) {
            require(isTxLimitExempt[recipient] || isTxLimitExempt[sender] || isMaxWalletExempt[sender]|| isMaxWalletExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds max wallet size.");
        }
        
        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
    
        if(shouldTakeFee(sender) != true || shouldTakeFee(recipient) != true){
             uint256 amountReceived = amount; 
             _balances[recipient] = _balances[recipient].add(amountReceived);

            emit Transfer(sender, recipient, amountReceived);

            _afterTokenTransfer(sender, recipient, amountReceived);

        }
        else {
            uint256 amountReceived = takeFee(sender, recipient, amount);
            _balances[recipient] = _balances[recipient].add(amountReceived);

            emit Transfer(sender, recipient, amountReceived);

            _afterTokenTransfer(sender, recipient, amountReceived);
        }


        
        
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(!bl[sender] && !bl[recipient]);
        require(isMaxWalletExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds max wallet size basic transfer.");
        require(isFeeExempt[sender] || tradingEnabled == true, "Trading not enabled yet");
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        uint256 multiplier = AntiDumpMultiplier();
        bool firstFewBlocks = AntSni();
        if(selling) {   return totalSellFee.mul(multiplier); }
        if (firstFewBlocks) {return feeDenominator.sub(1); }
        return totalFee;
    }

    function AntiDumpMultiplier() private view returns (uint256) {
        uint256 time_since_start = block.timestamp - launchTimestamp;
        uint256 hour = 3600;
        if (time_since_start > 1 * hour) { return (1);}
        else { return (2);}
    }
    
    function AntSni() private view returns (bool) {
        uint256 time_since_start = block.timestamp - launchTimestamp;
        if (time_since_start < timeF) { return true;}
        else { return false;}
    }
    
    function updateTimeF(uint256 _int) external onlyOwner {
        require(_int < 1536, "Time too long");
        timeF = _int;
        emit TimeFupdated(_int);
    }


    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);
        if(receiver == pair) {
            uint256 rewardFeeAmount = amount.mul(sellRewardFee).div(feeDenominator).mul(AntiDumpMultiplier());
            uint256 newFeeAmount = feeAmount.sub(rewardFeeAmount);
            
            _balances[buyNFTRewardWallet] = _balances[buyNFTRewardWallet].add(rewardFeeAmount);
            emit Transfer(sender, buyNFTRewardWallet, rewardFeeAmount);
            
            _balances[address(this)] = _balances[address(this)].add(newFeeAmount); 
            emit Transfer(sender, address(this), newFeeAmount); 
            return amount.sub(feeAmount); 
        }
        else {
            uint256 rewardFeeAmount = amount.mul(rewardFee).div(feeDenominator);
            uint256 newFeeAmount = feeAmount.sub(rewardFeeAmount);
            
            
            _balances[sellNFTRewardWallet] = _balances[sellNFTRewardWallet].add(rewardFeeAmount);
            emit Transfer(sender, sellNFTRewardWallet, rewardFeeAmount);
            
            _balances[address(this)] = _balances[address(this)].add(newFeeAmount);
            emit Transfer(sender, address(this), newFeeAmount);
            return amount.sub(feeAmount);
       }
    
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function getSwapFees() internal {
        tempLiquidityFee = liquidityFee.add(sellLiquidityFee).div(2);
        tempMarketingFee = marketingFee.add(sellMarketingFee).div(2);
        tempRewardFee = rewardFee.add(sellRewardFee).div(2);
        tempTotalFee = totalFee.add(totalSellFee).div(2);
    }

    function swapBack() internal swapping {
        //average the fees
        getSwapFees();
        
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 amountToLiquify = contractTokenBalance.mul(tempLiquidityFee).div(tempTotalFee.sub(tempRewardFee)).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = tempTotalFee.sub(tempRewardFee).sub(tempLiquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(tempLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(tempMarketingFee).div(totalBNBFee);
        
       
        (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess,"receiver rejected ETH transfer");

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                marketingFeeReceiver,
                block.timestamp
            );
        }
    }
    
    
    function startTrading() external onlyOwner{
        tradingEnabled = true;
        swapEnabled = true;
        launchTimestamp = block.timestamp;
        emit TradingEnabled(block.timestamp);
    }


    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }
    
    function checkTxLimit(address sender, address recipient, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender]|| isTxLimitExempt[recipient], "TX Limit Exceeded");
    }
    
    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
        emit TXLimitSet(amount);
    }

   function setMaxWallet(uint256 amount) external onlyOwner() {
        require(amount >= _totalSupply / 1000 );
        _maxWalletSize = amount;
        emit MaxWalletSet( amount);
    }    

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
        emit IsFeeExemptSet( holder, exempt);
    }
    
    function excludeFromMaxWallet(address _wallet, bool _excludeFromMaxWallet) external onlyOwner{
        isMaxWalletExempt[_wallet] = _excludeFromMaxWallet; 
    }

    function setBl(address _wallet, bool _bl) external onlyOwner{
        bl[_wallet] = _bl; 
        emit AdressBlacklisted(_wallet, _bl);
    }
    
    function excludeFromMaxTX(address _wallet, bool _excludeFromMaxTx) external onlyOwner{
        isTxLimitExempt[_wallet]= _excludeFromMaxTx;
    }

    function setBuyFees(uint256 _liquidityFee,  uint256 _marketingFee, uint256 _rewardFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        rewardFee = _rewardFee;
      
        totalFee = _liquidityFee.add(_marketingFee).add(_rewardFee);
        feeDenominator = _feeDenominator;
        emit BuyFeesSet (totalFee);
    }
    
    function setSellFees(uint256 _liquidityFee,  uint256 _marketingFee, uint256 _rewardFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        sellRewardFee = _rewardFee;
        
        totalSellFee = _liquidityFee.add(_marketingFee).add(_rewardFee);
        feeDenominator = _feeDenominator;
        emit SellFeesSet (totalFee);
    }

    function setBuyRewardFeeReceiver(address _rewardFeeReceiver) external authorized {
        buyNFTRewardWallet = _rewardFeeReceiver;
        emit RewardFeeReceiverSet(_rewardFeeReceiver );
    }

    function setSellRewardFeeReceiver(address _rewardFeeReceiver) external authorized {
        sellNFTRewardWallet = _rewardFeeReceiver;
        emit RewardFeeReceiverSet(_rewardFeeReceiver );
    }

    function setMarketingFeeReceiver(address _marketingFeeReceiver) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
        emit MarketingFeeReceiverSet(_marketingFeeReceiver );
    }
    

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
        emit SwapBackSettingsSet(_enabled, _amount);
    }
    

    function manualSend() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingFeeReceiver).transfer(contractETHBalance);
    }

    function transferERC20(address _token, uint _amount) public authorized {
        require(_amount <= IBEP20(_token).balanceOf(address(this)), "Can't transfer more than the balance");
        IBEP20(_token).transfer(marketingFeeReceiver, _amount);
    }
        
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    


}
