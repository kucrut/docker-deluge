**Application**

[Deluge](http://deluge-torrent.org/)

**Description**

Deluge is a full-featured ​BitTorrent client for Linux, OS X, Unix and Windows. It uses ​libtorrent in its backend and features multiple user-interfaces including: GTK+, web and console. It has been designed using the client server model with a daemon process that handles all the bittorrent activity. The Deluge daemon is able to run on headless machines with the user-interfaces being able to connect remotely from any platform.

**Build notes**

Latest Deluge release from Alpine Linux, based on [binhex/arch-deluge](https://github.com/binhex/arch-deluge/).

**Usage**
```
docker run -d \
    -p 8112:8112 \
    -p 58846:58846 \
    -p 58946:58946 \
    --name=<container name> \
    -v <path for data files>:/data \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    kucrut/deluge
```

Please replace all user variables in the above command defined by <> with the correct values.

**Access application**<br>

`http://<host ip>:8112`

**Example**
```
docker run -d \
    --name=deluge \
    -p 8112:8112 \
    -p 58846:58846 \
    -p 58946:58946 \
    -v /apps/docker/deluge/data:/data \
    -v /apps/docker/deluge/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=022 \
    -e PUID=1000 \
    -e PGID=000 \
    kucrut/deluge
```

**Notes**<br>

Setting PUID (User ID) and PGID (Group ID) environment variable is optional and they can be found by issuing the following command for the user you want to run the container as:

```
id <username>
```
