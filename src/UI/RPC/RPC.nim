#Errors lib.
import ../../lib/Errors

#RPC object.
import objects/RPCObj
export RPCObj

#RPC modules.
import Modules/SystemModule
import Modules/WalletModule
import Modules/BlockchainModule
import Modules/LatticeModule
import Modules/NetworkModule

#EventEmitter lib.
import ec_events

#Async standard lib.
import asyncdispatch

#Networking standard lib.
import asyncnet

#JSON standard lib.
import json

#Constructor.
proc newRPC*(
    events: EventEmitter,
    toRPC: ptr Channel[JSONNode],
    toGUI: ptr Channel[JSONNode]
): RPC {.raises: [SocketError].} =
    result = newRPCObject(
        events,
        toRPC,
        toGUI
    )

#Handle a message.
proc handle*(
    rpc: RPC,
    msg: JSONNode,
    reply: proc (json: JSONNode)
) {.raises: [KeyError].} =
    #Handle the data.
    case msg["module"].getStr():
        of "system":
            rpc.systemModule(msg, reply)
        of "wallet":
            rpc.walletModule(msg, reply)
        of "blockchain":
            rpc.blockchainModule(msg, reply)
        of "lattice":
            rpc.latticeModule(msg, reply)
        of "network":
            rpc.networkModule(msg, reply)
        else:
            reply(
                %* {
                    "error": "Unrecognized module."
                }
            )

#Start up the RPC (Channels; for the GUI).
proc start*(rpc: RPC) {.async.} =
    #Define the data outside of the loop.
    var data: tuple[dataAvailable: bool, msg: JSONNode]

    while rpc.listening:
        #Allow other async code to execute.
        await sleepAsync(1)

        #Try to get a message from the channel.
        data = rpc.toRPC[].tryRecv()
        #If there's no data, continue.
        if not data.dataAvailable:
            continue

        #Handle the data.
        rpc.handle(
            data.msg,
            proc (json: JSONNode) {.raises: [ChannelError].} =
                try:
                    rpc.toGUI[].send(json)
                except:
                    raise newException(ChannelError, "Couldn't send data to the GUI.")
        )

#Start up the RPC (Socket; for remote connections).
proc listen*(rpc: RPC, port: uint) {.async.} =
    #Start listening.
    rpc.server.setSockOpt(OptReuseAddr, true)
    rpc.server.bindAddr(Port(port))
    rpc.server.listen()

    #Define a new var for the client and data.
    var
        client: AsyncSocket
        data: string
        json: JSONNode

    #Accept new connections infinitely.
    while (rpc.listening) and (not rpc.server.isClosed()):
        #This is in a try/catch since ending the server while accepting a new Client will throw an Exception.
        try:
            #Accept a new client.
            client = await rpc.server.accept()

            #Handle the client.
            while not client.isClosed():
                #Read in a line.
                data = await client.recvLine()
                #If the line length is 0, the client is invalid. Stop handling it.
                if data.len == 0:
                    break

                #Parse the JSON.
                try:
                    json = parseJSON(data)
                except:
                    json = %* {
                        "error": "Invalid RPC payload."
                    }
                    toUgly(data, json)
                    asyncCheck client.send(data & "\r\n")
                    continue

                #Handle the data.
                rpc.handle(
                    json,
                    proc (res: JSONNode) =
                        #Convert the returned JSON to a string.
                        var resStr: string
                        toUgly(resStr, res)

                        #Send it.
                        asyncCheck client.send(resStr & "\r\n")
                )
        except:
            continue

#Shutdown.
func shutdown*(rpc: RPC) {.raises: [].} =
    rpc.listening = false
