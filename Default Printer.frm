VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmDefaultPrinter 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Default Printer Selection"
   ClientHeight    =   3195
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4680
   Icon            =   "Default Printer.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.ImageList imlLV2 
      Left            =   3960
      Top             =   1920
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   14
      ImageHeight     =   13
      MaskColor       =   16711935
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   2
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Default Printer.frx":08CA
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Default Printer.frx":0B58
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin VB.CheckBox chkRestore 
      Caption         =   "Set back to original on exit"
      Height          =   255
      Left            =   120
      TabIndex        =   5
      ToolTipText     =   "Return the default printer to what it was when this application started"
      Top             =   2880
      Value           =   1  'Checked
      Width           =   2655
   End
   Begin VB.CheckBox chkConfirm 
      Caption         =   "Confirm before setting default"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   2520
      Value           =   1  'Checked
      Width           =   2655
   End
   Begin MSComctlLib.ListView lvwPrinter 
      Height          =   1455
      Left            =   0
      TabIndex        =   1
      Top             =   360
      Width           =   4695
      _ExtentX        =   8281
      _ExtentY        =   2566
      View            =   3
      Sorted          =   -1  'True
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      AllowReorder    =   -1  'True
      Checkboxes      =   -1  'True
      FullRowSelect   =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   1
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Printer"
         Object.Width           =   7673
      EndProperty
   End
   Begin VB.CommandButton cmdSet 
      Caption         =   "Set Default Printer"
      Enabled         =   0   'False
      Height          =   375
      Left            =   1553
      TabIndex        =   2
      ToolTipText     =   "Click to set selected printer as default"
      Top             =   1920
      Width           =   1575
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "E&xit"
      Height          =   375
      Left            =   3720
      TabIndex        =   3
      Top             =   2760
      Width           =   855
   End
   Begin MSComctlLib.ImageList imlLV1 
      Left            =   3360
      Top             =   1920
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   12
      ImageHeight     =   12
      MaskColor       =   16711935
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   2
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Default Printer.frx":0DE6
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "Default Printer.frx":0FE8
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin VB.Label lblPrinters 
      Caption         =   "Choose From Available Printers:"
      Height          =   255
      Left            =   60
      TabIndex        =   0
      Top             =   120
      Width           =   3735
   End
End
Attribute VB_Name = "frmDefaultPrinter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'  ___________________________                          _______
' / frmDefaultPrinter         \________________________/ v1.00 |
'
' Program Description:  Set default printer at runtime.
'                       Something like this is useful because
'                       the VB DataReport always prints to the
'                       default printer.  If, for example, you
'                       have two separate reports and want each
'                       one to go to a different printer without
'                       prompting the user every time they want
'                       to print, you can have them set up which
'                       printer to use for each report and then
'                       programmatically change it for them at
'                       runtime.  Assumes user has appropriate
'                       registry and printer permissions.
'
'     Original Author:  CubeSolver
'        Date Created:  March 18, 2003
'       Date Released:
'        OS Tested On:  Windows NT 4 SP 6a, Windows XP Pro
'
' --------------------------------------------------------------
' Revision History
'
' Version  Who         Date          Comment
' -------  ----------  ------------  ---------------------------
'
' \____________________________________________________________/

Private sOrigPrinter As String    ' Name of the original printer when this app started
Private sPath As String           ' Registry location of the printers

' Registry location for this app
Private Const APPREGPATH As String = "Software\Default Printer Select Tool"

' For showing the sort order
Private Const LVM_FIRST As Long = &H1000
Private Const LVM_GETHEADER As Long = (LVM_FIRST + 31)

Private Const HDI_IMAGE As Long = &H20
Private Const HDI_FORMAT As Long = &H4

Private Const HDF_BITMAP_ON_RIGHT As Long = &H1000
Private Const HDF_IMAGE As Long = &H800
Private Const HDF_STRING As Long = &H4000

Private Const HDM_FIRST As Long = &H1200
Private Const HDM_SETITEM As Long = (HDM_FIRST + 4)

Private Type HD_ITEM
  lMask As Long
  cxy As Long
  pszText As String
  hbm As Long
  cchTextMax As Long
  lFmt As Long
  lParam As Long
  lImage As Long
  lOrder As Long
End Type

Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, lParam As Any) As Long
Private Sub CheckListViewForValue(ByRef lvwX As MSComctlLib.ListView, ByVal sValue As String)
  ' Find given value within a listview and mark its checkbox
  Dim itmX As MSComctlLib.ListItem

  Set itmX = lvwX.FindItem(sValue, lvwText)

  If Not itmX Is Nothing Then  ' No match
    Call DeselectAll(lvwX)
    itmX.EnsureVisible
    itmX.Selected = True
    itmX.Checked = True
'    lvwX.SetFocus
    Set itmX = Nothing
  End If
End Sub
Private Sub DeselectAll(ByRef lvwX As MSComctlLib.ListView)
  ' Make sure no items are checked in the listview
  Dim lLoop As Long

  For lLoop = 1 To lvwX.ListItems.Count
    lvwX.ListItems(lLoop).Checked = False
  Next
