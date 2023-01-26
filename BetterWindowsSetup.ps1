[CmdletBinding()]
param
(
	[Parameter()][ValidateSet('Stable', 'Nightly')][string]$Channel = "Nightly",
	[Parameter()][ValidateSet('64', '32', 'Detect')][string]$Architecture = "Detect",
	[Parameter()][String]$FFMPEGPath = "C:\betterEnv\ffmpeg\",
	[Parameter()][Switch]$AddEnvironmentVariable = $false,
	[Parameter()][String]$YoutubeDLPath = "C:\betterEnv\youtube-dl\"
)

Clear-Host
function Request-AdminPrivilege() {
	# Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Set-ExtraStuff() {
	[CmdletBinding()] param ()

	cmd /c color B

	$writeAscii = @"
	
	
	__                        __  __    _             _           ____     __       __             
	_________ _/ /___  ______ _____ ___  / /_/ /_  (_)___  ____ _(_)__  _____/ __/__  / /______/ /_  ___  _____
   / ___/ __ `/ __/ / / / __ `/ __ `__ \/ __/ __ \/ / __ \/ __ `/ / _ \/ ___/ /_/ _ \/ __/ ___/ __ \/ _ \/ ___/
  (__  ) /_/ / /_/ /_/ / /_/ / / / / / / /_/ / / / / / / / /_/ / /  __(__  ) __/  __/ /_/ /__/ / / /  __/ /    
 /____/\__,_/\__/\__, /\__,_/_/ /_/ /_/\__/_/ /_/_/_/ /_/\__, /_/\___/____/_/  \___/\__/\___/_/ /_/\___/_/     
				/____/                                  /____/                                              
				
"@

	Write-Host $writeAscii
}


