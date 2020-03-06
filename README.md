# wireguard\_installer

- Neuen Hyper-V Server erstellen (min. 2 Kerne, 1GB RAM, 32GB HDD, Gen2)
- download debian https://www.debian.org/distrib/  --> 64-Bit-PC Netinst-ISO
- installation
	- alles logisch...
	- Root-Passwort ist für den Benutzer root. Damit kann man sich nicht über ssh einloggen
	- Zusätzlicher Benutzer darf sich über SSH einloggen und dann befehle mit der Root-Berechtigung ausführen
	- Partitionierung: Geführt - vollständige Festplatte
	- Einzige Platte auswählen (Hyper-V: SCSI3 (0,0,0) (sda))
	- Alle Dateien auf eine Partition, für Anfänger empfohlen
	- keine andere CD für Zusätzliche Software / Treiber
	- Spiegelserver alles belassen, wie es ist
	- kein Proxy
	- An der Paketerfassung teilnehmen? Nein
	- Softwareauswahl: Nur ssh und Standard-Systemwerkzeuge
	- GRUB installieren? Ja!
	- auf /dev/sda
- als root anmelden (später per ssh als user anmelden (wie oben angelegt) und mit su zum root-user wechseln)
- Installationsscript herungerladen: 
	wget wireguard.comse.eu
- starten:
	bash installer.sh (bzw. bash index.html)
- Userfile downloaden:
	- Mit WinSCP Typ ssh auf den Server verbinden (den vergebenen usernamen verwenden)
	- Das Config File sollte sich im Homeverzeichnis des Users befinden

# Benutzerprofile verwalten
Im folgenden eine kurze Anleitung, wie die Benutzer angelegt, angezeigt und entfernt werden können.

## Verbindung zum Server aufbauen
Mit Putty kann eine Verbindung von Windows aus auf den Debian-Server hergestellt werden:

	Hostname: user@192.168.0.205
Dabei muss der zusätzliche Nutzer angegeben werden, der während der Installation von Debian angegeben wurde. Aus Sicherheitsgründen ist die direkte Anmeldung des Benutzers root über SSH bei Debian deaktiviert. Die Anmeldung kann in Putty unter Saved Sessions mit der Angabe eines Names für die Session gespeichert werden.

Nach der Anmeldung über SSH muss zum benutzer root gewechselt werden. Dies erfolgt mit dem Befehl

	su -
und der eingabe des root Passworts, das während der installation angegeben wurde. das "-" nach dem Befehl "su" muss mit angegeben werden!

Es wurden scripte erstellt, die die Verwaltung der Benutzerprofile erleichtert

## Anlegen eines Benutzers
	wg-add-client username
Dieser Befehl legt einen neuen Benutzer in wireguard an und kopiert die erstellte Konfigurationsdatei im Home-Verzeichnes des Standardbenutzers an. Diese Datei kann z.B. mit WinSCP vom Debian-Server kopiert werden und muss beim Client in Wireguard importiert werden. Nach dem Ausführen des Befehls werden die im System installierten Profile ausgegeben

## Anzeigen der installierten Benutzerprofile
	wg-list-clients
Dieser Befehl zeigt die vorhandenen Benutzerprofile an

## Entfernen eines Benutzers
	wg-remove-client
Dieser Befehl zeigt die installierten Profile an. Danach kann der Name eines Profils angegeben werden, das gelöscht werden soll. Dabei wird der Benutzer ausgewählt, der dem eingegebenen Namen am ehesten entspricht. Ist der Name bereits bekannt, kann dieser auch direkt beim Aufrufen des Scripts mit angegeben werden:

	wg-remove-client username
