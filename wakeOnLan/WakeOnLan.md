# Wake on LAN implementation 

Getting the server to work the way I wanted was an interesting problem. My home has no ethernet ports around the house, so in order for my server to have a wired connection, it must be placed right next to the router. Turning the server on and off wouldn't be an issue, however the router is placed in the basement, which is also currently inhabited by my roomate. So in the name of saving time and having to ask my roommate if I can go turn on the router every time I wanted to use it, I decided to use wake on lan to turn the device on and off.

In order to wake a pc up over a network, you must send a magic packet. This magic packet is routed to the broadcast address of the subnet, and any device in the subnet with the matching mac-addresses will receive the packet and be woken from the suspended state.

The device must be in this suspended state so the network interface card still has enough power to read sent messages. At first I was scared to have the pc always on due to the power bill, but from what I've read, it seems to use a significantly less amount of power to run than being on normally.

## Steps taken:

#### From server:

First I checked my ubuntu servers bios to see if wake on lan was a feature available. It was, so I enabled it and restated.


After enabling it in the bios, I logged on to ubuntu server and installed ethtool


    sudo apt install ethtool


I ran ethtool on my server's interface and checked the output to see if the ubuntu server was able to use wake on lan.

    sudo ethtool <interface_name>
    Wake-on: D 

We need to enable this interface to accept wake on lan packets: 

    sudo ethtool --change <interface_name> wol g

Command to use when logging out of the machine:

    sudo systemctl suspend

This command will suspend all processes and save there current state. Suspending also allows me to not have to re-enable wake on lan everytime we put the server into a low power state. We can create a one shot service with systemctl to re-enable wakeonlan after a complete shutdown.

    [Unit]
    Description=Enable Wake On Lan

    [Service]
    Type=oneshot
    ExecStart = /sbin/ethtool --change enp4s0 wol g

    [Install]
    WantedBy=basic.target
I placed these line in /etc/systemd/system/wol.service. This directory is were unit files for systemd are stored. 


From work station

First I installed wakeonlan

    sudo apt install wakeonlan

I then utilized chatgpt to write a connection script that turns on the server, waits for it to be fully powered on, and then intiates and ssh connection. SSH client is installed on ubuntu server install.

