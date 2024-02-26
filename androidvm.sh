#!/bin/bash

# Functie om het helpbericht weer te geven
function display_help {
  echo "Android-x86 Bouwscript"
  echo "Gebruik: ./build_android_x86.sh [opties]"
  echo "Opties:"
  echo "  -b, --branch <branch_naam>   Specificeer de branch om te bouwen (standaard: oreo-x86)"
  echo "  -m, --manifest <manifest>    Geef aanvullende manifestbestanden op (standaard: default.xml)"
  echo "  -h, --help                   Toon dit helpbericht"
}

# Functie om ISO naar USB te kopiëren
function copy_to_usb {
  echo "Beschikbare schijven:"
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

  read -p "Voer het apparaat in waarnaar u de Android-x86-image wilt kopiëren (bijv. /dev/sdX): " usb_device

  if [[ ! -e $usb_device ]]; then
    echo "Ongeldig apparaat. Afsluiten."
    exit 1
  fi

  read -p "Waarschuwing: Alle gegevens op $usb_device worden verwijderd. Doorgaan? (ja/nee): " confirm

  if [[ $confirm != "ja" ]]; then
    echo "Afsluiten."
    exit 1
  fi

  sudo dd if=${generated_image} of=${usb_device} bs=4M status=progress conv=fdatasync
  echo "Kopiëren naar USB voltooid."
}

# Standaardwaarden
branch="oreo-x86"
manifest="default.xml"

# Parseer commandoregelopties
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -b|--branch)
      branch="$2"
      shift
      ;;
    -m|--manifest)
      manifest="$2"
      shift
      ;;
    -h|--help)
      display_help
      exit 0
      ;;
    *)
      echo "Fout: Onbekende optie $1"
      display_help
      exit 1
      ;;
  esac
  shift
done

# ... (Rest van het script blijft hetzelfde)
# Toon gekozen branch en manifest
echo "Bouwen van Android-x86 branch: $branch"
echo "Gebruiken van manifest: $manifest"

# Instellingen voor de omgeving
echo "Instellen van de bouwomgeving..."
sudo apt -y install git gcc curl make repo libxml2-utils flex m4
sudo apt -y install openjdk-8-jdk lib32stdc++6 libelf-dev mtools
sudo apt -y install libssl-dev python-enum34 python-mako syslinux-utils

# Kloon Android-x86-broncode
echo "Klonen van Android-x86-broncode..."
mkdir android-x86
cd android-x86
repo init -u git://git.osdn.net/gitroot/android-x86/manifest -m $manifest -b $branch
repo sync --no-tags --no-clone-bundle

# Toon voltooiingsbericht
echo "Android-x86-bouwomgeving is ingesteld en broncode is gekloond."
echo "U kunt nu doorgaan met het bouwen van de image met de verstrekte instructies."

# Kies een doelplatform
echo "Kies een doelplatform voor het x86-apparaat:"
echo "1. android_x86_64 (64-bit)"
echo "2. android_x86 (32-bit)"
read -p "Voer het nummer in dat overeenkomt met uw keuze: " target_choice

case $target_choice in
  1)
    target_product="android_x86_64"
    ;;
  2)
    target_product="android_x86"
    ;;
  *)
    echo "Ongeldige keuze. Afsluiten."
    exit 1
    ;;
esac

# Bron build/envsetup.sh
source build/envsetup.sh

# Selecteer een doelplatform met het lunch-commando
lunch $target_product-userdebug

# Bouw een ISO-bestand
echo "Voer het aantal processorkernen in dat u heeft (bijv. 4 voor een quad-core CPU):"
read -p "Aantal processoren: " num_processors

# Gebruik m-commando om ISO te bouwen
m -j${num_processors} iso_img

# Toon informatie over het gegenereerde image
generated_image="out/target/product/${target_product}/${target_product}.iso"
echo "Het gegenereerde image bevindt zich op: ${generated_image}"

# Start VirtualBox
VBoxManage createvm --name "Android-x86" --register
VBoxManage modifyvm "Android-x86" --memory 2048
VBoxManage modifyvm "Android-x86" --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage storagectl "Android-x86" --name "IDE" --add ide
VBoxManage storageattach "Android-x86" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium ${generated_image}

# Start VirtualBox
VBoxManage startvm "Android-x86"

# Extra opties voor testen
echo "Testopties:"
echo "1. Test het ISO-bestand in een virtuele machine (bijv. VirtualBox, QEMU)"
echo "2. Gebruik het qemu-android-script om Android-x86 rechtstreeks in QEMU uit te voeren"
read -p "Voer het nummer in dat overeenkomt met uw testkeuze: " testing_choice

case $testing_choice in
  1)
    echo "Test het ISO-bestand in een virtuele machine."
    # Voeg eventuele specifieke instructies toe voor testen in een virtuele machine
    ;;
  2)
    echo "Voer Android-x86 rechtstreeks uit in QEMU met het qemu-android-script."
    # Voeg eventuele specifieke instructies toe voor uitvoeren in QEMU
    ;;
  *)
    echo "Ongeldige keuze. Afsluiten."
    exit 1
    ;;
esac

# Kopieer naar USB-optie
echo "Extra opties:"
echo "4. Kopieer Android-x86-image naar USB"
read -p "Voer het nummer in dat overeenkomt met uw keuze: " additional_choice

case $additional_choice in
  1)
    echo "Test het ISO-bestand in een virtuele machine."
    # Voeg eventuele specifieke instructies toe voor testen in een virtuele machine
    ;;
  2)
    echo "Voer Android-x86 rechtstreeks uit in QEMU met het qemu-android-script."
    # Voeg eventuele specifieke instructies toe voor uitvoeren in QEMU
    ;;
  3)
    echo "Afsluiten."
    exit 0
    ;;
  4)
    copy_to_usb
    exit 0
    ;;
  *)
    echo "Ongeldige keuze. Afsluiten."
    exit 1
    ;;
esac

# Einde van het script
echo "Uitvoering van het script voltooid."
