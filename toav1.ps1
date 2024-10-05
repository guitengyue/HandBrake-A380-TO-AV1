# 定义源目录路径和临时目录路径
$sourceDir = "Y:\XX"
$tempDir = Join-Path -Path $sourceDir -ChildPath "temp"

# 确保临时目录存在
if (-Not (Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir
}

# 定义 HandBrakeCLI 的路径
$handbrakeCLI = "C:\handbrake\HandBrakeCLI.exe"

# 遍历源目录中的每个视频文件并进行转换
Get-ChildItem -Path $sourceDir -Recurse -Include *.mp4 | ForEach-Object {
    $filePath = $_.FullName
    $fileName = $_.BaseName
    $fileExt = $_.Extension
    $outputFile = Join-Path -Path $tempDir -ChildPath "$fileName`_av1$fileExt"

    Write-Host "正在处理 $filePath..."

    # 调用 HandBrakeCLI 进行视频转换
    & $handbrakeCLI -i $filePath -o $outputFile --encoder qsv_av1 -q 30 --auto-anamorphic --keep-display-aspect --rate auto --crop 0:0:0:0

    # 检查转换是否成功
    if (Test-Path -Path $outputFile) {
        Move-Item -Path $outputFile -Destination $filePath -Force
        Write-Host "已转换并替换: $filePath"
    } else {
        Write-Host "转换失败: $filePath"
    }
}