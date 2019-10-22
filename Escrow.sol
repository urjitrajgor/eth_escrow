pragma solidity ^0.5.0;

contract Escrow{
    
    address payable public payer;
    address payable public payee;
    address payable public middleMan;
    
    uint public contract_activation_time;
    uint public time_to_raise_dispute;
    
    uint public middleManFees;
    uint public payableAmount;
    
    bool public activated_by_payee= false;
    bool public activated_by_payer= false;
    bool public contract_activated = false;
    bool public contract_settled = false;
    bool public dispute_raised = false;
    
    constructor( 
        address payable _payer,
        address payable _payee,
        address payable _middleMan,
        uint _middleManFees,
        uint _payableAmount,
        uint _time_to_raise_dispute) public {
        
        payer = _payer;
        payee = _payee;
        middleMan = _middleMan;
        middleManFees = _middleManFees;
        payableAmount = _payableAmount;
        time_to_raise_dispute = _time_to_raise_dispute;
    }
    
    
    function payment_by_payer() public payable {
        require(msg.value >= (payableAmount+middleManFees) && msg.sender == payer && !contract_activated);
        uint amountPaid = msg.value;
        uint amount_payable_by_payer = payableAmount + middleManFees;
    
        if(amountPaid > amount_payable_by_payer)
        {
            uint returnAmount = amountPaid - amount_payable_by_payer;
            msg.sender.transfer(returnAmount);
        }
        activated_by_payer = true;
        
        if(activated_by_payee == true){
            contract_activation_time = now;
            contract_activated = true;
        }
    }
    
    function payment_by_payee() public payable {
        require(msg.value >= middleManFees && msg.sender == payee && !contract_activated);
        uint amountPaid = msg.value;
        
    
        if(amountPaid > middleManFees)
        {
            uint returnAmount = amountPaid - middleManFees;
            msg.sender.transfer(returnAmount);
        }
        activated_by_payee = true;
        
        if(activated_by_payer == true){
            contract_activation_time = now;
            contract_activated = true;
        }
    }
    
    function withdraw_by_payer() public payable {
        
        require(!contract_activated && activated_by_payer && msg.sender == payer);
        uint amount_payable_by_payer = payableAmount + middleManFees;
        activated_by_payer = true;
        payer.transfer(amount_payable_by_payer);
    }
    
    function withdraw_by_payee() public payable {
        
        require(!contract_activated && activated_by_payee && msg.sender == payee);
        activated_by_payee = true;
        payer.transfer(middleManFees);
    }
    
    function settle() public{
      require(msg.sender == payer);
      payer.transfer(middleManFees);
      uint amount_payable_to_payee = payableAmount + middleManFees;
      payee.transfer(amount_payable_to_payee);
      contract_settled = true;
    }
    
    function forceSettle() public{
      require(now > (contract_activation_time + time_to_raise_dispute)); 
      payer.transfer(middleManFees);
      uint amount_payable_to_payee = payableAmount + middleManFees;
      payee.transfer(amount_payable_to_payee);
      contract_settled = true;
    }
    
    function raiseDispute() public {
        require(msg.sender == payer);
        dispute_raised = true;
    }
    
    function pay_to_payee() public{
        require(msg.sender == middleMan && dispute_raised == true);
        middleMan.transfer(middleManFees);
        uint amount_payable_to_payee = middleManFees + payableAmount;
        payee.transfer(amount_payable_to_payee);
        contract_settled = true;
    }
    
    
    function pay_to_payer() public{
        require(msg.sender == middleMan && dispute_raised == true);
        middleMan.transfer(middleManFees);
        uint amount_payable_to_payer = middleManFees + payableAmount;
        payer.transfer(amount_payable_to_payer);
        contract_settled = true;
    }
    
}