function Remove-Bloat() {
	$Apps = @(
		# bloat
		"Microsoft.3DBuilder"                    # 3D Builder
		"Microsoft.549981C3F5F10"                # Cortana
		"Microsoft.Appconnector"
		"Microsoft.BingFinance"                  # Finance
		"Microsoft.BingFoodAndDrink"             # Food And Drink
		"Microsoft.BingHealthAndFitness"         # Health And Fitness
		"Microsoft.BingNews"                     # News
		"Microsoft.BingSports"                   # Sports
		"Microsoft.BingTranslator"               # Translator
		"Microsoft.BingTravel"                   # Travel
		"Microsoft.BingWeather"                  # Weather
		"Microsoft.CommsPhone"
		"Microsoft.ConnectivityStore"
		"Microsoft.GetHelp"
		"Microsoft.Getstarted"
		"Microsoft.Messaging"
		"Microsoft.Microsoft3DViewer"
		"Microsoft.MicrosoftOfficeHub"
		"Microsoft.MicrosoftPowerBIForWindows"
		"Microsoft.MicrosoftSolitaireCollection" # MS Solitaire
		"Microsoft.MixedReality.Portal"
		"Microsoft.NetworkSpeedTest"
		"Microsoft.Office.OneNote"               # MS Office One Note
		"Microsoft.Office.Sway"
		"Microsoft.OneConnect"
		"Microsoft.People"                       # People
		"Microsoft.MSPaint"                      # Paint 3D
		"Microsoft.Print3D"                      # Print 3D
		"Microsoft.SkypeApp"                     # Skype
		"Microsoft.Todos"                        # Microsoft To Do
		"Microsoft.Wallet"
		"Microsoft.Whiteboard"                   # Microsoft Whiteboard
		"Microsoft.WindowsAlarms"                # Alarms
		"microsoft.windowscommunicationsapps"
		"Microsoft.WindowsMaps"                  # Maps
		"Microsoft.WindowsPhone"
		"Microsoft.WindowsReadingList"
		"Microsoft.WindowsSoundRecorder"         # Windows Sound Recorder
		"Microsoft.XboxApp"                      # Xbox Console Companion (Replaced by new App)
		"Microsoft.YourPhone"                    # Your Phone
		"Microsoft.ZuneMusic"                    # Groove Music / (New) Windows Media Player
		"Microsoft.ZuneVideo"                    # Movies & TV
	
		# Default Windows 11 apps
		"MicrosoftWindows.Client.WebExperience"  # Taskbar Widgets
		"MicrosoftTeams"                         # Microsoft Teams / Preview
	
		# 3rd party Apps
		"*ACGMediaPlayer*"
		"*ActiproSoftwareLLC*"
		"*AdobePhotoshopExpress*"                # Adobe Photoshop Express
		"*Amazon.com.Amazon*"                    # Amazon Shop
		"*Asphalt8Airborne*"                     # Asphalt 8 Airbone
		"*AutodeskSketchBook*"
		"*BubbleWitch3Saga*"                     # Bubble Witch 3 Saga
		"*CaesarsSlotsFreeCasino*"
		"*CandyCrush*"                           # Candy Crush
		"*COOKINGFEVER*"
		"*CyberLinkMediaSuiteEssentials*"
		"*DisneyMagicKingdoms*"
		"*Dolby*"                                # Dolby Products (Like Atmos)
		"*DrawboardPDF*"
		"*Duolingo-LearnLanguagesforFree*"       # Duolingo
		"*EclipseManager*"
		"*Facebook*"                             # Facebook
		"*FarmVille2CountryEscape*"
		"*FitbitCoach*"
		"*Flipboard*"                            # Flipboard
		"*HiddenCity*"
		"*Hulu*"
		"*iHeartRadio*"
		"*Keeper*"
		"*LinkedInforWindows*"
		"*MarchofEmpires*"
		"*NYTCrossword*"
		"*OneCalendar*"
		"*PandoraMediaInc*"
		"*PhototasticCollage*"
		"*PicsArt-PhotoStudio*"
		"*Plex*"                                 # Plex
		"*PolarrPhotoEditorAcademicEdition*"
		"*RoyalRevolt*"                          # Royal Revolt
		"*Shazam*"
		"*Sidia.LiveWallpaper*"                  # Live Wallpaper
		"*SlingTV*"
		"*Speed Test*"
		"*Sway*"
		"*TuneInRadio*"
		"*Twitter*"                              # Twitter
		"*Viber*"
		"*WinZipUniversal*"
		"*Wunderlist*"
		"*XING*"
	
		# Apps which other apps depend on
		"Microsoft.Advertising.Xaml"
	
		# SAMSUNG Bloat
		#"SAMSUNGELECTRONICSCO.LTD.SamsungSettings1.2"          # Allow user to Tweak some hardware settings
		"SAMSUNGELECTRONICSCO.LTD.1412377A9806A"
		"SAMSUNGELECTRONICSCO.LTD.NewVoiceNote"
		"SAMSUNGELECTRONICSCoLtd.SamsungNotes"
		"SAMSUNGELECTRONICSCoLtd.SamsungFlux"
		"SAMSUNGELECTRONICSCO.LTD.StudioPlus"
		"SAMSUNGELECTRONICSCO.LTD.SamsungWelcome"
		"SAMSUNGELECTRONICSCO.LTD.SamsungUpdate"
		"SAMSUNGELECTRONICSCO.LTD.SamsungSecurity1.2"
		"SAMSUNGELECTRONICSCO.LTD.SamsungScreenRecording"
		#"SAMSUNGELECTRONICSCO.LTD.SamsungRecovery"             # Used to Factory Reset
		"SAMSUNGELECTRONICSCO.LTD.SamsungQuickSearch"
		"SAMSUNGELECTRONICSCO.LTD.SamsungPCCleaner"
		"SAMSUNGELECTRONICSCO.LTD.SamsungCloudBluetoothSync"
		"SAMSUNGELECTRONICSCO.LTD.PCGallery"
		"SAMSUNGELECTRONICSCO.LTD.OnlineSupportSService"
		"4AE8B7C2.BOOKING.COMPARTNERAPPSAMSUNGEDITION"
	
		# Remove the # to Uninstall
	
		#"Microsoft.FreshPaint"             # Paint
		"Microsoft.MicrosoftEdge"          # Microsoft Edge
		#"Microsoft.MicrosoftStickyNotes"   # Sticky Notes
		#"Microsoft.WindowsCalculator"      # Calculator
		#"Microsoft.WindowsCamera"          # Camera
		#"Microsoft.ScreenSketch"           # Snip and Sketch (now called Snipping tool, replaces the Win32 version in clean installs)
		"Microsoft.WindowsFeedbackHub"     # Feedback Hub
		#"Microsoft.Windows.Photos"         # Photos
	
		"*Netflix*"                        # Netflix
		#"*SpotifyMusic*"                   # Spotify
	
		#"Microsoft.WindowsStore"           # Windows Store
	
		# Apps which cannot be removed using Remove-AppxPackage
		#"Microsoft.BioEnrollment"
		#"Microsoft.WindowsFeedback"        # Feedback Module
		#"Windows.ContactSupport"
	)
	
	Write-Title -Text "Remove Bloatware Apps"
	Write-Section -Text "Removing Windows unneeded Apps"
	Remove-UWPAppx -AppxPackages $Apps
}

