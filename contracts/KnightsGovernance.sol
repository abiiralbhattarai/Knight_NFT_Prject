// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

import "./DemonNft.sol";
import "./KnightsNft.sol";
import "./knightGovernanceQuorum.sol";

contract knightGovernance is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    knightGovernanceQuorum,
    GovernorTimelockControl
{
    KnightsNft private knightNft;
    uint256 private _quorum;

    constructor(
        KnightsNft _knightNftContract,
        TimelockController _timelock
    )
        Governor("Knight Governance")
        GovernorSettings(1, 40320, 1e18) // initialVotingDelay = 1 block, initialVotingPeriod = ~1 week, initialProposalThreshold = 2
        GovernorTimelockControl(_timelock)
        knightGovernanceQuorum(20)
    {
        knightNft = _knightNftContract;
    }

    function _getVotes(
        address account,
        uint256 blockNumber,
        bytes memory /* params */
    ) internal view override returns (uint256) {
        uint256 knightVotes = knightNft.getPastVotes(account, blockNumber);

        return knightVotes;
    }

    fallback() external payable {}

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(
        uint256 blockNumber
    )
        public
        view
        override(IGovernor, knightGovernanceQuorum)
        returns (uint256)
    {
        return
            (knightNft.getPastTotalSupply(blockNumber) *
                quorumNumerator(blockNumber)) / quorumDenominator();
    }

    function state(
        uint256 proposalId
    )
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override(Governor, IGovernor) returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(Governor, GovernorTimelockControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }
}
