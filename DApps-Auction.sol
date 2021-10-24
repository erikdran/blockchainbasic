pragma solidity ^0.4.17;
contract Auction {
    
    // Data
    //Structure to hold details of the item
    struct Item {
        uint itemId; // id of the item，奖品id
        uint[] itemTokens;  //tokens bid in favor of the item，投票池
       
    }
    
   //Structure to hold the details of a persons
    struct Person {
        uint remainingTokens; // tokens remaining with bidder，剩余票数
        uint personId; // it serves as tokenId as well，存根，身份证明
        address addr;//address of the bidder，地址
    }
 
    mapping(address => Person) tokenDetails; //address to person ，存根信息
    Person[4] bidders;//Array containing 4 person objects，竞标人数组，4人
    
    Item[3] public items;//Array containing 3 item objects，奖品数组，3个
    address[3] public winners;//Array for address of winners，奖品获得者
    address public beneficiary;//owner of the smart contract，受益人
    
    uint bidderCount=0;//counter,有几个bidder，计数
    
    //functions

    function Auction() public payable{    //constructor
                
        //Part 1 Task 1. Initialize beneficiary with address of smart contract’s owner
        //Hint. In the constructor,"msg.sender" is the address of the owner.
        // ** Start code here. 1 line approximately. **/
        beneficiary = msg.sender; //受益人为合约创建者
          //** End code here. **/
        uint[] memory emptyArray; //空数组
        items[0] = Item({itemId:0,itemTokens:emptyArray});
        
        //Part 1 Task 2. Initialize two items with at index 1 and 2. 
        // ** Start code here. 2 lines approximately. **/
        items[1] = Item({itemId:1,itemTokens:emptyArray});
        items[2] = Item({itemId:2,itemTokens:emptyArray});
        //** End code here**/
    }
    

    function register() public payable{
        
        
        bidders[bidderCount].personId = bidderCount; //竞标人注册，获得一个数组下标作为身份证明
        
        //Part 1 Task 3. Initialize the address of the bidder 
        /*Hint. Here the bidders[bidderCount].addr should be initialized with address of the registrant.*/

        // ** Start code here. 1 line approximately. **/
        bidders[bidderCount].addr =  msg.sender; //竞标人的地址
        //** End code here. **
        
        bidders[bidderCount].remainingTokens = 5; // only 5 tokens，竞标人的票数，仅5票
        tokenDetails[msg.sender]=bidders[bidderCount]; //address关联到人
        bidderCount++; //人数+1
    }
    
    function bid(uint _itemId, uint _count) public payable{
        /*
            Bids tokens to a particular item.
            Arguments:
            _itemId -- uint, id of the item
            _count -- uint, count of tokens to bid for the item
        */
        
        /*
        Part 1 Task 4. Implement the three conditions below.
            4.1 If the number of tokens remaining with the bidder is < count of tokens bidded, revert.
            4.2 If there are no tokens remaining with the bidder, revert.
            4.3 If the id of the item for which bid is placed, is greater than 2, revert.
        Hint: "tokenDetails[msg.sender].remainingTokens" gives the details of the number of tokens remaining with the bidder.
        */
        
        // ** Start code here. 2 lines approximately. **/
    	require(tokenDetails[msg.sender].remainingTokens >= _count && tokenDetails[msg.sender].remainingTokens > 0);  //竞标人的票不为0，且投剩余的票数大于他想投的票数
    	require(_itemId <= 2); //所投标的编号为0，1，2，因为只有三个标
        //** End code here. **
        
        /*Part 1 Task 5. Decrement the remainingTokens by the number of tokens bid and store the value in balance variable.
        Hint. "tokenDetails[msg.sender].remainingTokens" should be decremented by "_count". */
 
        // ** Start code here. 1 line approximately. **
        uint balance = tokenDetails[msg.sender].remainingTokens - _count;  //竞标人的票数在投票后减少
        //** End code here. **
        
        //todo: balance要更新两次，设计有问题，冗余储存了
        tokenDetails[msg.sender].remainingTokens=balance;
        bidders[tokenDetails[msg.sender].personId].remainingTokens=balance;//updating the same balance in bidders map.
        
        Item storage bidItem = items[_itemId]; //确定竞标的奖品
        for(uint i=0; i<_count;i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);   //将竞标者的票放进投票池中，每一票占一个位置 
        }
    }
    
    // Part 2 Task 1. Create a modifier named "onlyOwner" to ensure that only owner is allowed to reveal winners
    //Hint : Use require to validate if "msg.sender" is equal to the "beneficiary".
    modifier onlyOwner {
        // ** Start code here. 2 lines approximately. **
        require(beneficiary == msg.sender);
        _;
        //** End code here. **
    }
    
    
    function revealWinners() public onlyOwner{
        
        /* 
            Iterate over all the items present in the auction.
            If at least on person has placed a bid, randomly select          the winner */

        //todo：这个id应该小于2的，而不是id<3
        for (uint id = 0; id < 3; id++) {  //为三个奖品开奖
            Item storage currentItem=items[id];  //todo: 引用到数组下标3不会报错吗，为什么要多定义一个currentItem，也没必要
            if(currentItem.itemTokens.length != 0){  //有人竞拍才开奖
            // generate random# from block number ，todo：直接用%取余数呢
            uint randomIndex = (block.number / currentItem.itemTokens.length)% currentItem.itemTokens.length; 
            // Obtain the winning tokenId

            uint winnerId = currentItem.itemTokens[randomIndex];  //抽奖
                
            /* Part 1 Task 6. Assign the winners.
            Hint." bidders[winnerId] " will give you the person object with the winnerId.
            you need to assign the address of the person obtained above to winners[id] */

            // ** Start coding here *** 1 line approximately.
            bidders[winnerId].personId = winnerId;
                    
            //** end code here*
                
            }
        }
    } 

  //Miscellaneous methods: Below methods are used to assist Grading. Please DONOT CHANGE THEM.
    function getPersonDetails(uint id) public constant returns(uint,uint,address){
        return (bidders[id].remainingTokens,bidders[id].personId,bidders[id].addr);
    }

}