#script to convert HEIC files

#if this is true, we will run this on multiple files instead of just one
param([switch]$multimode)


$MagickExe = $PSScriptRoot + '.\ImageMagickPortable\magick.exe'

function convertFile($OldFile){
    #function to handle the creation of the new file name and initiation of the conversion step
    #the new file will be the old one, but with jpg instead of heic at the end
    $NewFile = $OldFile.Substring(0,$OldFile.LastIndexOf('HEIC'))+'jpg'

    #now we run the conversion command
    & $MagickExe convert $OldFile $NewFile
}

#set up file picker and message box in case the Magick.exe is not in the expected location
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

#create a file browser that will look for executables
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = $env:USERPROFILE
    Filter = "Executable Files|*.exe"
}

if(-Not (Test-Path $MagickExe)){
    [System.Windows.MessageBox]::Show("Please select the location of magick.exe","Could not find the magic")
    $FileBrowser.ShowDialog()
    $MagickExe = $FileBrowser.FileName
}

#at this point, we should have the correct path for magick.exe so we can get started with getting the files to convert
#end goal is to run the command for each file to convert:
#magick.exe convert oldfile.heic newfile.jpg

#first, let's adjust the FileBrowser object to look for HEICs
$FileBrowser.InitialDirectory = $env:USERPROFILE + "\Pictures"
$FileBrowser.Filter = "HEIC Image Files|*.HEIC"


if(-not $multimode){
    #if only doing a single file, we don't need to change much of the browser

    $FileBrowser.ShowDialog()
    
    convertFile($FileBrowser.FileName)

}
else{
    #If we are doing a folder (or folders) of files,
    #we'll need to enable multi select 
    $FileBrowser.Multiselect = $true
    $FileBrowser.ShowDialog()

    $files = @($FileBrowser.FileNames)

    foreach ($file in $files){
        convertFile($file)
    }

}
