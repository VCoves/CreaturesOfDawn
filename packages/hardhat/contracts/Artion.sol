// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./library/ERC2981PerTokenRoyalties.sol";

contract Artion is ERC721URIStorage, ERC2981PerTokenRoyalties, Ownable {
    using SafeMath for uint256;

    /// @dev Events of the contract
    event Minted(
        uint256 tokenId,
        address beneficiary,
        string tokenUri,
        address minter
    );

    event UpdatePlatformFee(uint256 platformFee);
    event UpdatePlatformFeeRecipient(address payable platformFeeRecipient);

    /// @dev current max tokenId
    uint256 public tokenIdPointer;

    /// @dev TokenID -> Creator address
    mapping(uint256 => address) public creators;

    /// @notice Platform fee
    uint256 public platformFee;

    /// @notice Platform fee recipient
    address payable public feeRecipient;

    /// @notice Contract constructor
    constructor(
        address payable _feeRecipient,
        uint256 _platformFee
    ) ERC721("ART", "Artion") {
        platformFee = _platformFee;
        feeRecipient = _feeRecipient;
    }

    /**
     @notice Mints a NFT AND when minting to a contract checks if the beneficiary is a 721 compatible
     @param _beneficiary Recipient of the NFT
     @param _tokenUri URI for the token being minted
     @return uint256 The token ID of the token that was minted
     */
    function mint(
        address _beneficiary,
        string calldata _tokenUri,
        address _royaltyRecipient,
        uint256 _royaltyValue
    ) external payable returns (uint256) {
        require(msg.value >= platformFee, "Insufficient funds to mint.");

        // Valid args
        _assertMintingParamsValid(_tokenUri, _msgSender());

        tokenIdPointer = tokenIdPointer.add(1);
        uint256 tokenId = tokenIdPointer;

        // Mint token and set token URI
        _safeMint(_beneficiary, tokenId);
        _setTokenURI(tokenId, _tokenUri);

        // set royalty, if the user requested the royalty to be set
        if (_royaltyRecipient != address(0)) {
            _setTokenRoyalty(tokenId, _royaltyRecipient, _royaltyValue);
        }

        // Send FTM fee to fee recipient
        feeRecipient.transfer(msg.value);

        // Associate garment designer
        creators[tokenId] = _msgSender();

        emit Minted(tokenId, _beneficiary, _tokenUri, _msgSender());
        return tokenId;
    }

    /**
     @notice Burns a NFT
     @dev Only the owner or an approved sender can call this method
     @param _tokenId the token ID to burn
     */
    function burn(uint256 _tokenId) external {
        address operator = _msgSender();
        require(
            ownerOf(_tokenId) == operator || isApproved(_tokenId, operator),
            "Only owner or approved"
        );

        // Destroy token mappings
        _burn(_tokenId);

        // Clean up designer mapping
        delete creators[_tokenId];
    }

    function _extractIncomingTokenId() internal pure returns (uint256) {
        // Extract out the embedded token ID from the sender
        uint256 _receiverTokenId;
        uint256 _index = msg.data.length - 32;
        assembly {
            _receiverTokenId := calldataload(_index)
        }
        return _receiverTokenId;
    }

    // Set collection-wide default royalty.
    function setDefaultRoyalty(
        address _receiver,
        uint16 _royaltyPercent
    ) external override onlyOwner {
        _setDefaultRoyalty(_receiver, _royaltyPercent);
    }

    // Set royalty for the given token.
    function setTokenRoyalty(
        uint256 _tokenId,
        address _receiver,
        uint16 _royaltyPercent
    ) external override {
        // only token owner can make the change
        address operator = _msgSender();
        require(
            ownerOf(_tokenId) == operator || isApproved(_tokenId, operator),
            "Only owner or approved"
        );

        _setTokenRoyalty(_tokenId, _receiver, _royaltyPercent);
    }

    /////////////////
    // View Methods /
    /////////////////

    /**
     @notice View method for checking whether a token has been minted
     @param _tokenId ID of the token being checked
     */
    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @dev checks the given token ID is approved either for all or the single token ID
     */
    function isApproved(
        uint256 _tokenId,
        address _operator
    ) public view returns (bool) {
        return
            isApprovedForAll(ownerOf(_tokenId), _operator) ||
            getApproved(_tokenId) == _operator;
    }

    /**
     @notice Method for updating platform fee
     @dev Only admin
     @param _platformFee uint256 the platform fee to set
     */
    function updatePlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
        emit UpdatePlatformFee(_platformFee);
    }

    /**
     @notice Method for updating platform fee address
     @dev Only admin
     @param _platformFeeRecipient payable address the address to sends the funds to
     */
    function updatePlatformFeeRecipient(
        address payable _platformFeeRecipient
    ) external onlyOwner {
        feeRecipient = _platformFeeRecipient;
        emit UpdatePlatformFeeRecipient(_platformFeeRecipient);
    }

    /////////////////////////
    // Internal and Private /
    /////////////////////////

    /**
     @notice Checks that the URI is not empty and the designer is a real address
     @param _tokenUri URI supplied on minting
     @param _designer Address supplied on minting
     */
    function _assertMintingParamsValid(
        string calldata _tokenUri,
        address _designer
    ) internal pure {
        require(
            bytes(_tokenUri).length > 0,
            "_assertMintingParamsValid: Token URI is empty"
        );
        require(
            _designer != address(0),
            "_assertMintingParamsValid: Designer is zero address"
        );
    }

    /// @inheritdoc	ERC165
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721, ERC2981PerTokenRoyalties)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
