lowmemory-ane
=============

A native extension to abolish memory warnings in iOS, a leading cause of excess garbage collection in AIR for certain devices.

This ANE is best for high memory using apps/games that want to target older generation iOS devices on iOS7.

iOS7 will flood the runtime with memory warnings when it reaches a low memory state on these devices, which causes the AIR GC to fire every time. This ANE will trick the iOS wrapper of the AIR runtime into never receiving a memory warning.

Original bug:

https://bugbase.adobe.com/index.cfm?event=bug&id=3649713

Original Workaround: 

http://qiita.com/tosik/items/9f9b474f03777626a42d (THANK YOU to whoever made this!!! どうもありがとう!!!!)

