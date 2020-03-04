#!/bin/bash

targetd=$1
projectf=$HOME/projects/$targetd

if [ ! -d "$projectf" ];then
    mkdir $projectf
fi

if [ ! -d "$projectf/recon" ];then
    mkdir $projectf/recon
fi

echo -e "\e[1;33m [+] Finding $targetd subdomain with assetFinder ... \e[0m"
assetfinder $targetd >> $projectf/recon/assetraw.txt
cat $projectf/recon/assetraw.txt | grep $1 >> $projectf/recon/domain_clean.txt
rm $projectf/recon/assetraw.txt

echo -e "\e[1;33m [+] AssetFinder Scan Completed!!! \e[0m"
echo -e "\e[1;33m [+] Now running amass on $targetd ... \e[0m"
amass enum -active -brute -d $targetd -o $projectf/recon/amass_raw.txt
sort -u $projectf/recon/amass_raw.txt >> $projectf/recon/amass_clean.txt
rm $projectf/recon/amass_raw.txt
echo -e "\e[1;33m [+] Amass Scan Completed!!! \e[0m"
echo -e "\e[1;33m [+] Merging and sorting domains for $targetd \e[0m"
cat $projectf/recon/amass_clean.txt $projectf/recon/domain_clean.txt | sort -u >> $projectf/recon/merge_domains.txt
echo -e "\e[1;33m [+] Merge Completed!!! \e[0m"
echo -e "\e[1;33m [+] Testing subdomains at $targetd with Aquatone.. \e[0m"
cat $projectf/recon/merge_domains.txt | aquatone -ports xlarge -out $projectf/recon/aquatone
echo -e "\e[1;33m [+] Aquatone Completed!!! \e[0m"