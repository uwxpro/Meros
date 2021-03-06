include MainNetwork

var
  fromMain: Channel[string] #Channel from the 'main' thread to the Interfaces thread.
  toRPC: Channel[JSONNode]  #Channel to the RPC from the GUI.
  toGUI: Channel[JSONNode]  #Channel to the GUI from the RPC.

#Open the channels.
fromMain.open()
toRPC.open()
toGUI.open()

proc mainRPC(
  config: Config,
  functions: GlobalFunctionBox,
  rpc: var RPC
) {.forceCheck: [].} =
  rpc = newRPC(functions, addr toRPC, addr toGUI)

  try:
    asyncCheck rpc.start()
    if config.rpc:
      asyncCheck rpc.listen(config)
  except Exception as e:
    panic("Couldn't start the RPC: " & e.msg)

when not defined(nogui):
  proc mainGUI() {.forceCheck: [].} =
    newGUI(addr fromMain, addr toRPC, addr toGUI, 800, 500)
