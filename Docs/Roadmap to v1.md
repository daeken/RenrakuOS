Goal
----

The project goal is that v1.0 should go out on July 4, 2010.  This marks the first anniversary of the project and will be the first major release.

What should it do?
------------------

You should be able to start Renraku in hosted or native mode (IA32 native only) and bring up a usable GUI.  You should be able to browse files, start applications, edit configuration, and run UI tests.  Depending on time constraints, we may or may not have additional applications (and a game?)

What needs to be done?
----------------------

Compiler:

- Exceptions
- Generics
- Array bounds checking
- Emit proper class data for reflection

Gui:

- Basic toolkit for controls
- Image rendering
- Font rendering
- Vector support?

Graphical shell:

- Window management
- Desktop icons
- Some sort of system tray/menu

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
	- Transparent object remoting
- Video driver on IA32 (better than VGA)

Services:

- Capsule implementation
- Service documentation

BCL:

- Migrate to Mono BCL
- Implement more of the BCL, if migrating to the Mono BCL isn't possible/practical

Applications:

- GUI console
- File browser
- Basic text editor
- Image viewer
- Some basic GUI game?

Build System:

- Allow portions of the code to be tagged as platform-specific, rather than the large file lists in the Rakefile
- Integrate building a LiveCD with a complete Renraku system.
- Build Renraku installer (XXX: May get pushed back to v2)
