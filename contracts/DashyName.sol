pragma solidity ^0.5.6;

import "./ERC721/ERC721.sol";
import "./ERC721/ERC721Enumerable.sol";

contract DashyName is ERC721, ERC721Enumerable {

    struct NameData {
        uint256 tokenId;                       // Unique token id
        address[] ownerHistory;                // History of all previous owners
        string photoCid;                       // IPFS CID of profile image
        string name;                           // Name
        string description;                    // Short description about the name
        uint256 timestamp;                     // Uploaded time
    }
    
    event NameUploaded(uint256 indexed tokenId, string photoCid, string name, string description, uint256 timestamp);

    mapping(uint256 => NameData) private _nameList;

    /**
   * @notice _mint() is from ERC721.sol
   */
    function uploadPhoto(string memory photoCid, string memory name, string memory description) public {
        uint256 tokenId = totalSupply() + 1;

        _mint(msg.sender, tokenId);

        address[] memory ownerHistory;

        NameData memory newData = NameData({
            tokenId : tokenId,
            ownerHistory : ownerHistory,
            photoCid : photoCid,
            name : name,
            description : description,
            timestamp : now
        });

        _nameList[tokenId] = newData;
        _nameList[tokenId].ownerHistory.push(msg.sender);

        emit NameUploaded(tokenId, photoCid, name, description, now);
    }

    /**
   * @notice safeTransferFrom function checks whether receiver is able to handle ERC721 tokens
   *  and then it will call transferFrom function defined below
   */
    function transferOwnership(uint256 tokenId, address to) public returns(uint, address, address, address) {
        safeTransferFrom(msg.sender, to, tokenId);
        uint ownerHistoryLength = _nameList[tokenId].ownerHistory.length;
        return (
            _nameList[tokenId].tokenId,
            //original owner
            _nameList[tokenId].ownerHistory[0],
            //previous owner, length cannot be less than 2
            _nameList[tokenId].ownerHistory[ownerHistoryLength-2],
            //current owner
            _nameList[tokenId].ownerHistory[ownerHistoryLength-1]);
    }

  /**
   * @notice Recommand using transferOwnership, which uses safeTransferFrom function
   * @dev Overided transferFrom function to make sure that every time ownership transfers
   *  new owner address gets pushed into ownerHistory array
   */
    function transferFrom(address from, address to, uint256 tokenId) public {
        super.transferFrom(from, to, tokenId);
        _nameList[tokenId].ownerHistory.push(to);
    }

    function getTotalNameCount() public view returns (uint) {
        return totalSupply();
    }

    function getName(uint tokenId) public view
    returns(uint256, address[] memory, string memory, string memory, string memory, uint256) {
        require(_nameList[tokenId].tokenId != 0, "Name does not exist");
        return (
            _nameList[tokenId].tokenId,
            _nameList[tokenId].ownerHistory,
            _nameList[tokenId].photoCid,
            _nameList[tokenId].name,
            _nameList[tokenId].description,
            _nameList[tokenId].timestamp);
    }
}