# setup_datasets.ps1
# Chay script nay tai thu muc goc project, vi du: Y:\Python\PrePost
# Muc dich:
# 1. Tao thu muc data
# 2. Tao toy datasets va expected outputs
# 3. Tai benchmark datasets tu FIMI
# 4. Giai nen .dat.gz thanh .txt bang .NET GzipStream
# 5. Tai Groceries raw dataset
# 6. Tao script Julia convert Groceries sang format so

$ErrorActionPreference = "Stop"

Write-Host "=== PrePost dataset setup ===" -ForegroundColor Cyan
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray

# -----------------------------
# 1. Tao thu muc
# -----------------------------
Write-Host "`n[1/7] Creating folders..." -ForegroundColor Cyan

$dirs = @(
    "data\raw",
    "data\toy\expected",
    "data\benchmark",
    "data\application",
    "scripts"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

# -----------------------------
# 2. Tao toy datasets
# -----------------------------
Write-Host "`n[2/7] Creating toy datasets..." -ForegroundColor Cyan

@"
1 2 3
1 3 4
2 3 5
1 2 3 5
2 3 4
"@ | Set-Content -Encoding UTF8 "data\toy\example_basic.txt"

@"
1 2 3 4
1 2 3
1 2 3 4
1 2 3
1 2
"@ | Set-Content -Encoding UTF8 "data\toy\example_special_single_path.txt"

@"
1 #SUP: 3
2 #SUP: 4
3 #SUP: 5
4 #SUP: 2
5 #SUP: 2
1 2 #SUP: 2
1 3 #SUP: 3
2 3 #SUP: 4
2 5 #SUP: 2
3 4 #SUP: 2
3 5 #SUP: 2
1 2 3 #SUP: 2
2 3 5 #SUP: 2
"@ | Set-Content -Encoding UTF8 "data\toy\expected\example_basic_minsup2.out"

@"
1 #SUP: 5
2 #SUP: 5
3 #SUP: 4
4 #SUP: 2
1 2 #SUP: 5
1 3 #SUP: 4
1 4 #SUP: 2
2 3 #SUP: 4
2 4 #SUP: 2
3 4 #SUP: 2
1 2 3 #SUP: 4
1 2 4 #SUP: 2
1 3 4 #SUP: 2
2 3 4 #SUP: 2
1 2 3 4 #SUP: 2
"@ | Set-Content -Encoding UTF8 "data\toy\expected\example_special_minsup2.out"

# -----------------------------
# 3. Tai benchmark datasets
# -----------------------------
Write-Host "`n[3/7] Downloading benchmark datasets..." -ForegroundColor Cyan

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$benchmarks = @(
    @{ Name = "chess";       Url = "https://fimi.uantwerpen.be/data/chess.dat.gz" },
    @{ Name = "mushroom";    Url = "https://fimi.uantwerpen.be/data/mushroom.dat.gz" },
    @{ Name = "retail";      Url = "https://fimi.uantwerpen.be/data/retail.dat.gz" },
    @{ Name = "T10I4D100K";  Url = "https://fimi.uantwerpen.be/data/T10I4D100K.dat.gz" },
    @{ Name = "accidents";   Url = "https://fimi.uantwerpen.be/data/accidents.dat.gz" }
)

foreach ($dataset in $benchmarks) {
    $name = $dataset.Name
    $url = $dataset.Url
    $outFile = "data\raw\$name.dat.gz"

    if (Test-Path $outFile) {
        Write-Host "Already exists: $outFile" -ForegroundColor Yellow
    }
    else {
        Write-Host "Downloading $name..."
        Invoke-WebRequest -Uri $url -OutFile $outFile
    }
}

# -----------------------------
# 4. Giai nen .dat.gz thanh .txt
# -----------------------------
Write-Host "`n[4/7] Extracting .dat.gz files to .txt..." -ForegroundColor Cyan

foreach ($dataset in $benchmarks) {
    $name = $dataset.Name
    $gzPath = "data\raw\$name.dat.gz"
    $outPath = "data\benchmark\$name.txt"

    if (-not (Test-Path $gzPath)) {
        Write-Host "Missing file, skipped: $gzPath" -ForegroundColor Red
        continue
    }

    Write-Host "Extracting $gzPath -> $outPath"

    $inStream = [System.IO.File]::OpenRead($gzPath)
    try {
        $gzipStream = New-Object System.IO.Compression.GzipStream(
            $inStream,
            [System.IO.Compression.CompressionMode]::Decompress
        )

        try {
            $outStream = [System.IO.File]::Create($outPath)
            try {
                $gzipStream.CopyTo($outStream)
            }
            finally {
                $outStream.Close()
            }
        }
        finally {
            $gzipStream.Close()
        }
    }
    finally {
        $inStream.Close()
    }
}

# -----------------------------
# 5. Tai Groceries raw dataset
# -----------------------------
Write-Host "`n[5/7] Downloading Groceries raw dataset..." -ForegroundColor Cyan

$groceriesUrl = "https://raw.githubusercontent.com/stedy/Machine-Learning-with-R-datasets/master/groceries.csv"
$groceriesRaw = "data\application\groceries_raw.csv"

if (Test-Path $groceriesRaw) {
    Write-Host "Already exists: $groceriesRaw" -ForegroundColor Yellow
}
else {
    Invoke-WebRequest -Uri $groceriesUrl -OutFile $groceriesRaw
}

# -----------------------------
# 6. Tao script Julia convert Groceries
# -----------------------------
Write-Host "`n[6/7] Creating Julia converter script..." -ForegroundColor Cyan

@'
input_path = "data/application/groceries_raw.csv"
output_path = "data/application/groceries.txt"
map_path = "data/application/groceries_item_mapping.csv"

item_to_id = Dict{String, Int}()
next_id = 1
converted_lines = String[]

for line in eachline(input_path)
    raw_items = split(strip(line), ",")
    ids = Int[]

    for raw_item in raw_items
        item = strip(raw_item)

        if isempty(item)
            continue
        end

        if !haskey(item_to_id, item)
            item_to_id[item] = next_id
            global next_id += 1
        end

        push!(ids, item_to_id[item])
    end

    ids = sort(unique(ids))
    push!(converted_lines, join(ids, " "))
end

write(output_path, join(converted_lines, "\n"))

open(map_path, "w") do io
    println(io, "id,item")
    for (item, id) in sort(collect(item_to_id), by = x -> x[2])
        println(io, string(id, ",", item))
    end
end

println("Saved converted dataset: ", output_path)
println("Saved item mapping: ", map_path)
println("Number of transactions: ", length(converted_lines))
println("Number of unique items: ", length(item_to_id))
'@ | Set-Content -Encoding UTF8 "scripts\convert_groceries.jl"

# -----------------------------
# 7. Chay convert Groceries neu co Julia
# -----------------------------
Write-Host "`n[7/7] Converting Groceries with Julia..." -ForegroundColor Cyan

$juliaCmd = Get-Command julia -ErrorAction SilentlyContinue

if ($null -eq $juliaCmd) {
    Write-Host "Julia not found in PATH. Please run later:" -ForegroundColor Yellow
    Write-Host "julia scripts\convert_groceries.jl" -ForegroundColor Yellow
}
else {
    julia scripts\convert_groceries.jl
}

# -----------------------------
# Kiem tra ket qua
# -----------------------------
Write-Host "`n=== Dataset files ===" -ForegroundColor Green

Get-ChildItem "data\toy" -Recurse -File | Select-Object FullName, Length
Get-ChildItem "data\benchmark" -File | Select-Object FullName, Length
Get-ChildItem "data\application" -File | Select-Object FullName, Length

Write-Host "`n=== Preview ===" -ForegroundColor Green

Write-Host "`nToy basic:" -ForegroundColor Cyan
Get-Content "data\toy\example_basic.txt" -TotalCount 5

Write-Host "`nChess benchmark:" -ForegroundColor Cyan
Get-Content "data\benchmark\chess.txt" -TotalCount 3

Write-Host "`nGroceries raw:" -ForegroundColor Cyan
Get-Content "data\application\groceries_raw.csv" -TotalCount 3

if (Test-Path "data\application\groceries.txt") {
    Write-Host "`nGroceries converted:" -ForegroundColor Cyan
    Get-Content "data\application\groceries.txt" -TotalCount 3
}

Write-Host "`nDone." -ForegroundColor Green
