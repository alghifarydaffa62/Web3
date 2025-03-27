// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Danantiri {
    enum ProgramStatus {
        INACTIVE, REGISTERED, ALLOCATED
    }

    struct Program {
        uint256 id;
        string name;
        string desc;
        uint256 targetFund;
        uint256 allocated;
        address pic;
        ProgramStatus status;
    }

    struct History {
        uint256 timestamp;
        string history;
        uint256 amount;
    }

    address public owner;
    Program[] public programs;
    uint256 public totalFund;
    uint256 public totalAllocated;
    mapping(uint256 => History[]) public programHistories;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier onlyPIC(uint256 _programid) {
        require(msg.sender == programs[_programid].pic, "You are not the PIC");
        _;
    }

    event programCreated(uint256 indexed programID, string name, uint256 target, address pic);
    event programUpdated(uint256 indexed programID, string name, string desc, address pic);
    event FundSent(address indexed sender, uint256 amount);
    event FundAllocated(uint256 indexed programID, uint256 amount);
    event FundWithdrawn(uint256 indexed programID, address indexed pic, string history, uint256 amount);

    function createProgram(
        string calldata _name, 
        string calldata _desc, 
        uint256 target, 
        address _pic) external onlyOwner() {
            require(bytes(_name).length > 0, "Invalid name!");
            require(bytes(_desc).length > 0, "Invalid desc!");
            require(target > 0, "Target must be greater than 0!");
            require(_pic != address(0), "Address PIC invalid!");

            Program memory program = Program({
                id: programs.length,
                name: _name,
                desc: _desc,
                targetFund: target,
                allocated: 0,
                pic: _pic,
                status: ProgramStatus.REGISTERED
            });

            programs.push(program);
            emit programCreated(program.id, program.name, program.targetFund, program.pic);
    }

    function updateProgram(
        uint256 _programId,
        string calldata _name,
        string calldata _desc,
        address _pic        
    ) external onlyOwner {
        require(_programId < programs.length, "Invalid ID!");
        require(bytes(_name).length > 0, "Invalid name!");
        require(bytes(_desc).length > 0, "Invalid description!");
        require(_pic != address(0), "Invalid PIC address!");

        Program storage program = programs[_programId];
        program.name = _name;
        program.desc = _desc;
        program.pic = _pic;
        emit programUpdated(_programId, _name, _desc, _pic);
    }

    function showAllPrograms() external view returns(Program[] memory) {
        return programs;
    }

}
