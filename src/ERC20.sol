// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
    function balanceOf(address _owner) external  view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external  payable returns (bool success);
    function approve(address _spender, uint256 _value) external  returns (bool success);
    function allowance(address _owner, address _spender) external  view returns (uint256 remaining);
}


contract BaseERC20 is IERC20{
    string public name; 
    string public symbol; 
    uint8 public decimals; 

    uint256 public totalSupply; 

    mapping (address => uint256)public balances; 

    mapping (address => mapping (address => uint256)) public allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * 10 ** uint256(decimals); 
        balances[msg.sender] = totalSupply;

    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender]>= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }


    function transferFrom(address _from, address _to, uint256 _value) public payable returns (bool success) {
        require(allowances[_from][msg.sender] >= _value, "ERC20: allowance transfer amount exceeds allowance");
        require(balances[_from]>= _value, "ERC20: balance transfer amount exceeds balance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balances[msg.sender]>=_value,"Not enough balance");
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {  
        return allowances[_owner][_spender];
    }

    function _mint(address account, uint256 value) public {
        require(account!= address(0),"User is empty!");
        balances[account] += value;
        totalSupply+=value;
    }

    function _burn(address account, uint256 value) public {
        require(account!= address(0),"User is empty!");
        balances[account]-=value;
        totalSupply-=value;
    }

    

}