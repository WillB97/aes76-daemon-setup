Each stream has its own config file. All lines beginning with `#` are comments and are ignored, each config file should have only one uncommented line.
The arguments on this line are passed as command line arguments to `alsaloop`, generally this line will be in the form:

```
-c <num-channels> -C plughw:<input-device> -P plughw:<output-device>
```

If you only have a single AES67 source and sink stream, they can be referred to as `RAVENNA` for the input or output device.

As well as the arguments from the config file some fixed arguments are passed, these are: `-t 2500 -r 48000 -f S32_LE`.
These set `alsaloop` to use a 2.5ms buffer, a 48kHz sample rate and 32 bit bit-depth.
Note, the daemon will convert the on-the-wire bit-depth to 32 automatically as alsaloop only supports converting to other formats at bit-depths of 32 and 16.

Once the config file has been created it can be enabled using:
```bash
sudo systemctl enable --now aes67-stream@<config-name>
```
If the config name contains spaces quote the name after the `@`.
Note, each AES67 input or output can only be connected to one instance at a time.

Currently on Raspberry Pi this only produces occasional pops,
if this becomes an issue the `-t` value and the daemon's `tic_frame_size` value can be tuned.

## Separating the Ravenna device into channels.
By default only a single Ravenna device is created regardless of how many sources and sinks are created.
The outputs can be converted into separate devices using alsa's `dshare` functionality, while the inputs can use `dsnoop`.
This is defined in `.asoundrc`, for example:


```
# first define the RAVENNA card as PCM slaves to be used by dshare and dsnoop
# if the number of inputs and outputs is the same the can probably be combined
pcm_slave.aes67ins {
    pcm "hw:CARD=RAVENNA"
    channels 4  # The total number of AES67 sink channels
    rate 48000
    format S24_3LE
}
pcm_slave.aes67outs {
    pcm "hw:CARD=RAVENNA"
    channels 4  # The total number of AES67 source channels
    rate 48000
    format S24_3LE
}

# a dshare stereo source of AES67 source channels 2 & 3
pcm.source_2 {
    type dshare
    ipc_key 0x11111
    slave aes67outs
    bindings {
        # map channel of this device to channel of slave device
        0 2  # source_2 ch0 => aes67outs ch2
        1 3  # source_2 ch1 => aes67outs ch3
    }
}

# a dsnoop stereo sink of AES67 sink channels 2 & 3
pcm.sink_2 {
    type dsnoop
    ipc_key 0x11111
    slave aes67ins
    bindings {
        # map channel of this device to channel of slave device
        0 2  # sink_2 ch0 => aes67ins ch2
        1 3  # sink_2 ch1 => aes67ins ch3
    }
}
```

Once these have been defined they can be used as follows:
```
# Route AES67 channels 2 & 3 to the output of the first device
-c 2 -C plug:source_2 -P plughw:0,0
```

```
# Route the microphone of the first device to AES67 channels 2 & 3
-c 2 -C plughw:0,0 -P plug:sink_2
```

For more information see the [Alsa Dshare page](https://alsa.opensrc.org/Dshare) and the [Alsa Dsnoop page](https://alsa.opensrc.org/Dsnoop).
