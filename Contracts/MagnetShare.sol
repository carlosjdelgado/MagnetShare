pragma solidity ^0.4.18;

contract MagnetShare {
    
    Magnet[] magnets;
    
    struct Magnet {
        string magnetLink;
        string shortDescription;
        string longDescription;
        mapping (address => Assessment) assessments;
        int32 rating;
        bool exist;
        address owner;
    }

    struct Assessment {
        int8 rating;
        string comment;
    }

    event MagnetAdded(address owner, uint magnetId, string magnetLink, string shortDescription, string longDescription);
    event MagnetRemoved(uint magnetId);
    event MagnetAssessed(address owner, uint magnetId, string comment, int8 rating);

    function addMagnet(string magnetLink, string shortDescription, string longDescription) public {
        Magnet memory magnet = Magnet(magnetLink, shortDescription, longDescription, 0, true, msg.sender);
        uint magnetsCount = magnets.push(magnet);

        MagnetAdded(msg.sender, magnetsCount - 1, magnetLink, shortDescription, longDescription);
    }

    function removeMagnet(uint magnetId) public {
        require(magnets[magnetId].exist);
        require(magnets[magnetId].owner == msg.sender);
        
        delete magnets[magnetId];
        MagnetRemoved(magnetId);
    }

    function assessMagnet(uint magnetId, int8 rating, string comment) public {
        require(magnets[magnetId].exist);
        require(rating == 1 || rating == -1);

        if (magnets[magnetId].assessments[msg.sender].rating != 0) {
            magnets[magnetId].rating -= magnets[magnetId].assessments[msg.sender].rating;
        }

        magnets[magnetId].rating += rating;
        magnets[magnetId].assessments[msg.sender] = Assessment(rating, comment);
        MagnetAssessed(msg.sender, magnetId, comment, rating);

        if (!isReliable(magnets[magnetId])) {
            removeMagnetBySystem(magnetId);
        }
    }

    function isReliable(Magnet magnet) private pure returns (bool) {
        if (magnet.rating > -50) {
            return true;
        }

        return false;
    }

    function removeMagnetBySystem(uint magnetId) private {
        require(magnets[magnetId].exist);

        delete magnets[magnetId];
        MagnetRemoved(magnetId);
    }
}