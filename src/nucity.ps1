$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(8192,50)

$nugetCore = resolve-path "..\packages\NuGet.Core*\lib\net40\NuGet.Core.dll"
$Assembly = [Reflection.Assembly]::LoadFrom($nugetCore);

$nugetPackageUri = New-Object System.Uri("http://packages.nuget.org/v1/FeedService.svc/")
$nugetPackageRepository = New-Object NuGet.DataServicePackageRepository($nugetPackageUri)

$localRepository = New-Object NuGet.LocalPackageRepository(resolve-path "..\packages")
$localPackages = $localRepository.GetPackages()
$outOfDatePackages = [NuGet.PackageRepositoryExtensions]::GetUpdates($nugetPackageRepository, $localPackages)

$outputFile = "results/nucity.html"

New-Item $outputFile -type file -force

Add-Content $outputFile "<html><body>"
Add-Content $outputFile "<h2>Following packages installed</h2>"
Add-Content $outputFile "<ul>"
foreach ($package in $localPackages) {
	$item = "<li>" + $package.Id + " -> " + $package.Version + "</li>"
	Add-Content $outputFile $item
}
Add-Content $outputFile "</ul>"

Add-Content $outputFile "<h2>An update exists for the following packages</h2>"
Add-Content $outputFile "<ul>"
foreach ($packageUpdate in $outOfDatePackages) {
	$item = "<li>" + $packageUpdate.Id + " -> " + $packageUpdate.Version + "</li>"
	Add-Content $outputFile $item
}
Add-Content $outputFile "</ul>"
Add-Content $outputFile "</body></html>"

$outputFile = Resolve-Path($outputFile)
Out-Default -InputObject "##teamcity[publishArtifacts '$outputFile']"