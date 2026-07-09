// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PollingSystem {

    struct Poll {
        string title;
        string[] options;
        uint256 endTime;
        bool exists;
        mapping(uint256 => uint256) voteCounts;
        mapping(address => bool) hasVoted;
    }

    Poll[] private polls;

    event PollCreated(uint256 indexed pollId, string title, uint256 endTime);
    event VoteCast(uint256 indexed pollId, address indexed voter, uint256 optionIndex);

    function createPoll(string calldata _title, string[] memory _options, uint256 _durationInSeconds) external {
        require(_options.length >= 2, "A poll must have at least 2 options.");
        require(_durationInSeconds > 0, "Duration must be greater than 0.");

        Poll storage newPoll = polls.push();
        newPoll.title = _title;
        newPoll.options = _options;
        newPoll.endTime = block.timestamp + _durationInSeconds;
        newPoll.exists = true;

        emit PollCreated(polls.length - 1, _title, newPoll.endTime);
    }

    function vote(uint256 _pollId, uint256 _optionIndex) external {
        require(_pollId < polls.length, "Poll does not exist.");
        Poll storage currentPoll = polls[_pollId];

        require(block.timestamp < currentPoll.endTime, "The voting deadline for this poll has passed.");
        require(!currentPoll.hasVoted[msg.sender], "You have already voted in this poll.");
        require(_optionIndex < currentPoll.options.length, "Invalid option selected.");

        currentPoll.hasVoted[msg.sender] = true;
        currentPoll.voteCounts[_optionIndex] += 1;

        emit VoteCast(_pollId, msg.sender, _optionIndex);
    }

    function getWinner(uint256 _pollId) external view returns (string memory winningOption, uint256 winningVoteCount) {
        require(_pollId < polls.length, "Poll does not exist.");
        Poll storage currentPoll = polls[_pollId];

        require(block.timestamp >= currentPoll.endTime, "The poll is still active. Wait until it ends.");

        uint256 highestVotes = 0;
        uint256 winningIndex = 0;

        for (uint256 i = 0; i < currentPoll.options.length; i++) {
            if (currentPoll.voteCounts[i] > highestVotes) {
                highestVotes = currentPoll.voteCounts[i];
                winningIndex = i;
            }
        }

        return (currentPoll.options[winningIndex], highestVotes);
    }
}