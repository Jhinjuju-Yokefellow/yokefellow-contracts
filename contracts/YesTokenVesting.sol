// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract YesTokenVesting {
    address public immutable token;
    address public immutable recipient;

    uint256 public constant TOTAL_RELEASES = 22;
    uint256 public constant TOKENS_PER_RELEASE = 39_674_006 * 1e18;
    uint256 public constant RELEASE_INTERVAL = 365 days;

    uint256 public startTime;
    uint256 public releasesClaimed;

    event TokensReleased(uint256 indexed releaseNumber, uint256 amount);

    constructor(address _token, address _recipient) {
        token = _token;
        recipient = _recipient;
        startTime = block.timestamp;
    }

    function release() external {
        require(releasesClaimed < TOTAL_RELEASES, "All tokens released");

        uint256 elapsed = block.timestamp - startTime;
        uint256 eligibleReleases = elapsed / RELEASE_INTERVAL;

        require(eligibleReleases > releasesClaimed, "No tokens available yet");

        uint256 pending = eligibleReleases - releasesClaimed;
        if (releasesClaimed + pending > TOTAL_RELEASES) {
            pending = TOTAL_RELEASES - releasesClaimed;
        }

        uint256 amount = pending * TOKENS_PER_RELEASE;
        releasesClaimed += pending;

        require(IERC20(token).transfer(recipient, amount), "Token transfer failed");

        emit TokensReleased(releasesClaimed, amount);
    }

    function nextReleaseTime() external view returns (uint256) {
        return startTime + (releasesClaimed + 1) * RELEASE_INTERVAL;
    }

    function remainingReleases() external view returns (uint256) {
        return TOTAL_RELEASES - releasesClaimed;
    }
}
