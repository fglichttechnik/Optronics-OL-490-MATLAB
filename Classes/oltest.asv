%OL490
cur = what;
path = cur.path;
NET.addAssembly([path '\dll\OLIPluginLibrary.dll'])
NET.addAssembly([path '\dll\OL490LIB.dll'])
NET.addAssembly([path '\dll\OL490_SDK_Dll.dll'])
NET.addAssembly([path '\dll\CyUSB.dll'])
ol_obj = OL490_SDK_Dll.OL490SdkLibrary;
ol_obj.ConnectToOL490(0);
ol_obj.CloseShutter;
ol_obj.LoadAndUseStoredCalibration(3); %750um-Spalt