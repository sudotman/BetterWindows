[CmdletBinding()]
		param
		(
			[Parameter()][ValidateSet('Stable', 'Nightly')][string]$Channel = "Nightly",
			[Parameter()][ValidateSet('64', '32', 'Detect')][string]$Architecture = "Detect",
			[Parameter()][String]$FFMPEGPath = "C:\betterEnv\ffmpeg\",
			[Parameter()][Switch]$AddEnvironmentVariable = $false
		)

		#General Declares in the Program
		$SaveFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-release-essentials.zip"
		$ExtractFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-release-essentials"

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
	
	if($x -eq 'Prereqs / Git+Chocolatey'){
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
	
	# I understand that I can install ffmpeg through chocolatey and solve myself all this headache but I like having my-
	# essential libraries in custom places. (plus, freedom to get essentials/full or any other changes such as only including ffmpeg.exe and not ffplay or probe)
	if ($x -eq 'Tools / FFMpeg') {
		

		#Request the static files available for download based on Architecture and Channel
		#$Request = Invoke-WebRequest -Uri ("https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip")	
	
		$DownloadFFMPEGStatic = ("https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip")
		
		# $ExtractedFFMPEGTempLocation = $FFMPEGPath + "ffmpeg-release-essentials\" + ($DownloadFFMPEGStatic.Split('/')[-1].Replace('.zip', '')) + "\"

		#Detection if ffmpeg is running and if so kill it
		Write-Verbose "Detecting if FFMPEG is already running"
		if (Get-Process ffmpeg -ErrorAction SilentlyContinue) {
			Write-Verbose "Shutting down FFMPEG"
			Get-Process ffmpeg | Stop-Process ffmpeg -Force
		}

		#Check if the FFMPEG Path in C:\ exists if not create it
		Write-Verbose "Detecting if FFMPEG directory already exists"
		If (-Not (Test-Path $FFMPEGPath)) {
			Write-Verbose "Creating FFMPEG directory"
			New-Item -Path $FFMPEGPath -ItemType Directory | Out-Null
		}
		else {
			Get-ChildItem $FFMPEGPath | Remove-item -Recurse -Confirm:$false
		}

		#Download based on the channel input which ffmpeg download you want
		Write-Verbose "Downloading the selected FFMPEG application zip"
		Invoke-WebRequest $DownloadFFMPEGStatic -OutFile $SaveFFMPEGTempLocation

		#Unzip the downloaded archive to a temp location
		Write-Verbose "Expanding the downloaded FFMPEG application zip"
		Expand-Archive $SaveFFMPEGTempLocation -DestinationPath $ExtractFFMPEGTempLocation

		#Copy from temp location to $FFMPEGPath
		Write-Verbose "Retrieving and installing new FFMPEG files"
		# Get-ChildItem -Path $ExtractFFMPEGTempLocation -Recurse | Where-Object {$_.Name -match 'ffmpeg.exe'} | Select-Object Fullname | Copy-Item -Destination $FFMPEGPath -Recurse -Force
		Get-ChildItem -Path $ExtractFFMPEGTempLocation -Recurse -Filter *ffmpeg*.exe | Copy-Item -Destination $FFMPEGPath -Recurse -Force
		# Get-ChildItem $ExtractedFFMPEGTempLocation | Copy-Item -Destination $FFMPEGPath -Recurse -Force

		#Add to the PATH Environment Variables
	
		Write-Verbose "Adding the FFMPEG bin folder to the User Environment Variables"
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

	if($x -eq 'Chocolatey / Development Essentials'){
		#install git
		choco install git -y

		#install vscode
		choco install vscode -y

		#install nodejs
		choco install nodejs -y

		#install notepad++
		choco install notepadplusplus -y

		#install 7zip
		choco install 7zip -y


	}

	if($x -eq 'Chocolatey / Satyam Essentials'){
		#install git
		choco install git -y

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

	if($x -eq 'Chocolatey / Entertainment Essentials'){
		#install vlc
		choco install vlc -y

		#install spotify
		choco install spotify -y
	}

	if($x -eq 'Chocolatey / Gaming Essentials'){
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