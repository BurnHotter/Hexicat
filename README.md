# Hexicat
Lightweight socat wrapper simplifying realtime 2-way transmission of raw bytes over a continuous socket connection.

Ever needed to send raw bytes over TCP straight from you keyboard? Ever debugged an ASCII/UTF-8 disconnect, or needed to spoof a proprietary header made from non-ASCII characters? Until now, the best way to do this was by piping an `echo -ne` command directly into a new netcat connection. While this worked, it came with significant drawbacks. Most notably: it required reestablishing the connection each time you wanted to send more bytes. For red teams, this creates an obvious pattern of attempted penetration for defenders to find. And for everyone else, it wastes bandwidth and loses the connection state that the program you are connecting to might rely on for further functionality.

Hexicat fixes this. This lightweight socat wrapper allows native conversion of typed hex values into raw bytes. Best of all, it keeps the new connection open and allows you to send subsequent bytes over the same TCP socket, no reconnect necessary. It can read and transmit contents of a file, and best of all, if you don't need raw hex, you can seamlessly swap back to ASCII over the same connection.

# Usage
Hexicat requires the following dependencies. Ensure both are installed:
- Bash
- Socat
Ensure hexicat.sh has +x permissions

To run, enter `hexicat.sh [IP] [Port]`
Once the connection opens, you can see a full list of hexicat's features by entering '!help'
