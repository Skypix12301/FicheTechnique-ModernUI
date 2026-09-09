$c = Get-Content "D:\mes projets\Fiche Technique_ModernUI\uMain_v3.pas" -Encoding UTF8 -Raw
$b = ([regex]::Matches($c, "begin")).Count
$e = ([regex]::Matches($c, "\bend\b")).Count
Write-Host "uMain_v3.pas: begin=$b end=$e diff=$($b-$e)"

$c = Get-Content "D:\mes projets\Fiche Technique_ModernUI\uModernTheme.pas" -Encoding UTF8 -Raw
$b = ([regex]::Matches($c, "begin")).Count
$e = ([regex]::Matches($c, "\bend\b")).Count
Write-Host "uModernTheme.pas: begin=$b end=$e diff=$($b-$e)"

$c = Get-Content "D:\mes projets\Fiche Technique_ModernUI\uUtils_v3.pas" -Encoding UTF8 -Raw
$b = ([regex]::Matches($c, "begin")).Count
$e = ([regex]::Matches($c, "\bend\b")).Count
Write-Host "uUtils_v3.pas: begin=$b end=$e diff=$($b-$e)"

$c = Get-Content "D:\mes projets\Fiche Technique_ModernUI\uIconsSVG.pas" -Encoding UTF8 -Raw
$b = ([regex]::Matches($c, "begin")).Count
$e = ([regex]::Matches($c, "\bend\b")).Count
Write-Host "uIconsSVG.pas: begin=$b end=$e diff=$($b-$e)"

$c = Get-Content "D:\mes projets\Fiche Technique_ModernUI\uBaseForm.pas" -Encoding UTF8 -Raw
$b = ([regex]::Matches($c, "begin")).Count
$e = ([regex]::Matches($c, "\bend\b")).Count
Write-Host "uBaseForm.pas: begin=$b end=$e diff=$($b-$e)"

$c = Get-Content "D:\mes projets\Fiche Technique_ModernUI\uGraphicsGDIP.pas" -Encoding UTF8 -Raw
$b = ([regex]::Matches($c, "begin")).Count
$e = ([regex]::Matches($c, "\bend\b")).Count
Write-Host "uGraphicsGDIP.pas: begin=$b end=$e diff=$($b-$e)"