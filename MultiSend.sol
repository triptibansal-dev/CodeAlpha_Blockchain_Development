// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSend {

    // Payable function to distribute Ether equally among an array of addresses
    function disperseEther(address payable[] calldata recipients) external payable {
        uint256 totalRecipients = recipients.length;
        
        // Ensure there is at least one recipient and some Ether was sent
        require(totalRecipients > 0, "Must provide at least one recipient address.");
        require(msg.value > 0, "Transaction value must be greater than 0.");

        // Calculate the equal share for each address
        uint256 amountPerRecipient = msg.value / totalRecipients;
        require(amountPerRecipient > 0, "Sent value is too small to divide evenly.");

        // Loop through the array and send the equal share to each address
        for (uint256 i = 0; i < totalRecipients; i++) {
            (bool success, ) = recipients[i].call{value: amountPerRecipient}("");
            require(success, "Ether transfer failed to one of the addresses.");
        }

        // Refund any leftover dust/wei due to division rounding back to the sender
        uint256 leftover = msg.value % totalRecipients;
        if (leftover > 0) {
            (bool refundSuccess, ) = msg.sender.call{value: leftover}("");
            require(refundSuccess, "Refund of leftover Wei failed.");
        }
    }
}