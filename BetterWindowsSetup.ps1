[CmdletBinding()]
param
(
	[Parameter()][ValidateSet('Stable', 'Nightly')][string]$Channel = "Nightly",
	[Parameter()][ValidateSet('64', '32', 'Detect')][string]$Architecture = "Detect",
	[Parameter()][String]$FFMPEGPath = "C:\betterEnv\ffmpeg\",
	[Parameter()][Switch]$AddEnvironmentVariable = $false,
	[Parameter()][String]$YoutubeDLPath = "C:\betterEnv\youtube-dl\"
)

#General Declares in the Program
$SaveFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-release-essentials.zip"
$ExtractFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-release-essentials"

#General Declares in the Program
$SaveYoutubeDLTempLocation = $YoutubeDLPath + "youtube-dl.exe"

#Context declares
$YoutubeDLContext = $YoutubeDLPath + "YoutubeDLPrompt.bat"

#Reg declares
$YoutubeDLContextReg = $YoutubeDLPath + "YoutubeDLReg.reg"

#If Architecture is set to Detect then detect and set it
if ($Architecture -eq 'Detect') {
	Write-Verbose "Detecting host operating system architecture to download according version of FFMPEG"
	if ([Environment]::Is64BitOperatingSystem) {
		$Architecture = '64'
	}
	else {
		$Architecture = '32'
	}
}


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# $sizeMultiplier = 2

$form = New-Object System.Windows.Forms.Form
$form.Text = 'satyam thingies fetcher'
$form.Size = New-Object System.Drawing.Size(300, 200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75, 120)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150, 120)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(280, 20)
$label.Text = 'Select resource to fetch:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 40)
$listBox.Size = New-Object System.Drawing.Size(260, 20)
$listBox.Height = 80


[void] $listBox.Items.Add('Prereqs / Git+Chocolatey')


[void] $listBox.Items.Add('Tools / FFMpeg')
[void] $listBox.Items.Add('Tools / Youtube-DL')
[void] $listBox.Items.Add('Tools / Youtube-DL / Context')

[void] $listBox.Items.Add('Chocolatey / Development Essentials')
[void] $listBox.Items.Add('Chocolatey / Satyam Essentials')
[void] $listBox.Items.Add('Chocolatey / Entertainment Essentials')
[void] $listBox.Items.Add('Chocolatey / Gaming Essentials')

[void] $listBox.Items.Add('Unity / Doctor Character')



$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
	$x = $listBox.SelectedItem
	
	Write-Host "Fetching" $x
	
	if ($x -eq 'Prereqs / Git+Chocolatey') {
		# install chocolatey
		Invoke-WebRequest https://chocolatey.org/install.ps1 | Invoke-Expression

		#install git
		choco install git -y
	}

	if ($x -eq 'Unity / Doctor Character') {
		git status	
		
		Remove-Item '.git' -Force -Recurse
		
		git init .
		git remote add origin https://github.com/sudotman/sudotman/
		#git checkout frequentModels
		
		git pull origin frequentModels
		
		Remove-Item '.git' -Force -Recurse
		Remove-Item 'README.md' -Force		
		
		Write-Host "Done running!"
	}
	
	if ($x -eq 'Tools / Youtube-DL / Context') {
		# youtube-dl -f "137+140/bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo[ext=mp4]+bestaudio/best" --merge-output-format mp4 %link%


		# ffmpeg direct convert to mp4

		# Youtube-DL Context menu

		#Check if the ydl Path in C:\ exists if not create it
		Write-Host "Detecting if ydl context file already exists"
		If (-Not (Test-Path $YoutubeDLContext)) {
			Write-Host "Creating ydl context directory"
			New-Item -Path $YoutubeDLContext
		}
		else {
			Clear-Content -Path $YoutubeDLContext
		}


		$youtubeDLBat = @"
:copy paste the path into the command prompt and transfer data to a location that you can edit.

@ECHO OFF
SET PATH=%PATH%;c:\youtube-dl-contextmenu-main\Stuff
SET /P link=Enter YouTube link: 
set link=%link:"=%
:: %command: =_% example to replace all spaces in command with underscores

IF "%link%"=="" GOTO Error

ECHO "%link%". Downloading now
youtube-dl -f "137+140/bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo[ext=mp4]+bestaudio/best" --merge-output-format mp4 %link%
GOTO End

:Error
ECHO You are supposed to enter a link.
PAUSE
EXIT /B

:End
ECHO Done.
PAUSE
EXIT /B
"@

		$youtubeDLBat | Out-File -FilePath $YoutubeDLContextReg


		$youtubeDLReg = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Classes\directory\Background\shell\BetterWindows]
