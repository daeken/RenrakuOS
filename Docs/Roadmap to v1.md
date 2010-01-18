Goal
====

The project goal is that v1.0 should go out on July 4, 2010.  This marks the first anniversary of the project and will be the first major release.

What should it do?
------------------

You should be able to start Renraku in hosted or native mode (IA32 native only) and bring up a usable GUI.  (XXX: What else?)

What needs to be done?
======================

Compiler:

- Exceptions
- Generics
- Array bounds checking

Gui:

- Basic toolkit for controls
- Image rendering
- Font rendering
- Vector support?

Graphical shell:

- Desktop icons
- Some sort of system tray/menu (let's look to BeOS for inspiration here)

Kernel:

- Tracebacks on exceptions
- Garbage collection
- Memory management
- Storage
	- Low level storage service (hard drive access)
	- FAT32 filesystem service
- Networking
	- TCP
	- IP and UDP supporting fragmenting
	- More robust DHCP
	- DNS
	- Routing
- Video driver on IA32 (better than VGA)

BCL:

- Migrate to Mono BCL
- Implement more of the BCL, if migrating to the Mono BCL isn't possible/practical

Applications:

- GUI console
- File browser
- Basic text editor
- Some basic GUI game?
