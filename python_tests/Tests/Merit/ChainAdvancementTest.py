#Types.
from typing import Dict, List, IO, Any

#Merit classes.
from python_tests.Classes.Merit.Block import Block
from python_tests.Classes.Merit.Blockchain import Blockchain

#TestError Exception.
from python_tests.Tests.TestError import TestError

#RPC class.
from python_tests.Meros.RPC import RPC

#JSON standard lib.
import json

def ChainAdvancementTest(
    rpc: RPC
) -> None:
    #Blockchain.
    blockchain: Blockchain = Blockchain(
        b"MEROS_DEVELOPER_NETWORK",
        60,
        int("FAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 16)
    )
    #Blocks.
    bbFile: IO[Any] = open("python_tests/Vectors/Merit/BlankBlocks.json", "r")
    blocks: List[Dict[str, Any]] = json.loads(bbFile.read())
    bbFile.close()

    #Publish Blocks.
    for jsonBlock in blocks:
        #Parse the Block.
        block: Block = Block.fromJSON(jsonBlock)

        #Add it locally.
        blockchain.add(block)

        #Publish it.
        rpc.call("merit", "publishBlock", [block.serialize().hex()])

        #Verify the difficulty.
        if blockchain.difficulty != int(rpc.call("merit", "getDifficulty"), 16):
            raise TestError("Difficulty doesn't match.")

        #Verify the Block.
        if rpc.call("merit", "getBlock", [block.header.nonce]) != jsonBlock:
            raise TestError("Block doesn't match.")

    #Verify the height.
    if rpc.call("merit", "getHeight") != len(blocks) + 1:
        raise TestError("Height doesn't match.")
