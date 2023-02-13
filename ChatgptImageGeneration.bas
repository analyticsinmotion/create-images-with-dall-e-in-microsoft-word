Attribute VB_Name = "ChatGPTImageGeneration"
Sub ImageGeneration()
'
' Image Generation Macro
'
'
  If Selection.Type = wdSelectionIP Then
    Exit Sub
  End If
  
  If Selection.Text = ChrW$(13) Then
    Exit Sub
  End If

  Dim strAPIKey As String
  Dim strURL As String
  Dim strPrompt As String
  Dim strImageSize As String
  Dim strResponse As String
  Dim objCurlHttp As Object
  Dim strJSONdata As String

  strAPIKey = Environ("OPENAI_API_KEY")
  strURL = "https://api.openai.com/v1/images/generations"
  strImageSize = "256x256"

  strPrompt = Replace(Selection, ChrW$(13), "")
  strJSONdata = "{""prompt"":""" & strPrompt & """,""size"":""" & strImageSize & """}"
  

  Set objCurlHttp = CreateObject("MSXML2.serverXMLHTTP")

  With objCurlHttp
    .Open "POST", strURL, False
    .SetRequestHeader "Content-type", "application/json"
    .SetRequestHeader "Authorization", "Bearer " + strAPIKey
    .Send (strJSONdata)

    strResponse = .ResponseText
    
    If Mid(strResponse, 6, 5) = "error" Then
      MsgBox Prompt:="The server had an error while processing your request. Sorry about that! Please try again"
      Exit Sub
    End If
    

    Dim intStartPos As Integer
    intStartPos = InStr(1, strResponse, Chr(34) & "url" & Chr(34)) + 8
    
    If intStartPos = 8 Then
      MsgBox Prompt:="ChatGPT is at capacity right now. Please wait a minute and try again."
      Exit Sub
    End If
    
    Dim intEndPos As Integer
    intEndPos = InStr(1, strResponse, "}") - 6
    
    Dim intLength As Integer
    intLength = intEndPos - intStartPos
    
    Dim strImageURL As String
    strImageURL = Mid(strResponse, intStartPos, intLength)

    
    Dim intFileNameStartPos As Integer
    intFileNameStartPos = InStr(1, strImageURL, "img-")
    
    Dim intFileNameEndPos As Integer
    intFileNameEndPos = InStr(1, strImageURL, "png") + 3
    
    Dim intFileNameLength As Integer
    intFileNameLength = intFileNameEndPos - intFileNameStartPos
    
    Dim strFileName As String
    strFileName = Mid(strImageURL, intFileNameStartPos, intFileNameLength)
        
    Dim strPath As String
    strPath = "C:\Users\Public\Pictures\"

    
    .Open "GET", strImageURL, False
    .Send
    
    Set Stream = CreateObject("ADODB.Stream")
    
    Stream.Open
    Stream.Type = 1
    Stream.write objCurlHttp.ResponseBody
    Stream.SaveToFile strPath & strFileName
    Stream.Close
    
    Selection.InsertAfter vbCr
    Selection.Collapse Direction:=wdCollapseEnd
    
    
    Selection.InlineShapes.AddPicture FileName:= _
    strPath & strFileName, LinkToFile:=False, _
    SaveWithDocument:=True
    
    Selection.InsertAfter vbCr
    Selection.Collapse Direction:=wdCollapseEnd
    

  End With
  
  Set objCurlHttp = Nothing

End Sub