End Sub
Private Sub SetDefaultPrinter(ByVal sPrinter As String)
  ' Save the default printer name in the registry for Windows to read
  Call SaveString(HKEY_CURRENT_USER, sPath, "Device", sPrinter)

  ' Make sure no printers are checked in the list
  Call DeselectAll(lvwPrinter)

  ' Now select the current default printer
  Call CheckListViewForValue(lvwPrinter, sPrinter)

  cmdSet.Enabled = False
End Sub
Private Sub ShowHeaderIcon(ByRef lvwX As MSComctlLib.ListView, ByVal lIconNo As Long)
  ' From http://www.mvps.org/vbnet/code/comctl/lvheaderimage.htm
  ' Modified by CubeSolver
  Dim lHeader As Long
  Dim tHD As HD_ITEM

  ' Get a handle to the listview header component
  lHeader = SendMessage(lvwX.hWnd, LVM_GETHEADER, 0, 0)

  ' Set up the required structure members
  With tHD
    .lMask = HDI_IMAGE Or HDI_FORMAT
    .lFmt = HDF_STRING Or HDF_IMAGE Or HDF_BITMAP_ON_RIGHT
    .lImage = lIconNo
  End With

  ' Modify the header
  Call SendMessage(lHeader, HDM_SETITEM, 0, tHD)
End Sub
Private Sub cmdExit_Click()
  Unload Me
End Sub
Private Sub cmdSet_Click()
  Dim sNewDefault As String

  If lvwPrinter.ListItems.Count > 0 Then    ' Make sure we have printers
    ' Make sure a printer has been selected
    If lvwPrinter.SelectedItem.Index > 0 And lvwPrinter.SelectedItem.Checked = False Then
      ' Get the name of the new printer to be set as default
      sNewDefault = lvwPrinter.ListItems(lvwPrinter.SelectedItem.Index)
      ' Confirm with the user if the Confirm checkbox is checked
      If chkConfirm.Value = vbChecked Then
        If MsgBox("You are about to set" & vbCrLf & sNewDefault & vbCrLf & _
                  "as the default printer." & vbCrLf & vbCrLf & "Are you sure you want to do this?", _
                  vbYesNo + vbDefaultButton2, "Set Default Printer?") = vbNo Then
          Exit Sub
        End If
      End If
      Call SetDefaultPrinter(sNewDefault)   ' If we made it this far, set the printer
    End If
  End If
End Sub
Private Sub Form_Load()
  Dim prtX As VB.Printer
  Dim itmX As MSComctlLib.ListItem

  ' Determine location in registry according to OS
  Select Case WinVer
    Case "NT", "00", "XP"
      sPath = "Software\Microsoft\Windows NT\CurrentVersion\Windows"
    Case "95", "98", "ME"
      sPath = "Software\Microsoft\Windows\CurrentVersion\Windows"
  End Select

  ' Make sure printers exist
  If Printers.Count > 0 Then
    ' Create a list of all printers available to this machine
    For Each prtX In VB.Printers
      Set itmX = lvwPrinter.ListItems.Add(, , prtX.DeviceName & "," & prtX.DriverName & "," & prtX.Port)
    Next

    lvwPrinter.ColumnHeaderIcons = imlLV1       ' For Windows style sorting arrow use imlLV1
'    lvwPrinter.ColumnHeaderIcons = imlLV2       ' For WinZip type sorting arrow use imlLV2

    If lvwPrinter.ListItems.Count > 1 Then      ' If there is more than one printer...
      Call ShowHeaderIcon(lvwPrinter, 0)        ' place an arrow at the top of the list
    End If
  End If

  ' Find out if the application crashed and if so, if the default printer needs to be restored
  If GetString(HKEY_CURRENT_USER, APPREGPATH, "Shutdown Properly") = "0" And _
    GetString(HKEY_CURRENT_USER, APPREGPATH, "Printer Name") <> GetString(HKEY_CURRENT_USER, sPath, "Device") Then
    sOrigPrinter = GetString(HKEY_CURRENT_USER, APPREGPATH, "Printer Name")
    If MsgBox("It appears that the default printer select tool crashed and has saved" & vbCrLf & _
              sOrigPrinter & vbCrLf & "as the original default printer." & vbCrLf & vbCrLf & _
              "Do you want to restore it now?", vbQuestion + vbYesNo + vbDefaultButton2, "Restore Original Default Printer?") = vbYes Then
      Call SaveString(HKEY_CURRENT_USER, sPath, "Device", sOrigPrinter)
    End If
  End If

  ' Remember the current default printer to allow for restoring after a crash
  sOrigPrinter = GetString(HKEY_CURRENT_USER, sPath, "Device")
  Call SaveString(HKEY_CURRENT_USER, APPREGPATH, "Printer Name", sOrigPrinter)
  Call SaveString(HKEY_CURRENT_USER, APPREGPATH, "Shutdown Properly", "0")

  ' Find the current default printer in the printers list
  Call CheckListViewForValue(lvwPrinter, sOrigPrinter)

  ' Restore the Confirm change setting
  chkConfirm.Value = Val(GetString(HKEY_CURRENT_USER, APPREGPATH, "Confirm"))

  ' Clean up
  Set prtX = Nothing
  Set itmX = Nothing
