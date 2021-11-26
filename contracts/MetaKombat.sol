// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// helper function for encoding data
import "./libraries/Base64.sol";

contract MetaKombat is ERC721 {

    // basic attributes for now
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    using Counters for Counters.Counter;
    // TODO: wait really, what's point of the above line then
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    // mapping from tokenId to the HERO characters and owners to their tokenIds they own
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(address => uint256 []) public nftHolders;

    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);


    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;

    constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    string memory bossName,
    string memory bossImageURI,
    uint bossHp,
    uint bossAttackDamage
    // This is the name and symbol for our token, ex Ethereum and ETH. I just call mine
    // Heroes and HERO. Remember, an NFT is just a token!
  )
  ERC721("Heroes", "HERO")
  {
      bigBoss = BigBoss({
          name: bossName,
          imageURI: bossImageURI,
          hp: bossHp,
          maxHp: bossHp,
          attackDamage: bossAttackDamage
      });

        console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);


      for(uint i=0; i < characterNames.length; i+=1) {
          defaultCharacters.push(CharacterAttributes({
                characterIndex: i,
                name: characterNames[i],
                imageURI: characterImageURIs[i],
                hp: characterHp[i],
                maxHp: characterHp[i],
                attackDamage: characterAttackDmg[i]
          }));

          CharacterAttributes memory c = defaultCharacters[i];
          console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
      }

      _tokenIds.increment();
  }

  function mintCharacterNFT(uint _characterIndex) external {
      // starts at 1
      uint256 newItemId = _tokenIds.current();

      _safeMint(msg.sender, newItemId);

      nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
      });

      console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);


      nftHolders[msg.sender].push(newItemId);
      _tokenIds.increment();

        // for(uint i=0; i < nftHolders[msg.sender].length; i++) {
        //     console.log("My minted NFT character id #%s", nftHolders[msg.sender][i]);
        // }
      

      emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
      CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

      string memory strHp = Strings.toString(charAttributes.hp);
      string memory strMaxHp = Strings.toString(charAttributes.maxHp);
      string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

      string memory json = Base64.encode(
          bytes(
              string(
                  abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        ' -- NFT #: ',
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "ipfs://',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,'} ]}'
                  )
              )
          )
      );

      string memory output = string(
          abi.encodePacked("data:application/json;base64,", json)
      );
        
      return output;
  }

  function attackBoss(uint256 _characterIndex) public {

      console.log("attack called");

      require(_characterIndex >= 0 && _characterIndex < 3, "Error: character index out of bounds");
      uint256 nftTokenIdOfPlayer = nftHolders[msg.sender][_characterIndex];
      CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
      console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
      console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

      require(player.hp > 0, "Error: character must have HP to attack boss.");
      require(bigBoss.hp > 0, "Error: boss have HP to attack character.");

      if (bigBoss.hp < player.attackDamage) {
          bigBoss.hp = 0;
      } else {
          bigBoss.hp = bigBoss.hp - player.attackDamage;
      }

      // Allow boss to attack player.
    if (player.hp < bigBoss.attackDamage) {
        player.hp = 0;
    } else {
        player.hp = player.hp - bigBoss.attackDamage;
    }
  
    // Console for ease.
    console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
    console.log("Boss attacked player. New player hp: %s\n", player.hp);

    emit AttackComplete(bigBoss.hp, player.hp);
    
  }

  function checkIfUserHas3NFTs() public view returns (CharacterAttributes[] memory) {
      uint256[] storage userNftTokenId = nftHolders[msg.sender];

      if (userNftTokenId.length == 3) {
          // TODO: error
          CharacterAttributes[] myFighters;
          for (uint i=0; i< userNftTokenId.length;i++){
              myFighters.push(nftHolderAttributes[userNftTokenId[i]]);
          }
          return myFighters;
      } else {
          CharacterAttributes[] memory emptyStruct;
          return emptyStruct;
      }
  }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

}
