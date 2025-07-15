# random directory
function randomtext{
    -join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})
}

# random path variables
$wd = randomtext
$path = "$env:temp/$wd"
echo $path

# make new dir in temp
mkdir $path
cd $path
echo "" > poc.txt 
cd C:\Users\ssriy\Downloads\pengerat
