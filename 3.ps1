# 定义源目录路径和临时目录路径
$sourceDir = "Y:\other\"
$tempDir = Join-Path -Path $sourceDir -ChildPath "temp"

# 确保临时目录存在
if (-Not (Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir
}

# 定义 HandBrakeCLI 的路径
$handbrakeCLI = "C:\handbrake\HandBrakeCLI.exe"

# 包括的文件扩展名
$fileExtensions = "*.mp4", "*.mkv", "*.avi", "*.mov"

# 遍历源目录中每个视频文件
foreach ($fileExtension in $fileExtensions) {
    Get-ChildItem -Path $sourceDir -Recurse -Include $fileExtension | ForEach-Object {
        $filePath = $_.FullName
        $fileName = $_.BaseName
        $fileExt = $_.Extension
        $outputFile = Join-Path -Path $tempDir -ChildPath "$fileName`_av1$fileExt"

        Write-Host "正在处理 $filePath..."

        # 使用 HandBrakeCLI 扫描文件获取输出信息
        $scanOutput = & $handbrakeCLI -i $filePath --scan 2>&1

        # 检查扫描输出，判断是否已是 AV1 编码
        if ($scanOutput -match "Video: av1\b") {
            Write-Host "跳过: $filePath 已经是 AV1 编码."
            return
        }

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
}
