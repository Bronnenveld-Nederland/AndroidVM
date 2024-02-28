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

# Functie om een optie ongedaan te maken
function undo_option {
  read -p "Wilt u de laatst gekozen optie ongedaan maken? (ja/nee): " undo_confirm
  if [[ $undo_confirm == "ja" ]]; then
    echo "Ongedaan maken van de laatst gekozen optie..."
    # Voer hier de nodige stappen uit om de laatste optie ongedaan te maken
  else
    echo "Optie niet ongedaan gemaakt."
  fi
}

# Logging functie
function log {
  echo "[LOG] $1"
}

# Foutafhandeling functie
function handle_error {
  echo "[FOUT] $1"
  exit 1
}

# Standaardwaarden
default_branch="oreo-x86"
manifest="default.xml"
branches=("r-x86" "q-x86" "pie-x86" "oreo-x86" "nougat-x86" "marshmallow-x86" "lollipop-x86" "kitkat-x86" "jb-x86" "ics-x86" "honeycomb-x86" "gingerbread-x86" "froyo-x86" "eclair-x86" "donut-x86" "cupcake-x86")
branch_names=("Android 11.0" "Android 10.0" "Android 9.0" "Android 8.1" "Android 7.1" "Android 6.0" "Android 5.1" "Android 4.4" "Android 4.3" "Android 4.0" "Android 3.2" "Android 2.3" "Android 2.2" "Android 2.1" "Android 1.6" "Android 1.5")

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
      handle_error "Onbekende optie $1"
      ;;
  esac
  shift
done

# Geef beschikbare branches weer en laat de gebruiker kiezen
log "Beschikbare branches:"
for ((i=0; i<${#branches[@]}; i++)); do
  log "$(($i+1)). ${branch_names[$i]} (${branches[$i]})"
done

read -p "Voer het nummer in dat overeenkomt met uw gewenste branch (standaard: 1): " branch_choice
branch_choice="${branch_choice:-1}"  # Stel standaard in op 1 als er geen invoer is

# Kies de branch op basis van de keuze
if [[ $branch_choice -ge 1 && $branch_choice -le ${#branches[@]} ]]; then
  branch="${branches[$(($branch_choice-1))]}"
else
  log "Ongeldige keuze. Standaardbranch '$default_branch' wordt gebruikt."
  branch="$default_branch"
fi

# Toon gekozen branch en manifest
log "Bouwen van Android-x86 branch: $branch"
log "Gebruiken van manifest: $manifest"

# Instellingen voor de omgeving
log "Instellen van de bouwomgeving..."
sudo apt -y install git gcc curl make repo libxml2-utils flex m4 || handle_error "Kon niet alle vereiste pakketten installeren."
sudo apt -y install openjdk-8-jdk lib32stdc++6 libelf-dev mtools
sudo apt -y install libssl-dev python3-enum34 python3-mako syslinux-utils

# Kloon Android-x86-broncode
log "Klonen van Android-x86-broncode..."
mkdir android-x86 || handle_error "Kon de map niet maken voor het klonen van de broncode."
cd android-x86 || handle_error "Kon niet naar de map android-x86 gaan."
repo init -u git://git.osdn.net/gitroot/android-x86/manifest -m $manifest -b $branch || handle_error "Kon de broncode niet initialiseren met de opgegeven parameters."
repo sync --no-tags --no-clone-bundle || handle_error "Kon de broncode niet synchroniseren."

# Toon voltooiingsbericht
log "Android-x86-bouwomgeving is ingesteld en broncode is gekloond."
log "U kunt nu doorgaan met het bouwen van de image met de verstrekte instructies."

# Kies een doelplatform
log "Kies een doelplatform voor het x86-apparaat:"
log "1. android_x86_64 (64-bit)"
log "2. android_x86 (32-bit)"
read -p "Voer het nummer in dat overeenkomt met uw keuze: " target_choice

case $target_choice in
  1)
    target_product="android_x86_64"
    ;;
  2)
    target_product="android_x86"
    ;;
  *)
    handle_error "Ongeldige keuze. Afsluiten."
    ;;
esac

# Toon gekozen branch en manifest
log "Bouwen van Android-x86 branch: $branch"
log "Gebruiken van manifest: $manifest"


# Bron build/envsetup.sh
source build/envsetup.sh

# Selecteer een doelplatform met het lunch-commando
lunch $target_product-userdebug || handle_error "Kon het lunch-commando niet uitvoeren."

# Bouw een ISO-bestand
log "Voer het aantal processorkernen in dat u heeft (bijv. 4 voor een quad-core CPU):"
read -p "Aantal processoren: " num_processors

# Gebruik m-commando om ISO te bouwen
m -j${num_processors} iso_img || handle_error "Kon geen ISO-bestand bouwen."

# Toon informatie over het gegenereerde image
generated_image="out/target/product/${target_product}/${target_product}.iso"
log "Het gegenereerde image bevindt zich op: ${generated_image}"

# Start VirtualBox
VBoxManage createvm --name "Android-x86" --register
VBoxManage modifyvm "Android-x86" --memory 2048
VBoxManage modifyvm "Android-x86" --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage storagectl "Android-x86" --name "IDE" --add ide
VBoxManage storageattach "Android-x86" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium ${generated_image}

# Start VirtualBox
VBoxManage startvm "Android-x86"

# Extra opties voor testen
log "Testopties:"
log "1. Test het ISO-bestand in een virtuele machine (bijv. VirtualBox, QEMU)"
log "2. Gebruik het qemu-android-script om Android-x86 rechtstreeks in QEMU uit te voeren"
read -p "Voer het nummer in dat overeenkomt met uw testkeuze: " testing_choice

case $testing_choice in
  1)
    log "Test het ISO-bestand in een virtuele machine."
    # Voeg eventuele specifieke instructies toe voor testen in een virtuele machine
    ;;
  2)
    log "Voer Android-x86 rechtstreeks uit in QEMU met het qemu-android-script."
    # Voeg eventuele specifieke instructies toe voor uitvoeren in QEMU
    ;;
  *)
    handle_error "Ongeldige keuze. Afsluiten."
    ;;
esac

# Kopieer naar USB-optie
log "Extra opties:"
log "4. Kopieer Android-x86-image naar USB"
read -p "Voer het nummer in dat overeenkomt met uw keuze: " additional_choice

case $additional_choice in
  1)
    log "Test het ISO-bestand in een virtuele machine."
    # Voeg eventuele specifieke instructies toe voor testen in een virtuele machine
    ;;
  2)
    log "Voer Android-x86 rechtstreeks uit in QEMU met het qemu-android-script."
    # Voeg eventuele specifieke instructies toe voor uitvoeren in QEMU
    ;;
  3)
    log "Afsluiten."
    exit 0
    ;;
  4)
    copy_to_usb
    exit 0
    ;;
  *)
    handle_error "Ongeldige keuze. Afsluiten."
    ;;
esac

# Einde van het script
log "Uitvoering van het script voltooid."
