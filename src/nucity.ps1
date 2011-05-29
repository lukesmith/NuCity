$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(8192,50)

$nugetCore = resolve-path "..\packages\NuGet.Core*\lib\net40\NuGet.Core.dll"
$Assembly = [Reflection.Assembly]::LoadFrom($nugetCore);

$Uri = New-Object System.Uri("http://packages.nuget.org/v1/FeedService.svc/")
$DataService = New-Object -TypeName "NuGet.DataServicePackageRepository"  -ArgumentList $Uri

$localRepository = New-Object NuGet.LocalPackageRepository(resolve-path "..\packages")
$localPackages = $localRepository.GetPackages()
$outOfDatePackages = [NuGet.PackageRepositoryExtensions]::GetUpdates($DataService, $localPackages)

$outputFile = ("results/nucity.html")

New-Item $outputFile -type file -force

Add-Content $outputFile "<html><body>"
Add-Content $outputFile "<h1>An update exists for the following packages</h1>"
Add-Content $outputFile "<ul>"
foreach ($packageUpdate in $outOfDatePackages) {
	$item = "<li>" + $packageUpdate.Id + " -> " + $packageUpdate.Version + "</li>"
	Add-Content $outputFile $item
}
Add-Content $outputFile "</ul>"
Add-Content $outputFile "</body></html>"

$fullOutputPath = Resolve-Path($outputFile)
Out-Default -InputObject "##teamcity[publishArtifacts '$fullOutputPath']"