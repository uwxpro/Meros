#Serialize Verification Test.

#Util lib.
import ../../../../src/lib/Util

#Hash lib.
import ../../../../src/lib/Hash

#BLS lib.
import ../../../../src/lib/BLS

#MinerWallet lib.
import ../../../../src/Database/Merit/MinerWallet

#Verifications lib.
import ../../../../src/Database/Merit/Verifications

#Serialize lib.
import ../../../../src/Network/Serialize/Merit/SerializeVerifications
import ../../../../src/Network/Serialize/Merit/ParseVerifications

#Random standard lib.
import random

#Set the seed to be based on the time.
randomize(int(getTime()))

#Test 20 Verification serializations.
for i in 1 .. 20:
    echo "Testing Verification Serialization/Parsing, iteration " & $i & "."

    var
        #Create a Wallet for signing the Verification.
        verifier: MinerWallet = newMinerWallet()
        #Create a hash.
        hash: Hash[512]
    #Set the hash to a random value.
    for i in 0 ..< 64:
        hash.data[i] = uint8(rand(255))
    #Add the Verification.
    var verif: MemoryVerification = newMemoryVerification(hash)
    verifier.sign(verif)

    #Serialize it and parse it back.
    var verifParsed: MemoryVerification = verif.serialize().parseVerification()

    #Test the serialized versions.
    assert(verif.serialize() == verifParsed.serialize())

    #Test the Verification's properties.
    assert(verif.verifier == verifParsed.verifier)
    assert(verif.hash == verifParsed.hash)
    assert(verif.signature == verifParsed.signature)

echo "Finished the Network/Serialize/Merit/Verifications test."
