// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract NFT_USE_PAYMENTS is ERC721Enumerable, Ownable, ReentrancyGuard {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.001 ether;
  uint256 public maxSupply = 30;
  uint256 public maxMintAmount = 30;
  bool public paused = false;
  address public payments;
  //  array which is going to store the shuffled / random numbers
  uint256[] private _randomNumbers;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    address _payments
  )
  ReentrancyGuard() 
   ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    payments=_payments;
    // fill array with numbers from 1 to the maximum value required
    for(uint i = 1; i <= 30; i++) {
    _randomNumbers.push(i);
     }
  }

  function getRandomNumbers() public view returns(uint256 [] memory) {
       return _randomNumbers;
  }
   

  function getRandomNum( address _sender, uint256 _count, uint256 _mintLeft  ) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked( block.difficulty, _sender, block.timestamp, _count, _mintLeft))) % 30;
      return num;
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }


 

 
  // public
  function mint(address _to, uint256 _mintAmount) nonReentrant() public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);

    if (msg.sender != owner()) {
          require(msg.value >= cost * _mintAmount);
    }
   for (uint i = 1; i < _mintAmount + 1; i++) {
     uint256 randomIndex = getRandomNum(_to, supply+i, _mintAmount - i)%(_randomNumbers.length);
         uint256 resultNumber = _randomNumbers[randomIndex];
             _randomNumbers[randomIndex] = _randomNumbers[_randomNumbers.length - 1];
             _randomNumbers.pop();

    _safeMint(_to, resultNumber);

   }

  
  //  for (uint256 i = 1; i <= _mintAmount; i++) {
  //     uint256 randomIndex = getRandomNum(_to, supply+i, _mintAmount-i  );
  //      _safeMint(_to, randomIndex );
  //     }

    
    
   }
    


  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

function setPayments(address newPayments) public onlyOwner {
    payments = newPayments;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function withdraw() nonReentrant() public payable onlyOwner {
    (bool success, ) = payable(payments).call{value: address(this).balance}("");
    require(success);
  }
}
