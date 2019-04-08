#Errors lib, providing easy access to ForceCheck and defining all out custom errors.

#ForceCheck lib.
import ForceCheck
export ForceCheck

#DB lib.
import mc_lmdb
#Export its custom Error type.
export LMDBError

type
    #lib Errors.
    RandomError* = object of Exception #Used when the RNG fails.
    ArgonError*  = object of Exception #Used when Argon fails.
    BLSError*    = object of Exception #Used when BLS fails.
    SodiumError* = object of Exception #Used when LibSodium fails.
    EventError*  = object of Exception #Used when the EventEmiiter fails.

    #Wallet Errors.
    EdSeedError*      = object of Exception #Used when passed an invalid Ed25519 Seed.
    EdPublicKeyError* = object of Exception #Used when passed an invalid Ed25519 Public Key.
    AddressError*     = object of Exception #Used when passed an invalid Address.

    #Database/common Errors.
    MerosIndexError* = object of Exception #KeyError, yet not `of ValueError`. It's prefixed with Meros since Nim provides an IndexError.

    #Database/Filesystem Errors.
    MemoryError* = object of Exception #Used when alloc/dealloc fails.

    #Database/Lattice Errors.
    MintError* = object of Exception #Used when Minting MR fails.

    #Network Errors.
    AsyncError*           = object of Exception #Used when async code fails.
    SocketError*          = object of Exception #Used when a socket fails.
    SyncConfigError*      = object of Exception #Used when a Socket which isn't set for syncing is used to sync.
    DataMissingError*     = object of Exception #Used when a Client is missing requested data.
    InvalidResponseError* = object of Exception #Used when a Client sends an Invalid Response.

    #UI/RPC Errors.
    ChannelError*  = object of Exception #Used when a Channel fails.
    PersonalError* = object of Exception #Used when the Wallet in the RPC fails.

    #UI/GUI Errors.
    WebViewError* = object of Exception #Used when Webview fails.
