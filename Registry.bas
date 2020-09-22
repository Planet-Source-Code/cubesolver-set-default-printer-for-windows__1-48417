Attribute VB_Name = "modRegistry"
Option Explicit

' Get and set string type entries in the registry as well as delete a key
' This is not an all inclusive registry tool module

Public Const HKEY_CURRENT_USER As Long = &H80000001

Private Const ERROR_SUCCESS As Long = 0&
Private Const REG_SZ As Long = 1

Private Declare Function RegOpenKey Lib "advapi32.dll" Alias "RegOpenKeyA" (ByVal hKey As Long, ByVal lpSubKey As String, phkResult As Long) As Long
Private Declare Function RegCreateKey Lib "advapi32.dll" Alias "RegCreateKeyA" (ByVal hKey As Long, ByVal lpSubKey As String, phkResult As Long) As Long
Private Declare Function RegSetValueEx Lib "advapi32.dll" Alias "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, lpData As Any, ByVal cbData As Long) As Long
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long
Private Declare Function RegDeleteKey Lib "advapi32.dll" Alias "RegDeleteKeyA" (ByVal hKey As Long, ByVal lpSubKey As String) As Long
Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
Public Sub DeleteKey(ByVal lKey As Long, ByVal sKey As String)
  Call RegDeleteKey(lKey, sKey)
End Sub
Public Function GetString(ByVal lKey As Long, ByVal sPath As String, ByVal sValue As String) As String
  Dim lKeyHand As Long, lValueType As Long, lResult As Long
  Dim sBuff As String
  Dim lDataBufSize As Long
  Dim iZeroPos As Integer

  Call RegOpenKey(lKey, sPath, lKeyHand)
  Call RegQueryValueEx(lKeyHand, sValue, 0, lValueType, ByVal 0, lDataBufSize)

  If lValueType = REG_SZ Then
    sBuff = String$(lDataBufSize, " ")
    lResult = RegQueryValueEx(lKeyHand, sValue, 0, 0, ByVal sBuff, lDataBufSize)

    If lResult = ERROR_SUCCESS Then
      iZeroPos = InStr(sBuff, vbNullChar)
      If iZeroPos > 0 Then
        GetString = Left$(sBuff, iZeroPos - 1)
      Else
        GetString = sBuff
      End If
    End If
  End If

  Call RegCloseKey(lKey)
End Function
Public Sub SaveString(ByVal lKey As Long, ByVal sPath As String, ByVal sValue As String, ByVal sData As String)
  Dim lKeyHand As Long

  Call RegCreateKey(lKey, sPath, lKeyHand)
  Call RegSetValueEx(lKeyHand, sValue, 0, REG_SZ, ByVal sData, Len(sData))
  Call RegCloseKey(lKeyHand)
End Sub
