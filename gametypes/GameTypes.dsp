# Microsoft Developer Studio Project File - Name="GameTypes" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Generic Project" 0x010a

CFG=GameTypes - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "GameTypes.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "GameTypes.mak" CFG="GameTypes - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "GameTypes - Win32 Debug" (based on "Win32 (x86) Generic Project")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Earth2160/Scripts/GameTypes", KTAAAAAA"
# PROP Scc_LocalPath "."
MTL=midl.exe
# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# Begin Target

# Name "GameTypes - Win32 Debug"
# Begin Source File

SOURCE=.\AgentsDialogs.ech
# End Source File
# Begin Source File

SOURCE=.\CommonGameType.ech
# End Source File
# Begin Source File

SOURCE=.\DestroyEnemyStructures.ec
# Begin Custom Build
InputPath=.\DestroyEnemyStructures.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC2160.bat $(InputPath) $(InputPath)o

# End Custom Build
# End Source File
# Begin Source File

SOURCE=.\DestroyEnemyStructuresnowin.ec
# End Source File
# Begin Source File

SOURCE=.\KillHero.ec
# Begin Custom Build
InputPath=.\KillHero.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC2160.bat $(InputPath) $(InputPath)o

# End Custom Build
# End Source File
# Begin Source File

SOURCE=.\Peace.ec
# Begin Custom Build
InputPath=.\Peace.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC2160.bat $(InputPath) $(InputPath)o

# End Custom Build
# End Source File
# Begin Source File

SOURCE=.\UncleSam.ec
# Begin Custom Build
InputPath=.\UncleSam.ec

"$(InputPath)o" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	EarthC2160.bat $(InputPath) $(InputPath)o

# End Custom Build
# End Source File
# End Target
# End Project
