// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BatchContract.sol";

contract TraceabilityContract is BatchContract {
    struct TraceabilityData {
        uint256 batchId;
        uint256 lotId;
        address owner;
        uint256 timestamp;
        string location;
    }

    mapping(uint256 => mapping(uint256 => TraceabilityData[])) public traceabilityData;

    event TraceabilityDataAdded(uint256 indexed batchId, uint256 indexed lotId, address owner, uint256 timestamp, string location);

    function addTraceabilityData(uint256 _batchId, uint256 _lotId, string memory _location) internal {
        traceabilityData[_batchId][_lotId].push(TraceabilityData(_batchId, _lotId, msg.sender, block.timestamp, _location));
        emit TraceabilityDataAdded(_batchId, _lotId, msg.sender, block.timestamp, _location);
    }

    function getTraceabilityData(uint256 _batchId, uint256 _lotId) public view returns (TraceabilityData[] memory) {
        return traceabilityData[_batchId][_lotId];
    }
}