// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract contractCF {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 createdAt;
        uint256 amountCollected;
        string image;
        bool isActive;
        address[] donators;
        uint256[] donations;
    }
    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        uint256 _createdAt,
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.createdAt = _createdAt;
        campaign.amountCollected = 0;
        campaign.image = _image;
        campaign.isActive = true;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        require(
            campaigns[_id].deadline > block.timestamp,
            "The funding period has expired."
        );
        require(
            campaigns[_id].isActive == true,
            "The campaign is no longer active."
        );

        uint256 amount = msg.value;

        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

        (bool sent,) = payable(campaign.owner).call{value : amount}("");

        if(sent) {
            campaign.amountCollected += amount;
        }
    }

    function getDonators(uint256 _campaignId)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        return (
            campaigns[_campaignId].donators,
            campaigns[_campaignId].donations
        );
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        //[{}, {}, {}]
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            allCampaigns[i] = campaigns[i];
        }
        return allCampaigns;
    }

    function activeStatusCampaign(
        uint256 _id,
        address _owner,
        bool _isActive
    ) public {
        require(
            campaigns[_id].owner == _owner,
            "You are not the owner of this campaign."
        );
        campaigns[_id].isActive = _isActive;
    }

    function restoreDataFromOldContract(address _oldContractAddress) public {
        contractCF oldContract = contractCF(_oldContractAddress);
        Campaign[] memory oldCampaigns = oldContract.getCampaigns();

    }
}