function Remove-OneDrive() {
    # Description: This script will remove and disable OneDrive integration.
    Write-Host "Kill OneDrive process..."
    taskkill.exe /F /IM "OneDrive.exe"
    taskkill.exe /F /IM "explorer.exe"

    Write-Host "Remove OneDrive."
    if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
        & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
    }
    if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
        & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
    }

    Write-Host "Removing OneDrive leftovers..."
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:systemdrive\OneDriveTemp"
    # check if directory is empty before removing:
    If ((Get-ChildItem "$env:userprofile\OneDrive" -Recurse | Measure-Object).Count -eq 0) {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:userprofile\OneDrive"
    }

    Write-Host "Disable OneDrive via Group Policies."
    New-FolderForced -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1

    Write-Host "Remove Onedrive from explorer sidebar."
    New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
    mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
    mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
    Set-ItemProperty -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
    Remove-PSDrive "HKCR"

    # Thank you Matthew Israelsson
    Write-Host "Removing run hook for new users..."
    reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
    reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
    reg unload "hku\Default"

    Write-Host "Removing startmenu entry..."
    Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

    Write-Host "Removing scheduled task..."
    Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

    Write-Host "Restarting explorer..."
    Start-Process "explorer.exe"

    Write-Host "Waiting for explorer to complete loading..."
    Start-Sleep 5
}

function Set-Rebloat() {
    # The following code is from Microsoft (Adapted): https://go.microsoft.com/fwlink/?LinkId=619547
    # Get all the provisioned packages
    $Packages = (Get-Item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Applications') | Get-ChildItem
    # Filter the list if provided a filter
    $PackageFilter = $args[0]

    If ([string]::IsNullOrEmpty($PackageFilter)) {
        Write-Warning "No filter specified, attempting to re-register all provisioned apps."
    } Else {
        $Packages = $Packages | Where-Object { $_.Name -like $PackageFilter }

        If ($null -eq $Packages) {
            Write-Warning "No provisioned apps match the specified filter."
            exit
        } Else {
            Write-Host "Registering the provisioned apps that match $PackageFilter ..."
        }
    }

    ForEach ($Package in $Packages) {
        # Get package name & path
        $PackageName = $Package | Get-ItemProperty | Select-Object -ExpandProperty PSChildName
        $PackagePath = [System.Environment]::ExpandEnvironmentVariables(($Package | Get-ItemProperty | Select-Object -ExpandProperty Path))
        # Register the package
        Write-Host "Attempting to register package: $PackageName ..."
        Add-AppxPackage -register $PackagePath -DisableDevelopmentMode
    }
}


Request-AdminPrivilege # Check admin rights

Set-ExtraStuff

Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

# Makes the console look cooler
Write-Host "Your Current Folder $pwd"
Write-Host "Script Root Folder $PSScriptRoot"

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

[System.Windows.Forms.Application]::EnableVisualStyles() # Rounded Buttons :3

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
[void] $listBox.Items.Add('Tools / Remove Bloat')

[void] $listBox.Items.Add('Tools / FFMpeg')
[void] $listBox.Items.Add('Tools / Youtube-DL')
[void] $listBox.Items.Add('Tools / Youtube-DL / Context')

[void] $listBox.Items.Add('Chocolatey / Development Essentials')
[void] $listBox.Items.Add('Chocolatey / Satyam Essentials')
[void] $listBox.Items.Add('Chocolatey / Entertainment Essentials')
[void] $listBox.Items.Add('Chocolatey / Gaming Essentials')

[void] $listBox.Items.Add('Unity / Doctor Character')

[void] $listBox.Items.Add('Why / Rebloat')



$form.Controls.Add($listBox)

$form.Topmost = $true

$continue = $true
while ($continue) {
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $x = $listBox.SelectedItem
        Write-Host "Fetching" $x
        # run commands corresponding to selected item

        # check if user wants to continue using the script
        $continue = [System.Windows.Forms.MessageBox]::Show("Do you want to continue using the script?", "", [System.Windows.Forms.MessageBoxButtons]::YesNo) -eq [System.Windows.Forms.DialogResult]::Yes
    } else {
        # exit loop if user pressed cancel button
        $continue = $false
    }
}


if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
	$x = $listBox.SelectedItem
	
	Write-Host "Fetching" $x
	
	if ($x -eq 'Prereqs / Git+Chocolatey') {
		# install chocolatey
		Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

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

	if($x -eq 'Tools / Remove Bloat'){
		Remove-Bloat
		Remove-OneDrive
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

	if($x -eq 'Why / Rebloat'){
		Set-Rebloat
	}
	
	
}
