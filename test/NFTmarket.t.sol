// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NFTmarket} from "../src/NFTmarket.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {BaseERC20} from "../src/ERC20.sol";

contract CounterTest is Test {
    NFTmarket public nftmarket;
    BaseERC20 erc20;
    ERC721 erc721;
    address alice; // NFT seller
    address bob;  // NFT buyer
    function setUp() public {
        erc20 = new BaseERC20();
        erc721 = new ERC721("rain","rayer");
        nftmarket = new NFTmarket(address(erc20), address(erc721));
        alice = makeAddr("alice");
        bob = makeAddr("bob");

    }

    function test_erc721_mintNFT()public {
        vm.prank(alice);
        erc721._mint(alice, 1);
        assertEq(erc721.ownerOf(1), alice);
        
    }

        // 测试将nft上架到market之前，你需要在nftcontract里面own the nft
    function test_list()public {
        test_erc721_mintNFT();
        uint256 price = 1 ether;
        uint256 tokenId = 1;
        vm.prank(alice);
        nftmarket.list(tokenId, price);

        (uint256 _price,address _seller) = nftmarket.listings(tokenId);
        assertEq(_price, price);
        assertEq(_seller, alice);
    }

    function test_erc721_approve()public {
        test_list();
        vm.prank(alice);
        erc721._approve(address(nftmarket), 1, alice);
        assertEq(erc721._tokenApprovals(1), address(nftmarket));
    }



    function test_mint()public {
        erc20._mint(bob, 1 ether);
        assertEq(erc20.balances(bob), 1 ether);
    }

    function test_approval_in_ERC20()public {
        test_mint();
        vm.prank(bob);
        erc20.approve(address(nftmarket), 1 ether);
        assertEq(erc20.balances(bob), 1 ether);
        assertEq(erc20.allowance(bob, address(nftmarket)), 1 ether);
    }



    //转账之前，需要在erc20中mint bob的token
    function test_buy() public{
        // 先上架，并在721中aprove给nftmarket
        test_erc721_approve();
        // ERC20中允许alice调用bob的余额
        test_approval_in_ERC20();
        // bob在nftmarket中购买alice的nft
        vm.prank(bob);
        nftmarket.buy(1);
        assertEq(erc721.ownerOf(1), bob);
        assertEq(erc20.balances(bob), 0);
        assertEq(erc20.allowance(bob, alice), 0);
        assertEq(erc20.balances(alice), 1 ether);
        // NFT交易后，alice再想上架NFT则会报错
        vm.expectRevert("You are not the owner");
        vm.prank(alice);
        nftmarket.list(1, 1 ether);
    }


}
