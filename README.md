# Host Sink!

Just a small program to generate a list of hosts to be mapped onto
localhost. The program generates both a compatible `/etc/hosts` file as
well as an unbound `local-data.conf` which it outputs into the directory
where it was run. It relies on external sources with slightly
different formatting and coalesces them inte one list without
duplicates.

## Config

The program defaults to the following sources:

 * https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
 * https://mirror1.malwaredomains.com/files/justdomains
 * http://sysctl.org/cameleon/hosts
 * https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist
 * https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
 * https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
 * https://hosts-file.net/ad_servers.txt
 * http://winhelp2002.mvps.org/hosts.txt

Which are compiled in. You can also append or replace the sources list
using an ini file at `~/.config/host-sink/ini`.

~~~{.ini}
[sources]
replace = https://one.com/hosts, https://two.com/hosts
append = https://three.com/hosts

[http-proxy]
host = https://www-gw.example.com
port = 8080
~~~

This config results in proyxing through `www-gw.example.com:8080` with
`{one,two,three}.com/hosts` as sources.

## Usage

If you're using NixOS:

  1. Run `host-sink -s -u` in the same folder as your `configuration.nix`
  1. Just put one or both of the following directives into your
     `configuration.nix`:

     ~~~{.nix}

        networking.extraHosts = builtins.readFile ./hosts
        services.unbound.extraConfig = builtins.readFile ./local-data.conf

     ~~~

# Notes

This can be [trivially done with awk+sort within NixOS](https://github.com/NixOS/nixpkgs/pull/47518) using (`builtins.fetchurl`)
but this was slightly more entertaining.