End Sub
Private Sub Form_Unload(Cancel As Integer)
  ' Restore original default printer if so desired
  If chkRestore.Value = vbChecked Then
    Call SaveString(HKEY_CURRENT_USER, sPath, "Device", sOrigPrinter)
  End If

  ' Indicate in the registry that we didn't crash and the original printer name is not needed
  Call SaveString(HKEY_CURRENT_USER, APPREGPATH, "Shutdown Properly", "1")

  ' Remember whether to confirm or not
  Call SaveString(HKEY_CURRENT_USER, APPREGPATH, "Confirm", chkConfirm.Value)

'  ' Allow anyone who ran this to clean up (just comment it out if you don't care)
'  If MsgBox("Do you want to remove all registry entries saved by this app?", _
'            vbQuestion + vbYesNo + vbDefaultButton2, "Clean Up") = vbYes Then
'    Call DeleteKey(HKEY_CURRENT_USER, APPREGPATH)   ' Only for this app, not the printers
'  End If

  Set frmDefaultPrinter = Nothing
End Sub
Private Sub lvwPrinter_BeforeLabelEdit(Cancel As Integer)
  ' Don't allow any changes to be made to the printer name
  Cancel = True
End Sub
Private Sub lvwPrinter_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
  Dim itmX As MSComctlLib.ListItem

  ' Make sure there are printers with which we can work
  If lvwPrinter.ListItems.Count <= 0 Then
    Exit Sub
  End If

  ' Make sure the listview's sorted property is set correctly
  If lvwPrinter.Sorted = False Then
    lvwPrinter.Sorted = True
  End If

  ' Reverse the sort from what it currently is
  If lvwPrinter.SortKey = ColumnHeader.Index - 1 Then
    If lvwPrinter.SortOrder = lvwAscending Then
      lvwPrinter.SortOrder = lvwDescending
    Else
      lvwPrinter.SortOrder = lvwAscending
    End If
  Else
    lvwPrinter.SortKey = ColumnHeader.Index - 1
    lvwPrinter.SortOrder = lvwAscending
  End If

  Set itmX = lvwPrinter.FindItem(lvwPrinter.SelectedItem)

  ' Make sure that any selected item stays visible to the user
  If Not itmX Is Nothing Then
    itmX.EnsureVisible
    lvwPrinter.SetFocus
  End If

  If lvwPrinter.ListItems.Count > 1 Then                    ' If there is more than one printer...
    Call ShowHeaderIcon(lvwPrinter, lvwPrinter.SortOrder)   ' place an arrow at the top of the list
  End If

  ' Clean up
  Set itmX = Nothing
End Sub
Private Sub lvwPrinter_DblClick()
  ' Allow the user to set the default printer on double-click
  If Not lvwPrinter.SelectedItem Is Nothing Then        ' Do we have something selected?
    If lvwPrinter.SelectedItem.Selected Then
      ' Make sure it's not already set as the default
      If lvwPrinter.SelectedItem.Checked = False Then
        Call cmdSet_Click
      Else
        MsgBox lvwPrinter.SelectedItem.Text & vbCrLf & "is already set as the default printer.", _
               vbExclamation, "Default Printer Set"
      End If
    End If
  End If
End Sub
Private Sub lvwPrinter_GotFocus()
  On Error GoTo ErrorHandler    ' In case there are no printers listed

  ' Determine whether or not to enable the 'Set Default Printer' button
  If lvwPrinter.SelectedItem.Index > 0 And Not lvwPrinter.SelectedItem.Checked Then
    cmdSet.Enabled = True
  Else
    cmdSet.Enabled = False
  End If

ErrorHandler:
End Sub
Private Sub lvwPrinter_ItemCheck(ByVal Item As MSComctlLib.ListItem)
  ' Don't allow checkbox to be changed when clicked
  Item.Checked = Not Item.Checked
End Sub
Private Sub lvwPrinter_KeyDown(KeyCode As Integer, Shift As Integer)
  ' Don't allow checkbox to be changed using the keyboard
  If KeyCode = vbKeySpace Then
    KeyCode = 0
  End If
End Sub
Private Sub lvwPrinter_KeyUp(KeyCode As Integer, Shift As Integer)
  On Error GoTo ErrorHandler    ' In case there are no printers listed

  ' Determine whether or not to enable the 'Set Default Printer' button
  If lvwPrinter.SelectedItem.Index > 0 And Not lvwPrinter.SelectedItem.Checked Then
    cmdSet.Enabled = True
  Else
    cmdSet.Enabled = False
  End If

ErrorHandler:
End Sub
Private Sub lvwPrinter_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
  On Error GoTo ErrorHandler    ' In case there are no printers listed

  ' Determine whether or not to enable the 'Set Default Printer' button
  If lvwPrinter.SelectedItem.Index > 0 And Not lvwPrinter.SelectedItem.Checked Then
    cmdSet.Enabled = True
  Else
    cmdSet.Enabled = False
  End If

ErrorHandler:
End Sub
