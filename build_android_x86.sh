#!/bin/bash

# Functie om het helpbericht weer te geven
function display_help {
  echo "Android-x86 Build Script"
  echo "Gebruik: ./build_android_x86.sh [opties]"
  echo "Opties:"
  echo "  -b, --branch <branch_naam>   Specificeer de branch om te bouwen"
  echo "  -h, --help                   Toon dit helpbericht"
  echo "  -m, --manifest <manifest>    Geef aanvullende manifestbestanden op"
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
    -h|--help)
      display_help
      exit 0
      ;;
    -m|--manifest)
      manifest="$2"
      shift
      ;;
    *)
      echo "Fout: Onbekende optie $1"
      display_help
      exit 1
      ;;
  esac
  shift
done

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

# Choose a target
echo "Choose a target for the x86 device:"
echo "1. android_x86_64 (64-bit)"
echo "2. android_x86 (32-bit)"
read -p "Enter the number corresponding to your choice: " target_choice

case $target_choice in
  1)
    target_product="android_x86_64"
    ;;
  2)
    target_product="android_x86"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Source build/envsetup.sh
source build/envsetup.sh

# Select a target using lunch command
#lunch ${target_product}-userdebug
lunch $TARGET_PRODUCT-$TARGET_BUILD_VARIANT-userdebug

# Build an ISO file
echo "Enter the number of processors you have (e.g., 4 for a quad-core CPU):"
read -p "Number of processors: " num_processors

TARGET_PRODUCT := android_x86_64
TARGET_BUILD_VARIANT := userdebug
TARGET_BUILD_TYPE := release
TARGET_KERNEL_CONFIG := android-x86_64_defconfig

make -jX iso_img

# Using m command to build ISO
m -j${num_processors} iso_img

# Provide information about the generated image
generated_image="out/target/product/${target_product}/${target_product}.iso"
echo "The generated image is located at: ${generated_image}"

sudo out/host/linux-x86/bin/qemu-android

# Set up VirtualBox
VBoxManage createvm --name "Android-x86" --register
VBoxManage modifyvm "Android-x86" --memory 2048
VBoxManage modifyvm "Android-x86" --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage storagectl "Android-x86" --name "IDE" --add ide
VBoxManage storageattach "Android-x86" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium out/target/product/android_x86_64/android_x86_64.iso

# Start VirtualBox
VBoxManage startvm "Android-x86"

# Additional options for testing
echo "Testing options:"
echo "1. Test in a virtual machine (e.g., VirtualBox, QEMU)"
echo "2. Use the qemu-android script to run Android-x86 in QEMU directly"
read -p "Enter the number corresponding to your testing choice: " testing_choice

case $testing_choice in
  1)
    echo "Test the ISO file in a virtual machine."
    # Add any specific instructions for testing in a virtual machine
    ;;
  2)
    echo "Run Android-x86 in QEMU directly using qemu-android script."
    # Add any specific instructions for running in QEMU
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# Additional advanced options (not included in the script, user intervention required):
echo "Advanced options:"
echo "1. Install to USB disk"
echo "2. Install to hard disk"
echo "3. Save data to USB/hard disk"
echo "Please refer to the provided information for these advanced options."

# End of the script
echo "Script execution completed."