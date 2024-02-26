# AndroidVM
Dit script bevat opties om de branch (-b of --branch) en het manifest (-m of --manifest) te specificeren, en geeft een helpbericht weer (-h of --help). U kunt dit script uitvoeren in de terminal en de vereiste opties opgeven. Zorg ervoor dat het uitvoeringsrechten heeft (chmod +x build_android_x86.sh) voordat u het uitvoert.

### Android-x86 Build Script

## Overzicht
Dit script automatiseert het bouwproces van Android-x86 voor verschillende doelplatforms. Het is ontworpen om het proces te stroomlijnen, de gebruiker te voorzien van flexibiliteit bij het kiezen van opties en een geïntegreerde functie om de gebouwde image direct naar een USB-apparaat te kopiëren.

## Functies

    1. Bouwt Android-x86 voor zowel 32-bits als 64-bits doelplatforms.
    2. Ondersteunt verschillende branches en manifestbestanden.
    3. Automatiseert het instellen van de bouwomgeving en het klonen van de broncode.
    4. Biedt opties voor het testen in virtuele machines (bijv. VirtualBox, QEMU).
    5. Inclusief functie om de gebouwde image direct naar een USB-apparaat te kopiëren.

## Gebruik

Voer het script uit met de gewenste opties:

```bash
./build_android_x86.sh -b <branch_naam> -m <manifest>

Voor gedetailleerde informatie over beschikbare opties, gebruik:

```bash
./build_android_x86.sh -h

## Doel

Het hoofddoel van dit script is om het proces van het bouwen van Android-x86 te automatiseren en de gebruiker een intuïtieve interface te bieden om verschillende opties te selecteren. Het stelt ontwikkelaars in staat snel een aangepaste Android-x86-image te bouwen en deze te testen in virtuele machines of op fysieke hardware.

## Probleemoplossing en Verbeteringen

Voel je vrij om problemen te melden of verbeteringen voor te stellen door een probleem aan te maken of een pull-verzoek in te dienen. Feedback is welkom!