@="&Download via YoutubeDL"
"Icon"="%SystemRoot%\\System32\\shell32.dll,71"
	
[HKEY_CURRENT_USER\Software\Classes\directory\Background\shell\BetterWindows\command]
@="C:\\betterEnv\\youtube-dl\\YoutubeDLPrompt.bat \"%V\""
	
[HKEY_CURRENT_USER\Software\Classes\directory\shell\BetterWindows]
@="&Download via YoutubeDL"
"Icon"="%SystemRoot%\\System32\\shell32.dll,71"
	
[HKEY_CURRENT_USER\Software\Classes\directory\shell\BetterWindows\command]
@="C:\\betterEnv\\youtube-dl\\YoutubeDLPrompt.bat \"%V\""
"@
	
		Write-Host "Detecting if ydl reg file already exists"
		If (-Not (Test-Path $YoutubeDLContextReg)) {
			Write-Host "Creating ydl reg directory"
			New-Item -Path $YoutubeDLContextReg
		}
		else {
			Clear-Content -Path $YoutubeDLContextReg
		}

		$youtubeDLReg | Out-File -FilePath $YoutubeDLContextReg

		reg.exe IMPORT $YoutubeDLContextReg
		# regedit.exe /s $YoutubeDLContextReg
	}




	# I understand that I can install ffmpeg through chocolatey and solve myself all this headache but I like having my-
	# essential libraries in custom places. (plus, freedom to get essentials/full or any other changes such as only including ffmpeg.exe and not ffplay or probe)
	if ($x -eq 'Tools / FFMpeg') {
		

		#Request the static files available for download based on Architecture and Channel
		#$Request = Invoke-WebRequest -Uri ("https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip")	
	
		$DownloadFFMPEGStatic = ("https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip")
		
		# $ExtractedFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-release-essentials\" + ($DownloadFFMPEGStatic.Split('/')[-1].Replace('.zip', '')) + "\"

		#Detection if ffmpeg is running and if so kill it
		Write-Host "Detecting if FFMPEG is already running"
		if (Get-Process ffmpeg -ErrorAction SilentlyContinue) {
			Write-Verbose "Shutting down FFMPEG"
			Get-Process ffmpeg | Stop-Process ffmpeg -Force
		}

		#Check if the FFMPEG Path in C:\ exists if not create it
		Write-Host "Detecting if FFMPEG directory already exists"
		If (-Not (Test-Path $FFMPEGPath)) {
			Write-Verbose "Creating FFMPEG directory"
			New-Item -Path $FFMPEGPath -ItemType Directory | Out-Null
		}
		else {
			Get-ChildItem $FFMPEGPath | Remove-item -Recurse -Confirm:$false
		}

		#Download based on the channel input which ffmpeg download you want
		Write-Host "Downloading the selected FFMPEG application zip"
		Invoke-WebRequest $DownloadFFMPEGStatic -OutFile $SaveFFMPEGTempLocation

		#Unzip the downloaded archive to a temp location
		Write-Host "Expanding the downloaded FFMPEG application zip"
		Expand-Archive $SaveFFMPEGTempLocation -DestinationPath $ExtractFFMPEGTempLocation

		#Copy from temp location to $FFMPEGPath
		Write-Host "Retrieving and installing new FFMPEG files"
		# Get-ChildItem -Path $ExtractFFMPEGTempLocation -Recurse | Where-Object {$_.Name -match 'ffmpeg.exe'} | Select-Object Fullname | Copy-Item -Destination $FFMPEGPath -Recurse -Force
		Get-ChildItem -Path $ExtractFFMPEGTempLocation -Recurse -Filter *ffmpeg*.exe | Copy-Item -Destination $FFMPEGPath -Recurse -Force
		# Get-ChildItem $ExtractedFFMPEGTempLocation | Copy-Item -Destination $FFMPEGPath -Recurse -Force

		#Add to the PATH Environment Variables
	
		Write-Host "Adding the FFMPEG bin folder to the User Environment Variables"
		[Environment]::SetEnvironmentVariable("PATH", ($FFMPEGPath), "User")
		

		#Clean up of files that were used
		Write-Verbose "Clean up of the downloaded FFMPEG zip package"
		if (Test-Path ($SaveFFMPEGTempLocation)) {
			Remove-Item $SaveFFMPEGTempLocation -Confirm:$false
		}

		#Clean up of files that were used
		Write-Verbose "Clean up of the expanded FFMPEG zip package"
		if (Test-Path ($ExtractFFMPEGTempLocation)) {
			Remove-Item $ExtractFFMPEGTempLocation -Recurse -Confirm:$false
		}		
	}

	if ($x -eq 'Tools / Youtube-DL') {
		

		#Request the static files available for download based on Architecture and Channel
		#$Request = Invoke-WebRequest -Uri ("https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip")	
	
		$DownloadYoutubeDLStatic = ("https://youtube-dl.org/downloads/latest/youtube-dl.exe")
		
		# $ExtractedFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-release-essentials\" + ($DownloadFFMPEGStatic.Split('/')[-1].Replace('.zip', '')) + "\"


		#Check if the ydl Path in C:\ exists if not create it
		Write-Host "Detecting if ydl directory already exists"
		If (-Not (Test-Path $YoutubeDLPath)) {
			Write-Host "Creating ydl directory"
			New-Item -Path $YoutubeDLPath -ItemType Directory | Out-Null
		}
		else {
			Get-ChildItem $YoutubeDLPath | Remove-item -Recurse -Confirm:$false
		}

		#Download based on the channel input which ydl download you want
		Write-Host "Downloading the selected ydl application zip"
		Invoke-WebRequest $DownloadYoutubeDLStatic -OutFile $SaveYoutubeDLTempLocation

		#Copy from temp location to $FFMPEGPath
		Write-Host "Retrieving and installing new ydl files"
		# Get-ChildItem -Path $ExtractFFMPEGTempLocation -Recurse | Where-Object {$_.Name -match 'ffmpeg.exe'} | Select-Object Fullname | Copy-Item -Destination $FFMPEGPath -Recurse -Force
		Get-ChildItem -Path $SaveYoutubeDLTempLocation -Recurse -Filter *youtube-dl*.exe | Copy-Item -Destination $YoutubeDLPath -Recurse -Force
		# Get-ChildItem $ExtractedFFMPEGTempLocation | Copy-Item -Destination $FFMPEGPath -Recurse -Force

		#Add to the PATH Environment Variables
	
		Write-Host "Adding the ydl bin folder to the User Environment Variables"
		[Environment]::SetEnvironmentVariable("PATH", ($YoutubeDLPath), "User")
		
	}

	if ($x -eq 'Chocolatey / Development Essentials') {
		#install git
		#choco install git -y

		#install vscode
		choco install vscode -y

		#install nodejs
		choco install nodejs -y

		#install notepad++
		choco install notepadplusplus -y

		#install 7zip
		choco install 7zip -y


	}

	if ($x -eq 'Chocolatey / Satyam Essentials') {
		#install git
		#choco install git -y

		#install vscode
		choco install vscode -y

		#install nodejs
		choco install nodejs -y

		#install notepad++
		choco install notepadplusplus -y

		#install 7zip
		choco install 7zip -y

		#install vlc
		choco install vlc -y

		#install spotify
		choco install spotify -y

		#install adb
		choco install adb -y
	}

	if ($x -eq 'Chocolatey / Entertainment Essentials') {
		#install vlc
		choco install vlc -y

		#install spotify
		choco install spotify -y
	}

	if ($x -eq 'Chocolatey / Gaming Essentials') {
		#install epic games launcher
		choco install epicgameslauncher -y

		#install retroarch
		choco install retroarch -y

		#install steam
		choco install steam-client -y

		#install discord
		choco install discord -y
	}
	
	
}