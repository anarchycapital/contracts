//SPDX-License-Identifier: Unlicense
pragma solidity >0.4.23 <0.9.0;

contract Ipfs {
    string public name = "Ipfs file manager";
    uint256 public fileCount = 0;

    mapping(uint256 => File) public files;

    string ipfsHash;

    function sendHash(string memory x) public {
        ipfsHash = x;
    }

    function getHash() public view returns (string memory) {
        return ipfsHash;
    }

     struct File {
        uint256 fileId;
        string filePath;
        uint256 fileSize;
        string fileType;
        string fileName;
        address payable uploader;
    }

    event FileUploaded(
        uint256 fileId,
        string filePath,
        uint256 fileSize,
        string fileType,
        string fileName,
        address payable uploader
    );

      function uploadFile(
        string memory _filePath,
        uint256 _fileSize,
        string memory _fileType,
        string memory _fileName
    ) public {
        require(bytes(_filePath).length > 0);
        require(bytes(_fileType).length > 0);
        require(bytes(_fileName).length > 0);
        require(msg.sender != address(0));
        require(_fileSize > 0);
        
        // since solidity mappings
        // do not have a lenght attribute
        // the simplest way to control the amount 
        // of files is using a counter
        fileCount++;

        files[fileCount] = File(
            fileCount,
            _filePath,
            _fileSize,
            _fileType,
            _fileName,
            payable(msg.sender)
        );

           emit FileUploaded(
            fileCount,
            _filePath,
            _fileSize,
            _fileType,
            _fileName,
            payable(msg.sender)
        );
        
    

}
}